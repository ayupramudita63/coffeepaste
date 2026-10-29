import 'dart:async';

import '../core/constants/app_constants.dart';
import '../features/cart/cart_item_model.dart';
import '../features/order/data/order_repository.dart';
import '../features/order/models/order_model.dart';
import '../features/order/models/product_review_draft.dart';
import 'base_provider.dart';

/// Pemicu notifikasi lokal: daftar pesanan lama vs. daftar pesanan terbaru
/// dari server.
typedef OrdersChangedListener = void Function(
  List<OrderModel> previous,
  List<OrderModel> next,
);

/// [status] = status memuat daftar pesanan.
/// [isSubmitting] / [submitError] = status membuat atau membatalkan pesanan.
class OrderProvider extends BaseProvider {
  /// Jeda antar pengecekan status pesanan saat layar Pesanan terbuka.
  static const Duration pollInterval = Duration(seconds: 10);

  final OrderRepository _repository;

  /// Dipanggil setiap daftar pesanan dari server diganti (bukan perubahan lokal
  /// seperti membuat/membatalkan pesanan). Dipakai untuk memicu notifikasi
  /// lokal saat status atau pembayaran berubah.
  final OrdersChangedListener? onOrdersChanged;

  OrderProvider(this._repository, {this.onOrdersChanged});

  List<OrderModel> _orders = const [];
  bool _isSubmitting = false;
  String? _submitError;
  OrderModel? _lastCreatedOrder;

  Timer? _pollTimer;
  bool _isRefreshing = false;

  /// Naik setiap [clear] (logout) supaya hasil fetch lama tidak menimpa data akun berikutnya.
  int _epoch = 0;

  List<OrderModel> get orders => List.unmodifiable(_orders);

  List<OrderModel> get ongoingOrders =>
      _orders.where((order) => order.isOngoing).toList();

  List<OrderModel> get historyOrders =>
      _orders.where((order) => !order.isOngoing).toList();

  bool get isSubmitting => _isSubmitting;
  String? get submitError => _submitError;

  /// Pesanan yang baru berhasil dibuat lewat [createOrder] (untuk membuka halaman pembayaran).
  OrderModel? get lastCreatedOrder => _lastCreatedOrder;

  /// Pesanan berdasarkan ID server (mis. "#CP00001"); null bila tidak ada.
  OrderModel? orderById(String id) {
    for (final order in _orders) {
      if (order.id == id) return order;
    }
    return null;
  }

  bool get isPolling => _pollTimer != null;

  /// Mulai mengecek status pesanan secara berkala. Aman dipanggil berulang.
  /// Hanya benar-benar memanggil server bila ada pesanan yang sedang berlangsung.
  void startPolling({Duration interval = pollInterval}) {
    if (_pollTimer != null) return;
    _pollTimer = Timer.periodic(
      interval,
      (_) => refreshSilently(onlyIfOngoing: true),
    );
  }

  void stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  /// Memuat ulang pesanan tanpa loading. Kegagalan diabaikan (data lama dipakai);
  /// listener baru diberi tahu bila datanya benar-benar berubah.
  ///
  /// [notify] = false dipakai saat kembali dari background dan push server
  /// sudah menampilkan perubahannya sendiri, supaya tidak ada notifikasi ganda.
  Future<void> refreshSilently({
    bool onlyIfOngoing = false,
    bool notify = true,
  }) async {
    if (isLoading || _isRefreshing || _isSubmitting) return;
    if (onlyIfOngoing && !_orders.any((order) => order.isOngoing)) return;

    _isRefreshing = true;
    final epoch = _epoch;
    try {
      final fresh = await _repository.fetchOrders();
      if (epoch != _epoch || _isSubmitting) return;
      if (_signature(fresh) != _signature(_orders)) {
        final previous = _orders;
        _orders = fresh;
        notifyListeners();
        if (notify) onOrdersChanged?.call(previous, fresh);
      }
    } catch (_) {
      // Jaringan putus sesaat: coba lagi pada putaran berikutnya.
    } finally {
      _isRefreshing = false;
    }
  }

  static String _signature(List<OrderModel> orders) => orders
      .map((o) =>
          '${o.id}:${o.status.name}:${o.paid}:${o.items.length}:${o.reviewedItemIds.length}')
      .join('|');

  Future<void> loadOrders() async {
    if (isLoading) return;
    setLoading();

    try {
      final previous = _orders;
      _orders = await _repository.fetchOrders();
      setSuccess();
      onOrdersChanged?.call(previous, _orders);
    } catch (error) {
      setError(error);
    }
  }

  /// Checkout. Mengembalikan true jika pesanan berhasil dibuat.
  Future<bool> createOrder({
    required List<CartItemModel> items,
    required String orderType,
    PaymentMethod paymentMethod = PaymentMethod.qris,
  }) async {
    if (_isSubmitting || items.isEmpty) return false;

    _isSubmitting = true;
    _submitError = null;
    _lastCreatedOrder = null;
    notifyListeners();

    try {
      final subtotal =
          items.fold<int>(0, (sum, item) => sum + item.subtotal);
      final tax = (subtotal * AppConstants.taxRate).round();

      final order = await _repository.createOrder(
        items: items,
        orderType: orderType,
        paymentMethod: paymentMethod,
        subtotal: subtotal,
        tax: tax,
        total: subtotal + tax,
      );

      _orders = [order, ..._orders];
      _lastCreatedOrder = order;
      return true;
    } catch (error) {
      _submitError = BaseProvider.messageOf(error);
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  /// Customer hanya bisa membatalkan sebelum kasir memproses pesanan
  /// (aturan final ada di backend).
  Future<bool> cancelOrder(String orderId) async {
    if (_isSubmitting) return false;

    _isSubmitting = true;
    _submitError = null;
    notifyListeners();

    try {
      await _repository.cancelOrder(orderId);

      _orders = [
        for (final order in _orders)
          order.id == orderId
              ? order.copyWith(status: OrderStatus.cancelled)
              : order,
      ];
      return true;
    } catch (error) {
      _submitError = BaseProvider.messageOf(error);
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  /// Kirim ulasan per produk. Mengembalikan true bila berhasil; pesan gagal ada di [submitError].
  Future<bool> submitReviews(
    OrderModel order,
    List<ProductReviewDraft> reviews,
  ) async {
    if (_isSubmitting || reviews.isEmpty) return false;

    _isSubmitting = true;
    _submitError = null;
    notifyListeners();

    try {
      await _repository.submitReviews(order.id, reviews);

      final reviewed = reviews.map((review) => review.menuItemId);
      _orders = [
        for (final o in _orders)
          o.id == order.id
              ? o.copyWith(reviewedItemIds: {...o.reviewedItemIds, ...reviewed})
              : o,
      ];
      return true;
    } catch (error) {
      _submitError = BaseProvider.messageOf(error);
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  void clear() {
    _epoch++;
    stopPolling();
    _orders = const [];
    _lastCreatedOrder = null;
    resetStatus();
  }

  @override
  void dispose() {
    stopPolling();
    super.dispose();
  }
}
