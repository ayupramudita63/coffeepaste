import '../../../core/constants/app_constants.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/utils/option_labels.dart';
import '../../cart/cart_item_model.dart';
import '../models/order_model.dart';
import '../models/product_review_draft.dart';
import 'order_repository.dart';

/// Repository palsu untuk pesanan. Disimpan di memori selama aplikasi jalan.
///
/// Status pesanan baru maju otomatis agar alur UI bisa dicoba:
/// diterima -> diproses (20 dtk) -> siap diambil (45 dtk) -> selesai (70 dtk).
/// Pembayaran juga disimulasikan: QRIS lunas 12 dtk setelah dipesan, tunai lunas
/// 15 dtk setelah dipesan (seolah kasir sudah menerima uang).
class MockOrderRepository implements OrderRepository {
  final Duration latency;

  MockOrderRepository({this.latency = const Duration(milliseconds: 600)}) {
    _seedHistory();
  }

  final List<_MockOrderRecord> _records = [];
  int _counter = 0;

  @override
  Future<List<OrderModel>> fetchOrders() async {
    await Future<void>.delayed(latency);

    final orders = _records.map((record) => record.toOrder()).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    return orders;
  }

  @override
  Future<OrderModel> createOrder({
    required List<CartItemModel> items,
    required String orderType,
    required PaymentMethod paymentMethod,
    required int subtotal,
    required int tax,
    required int total,
  }) async {
    await Future<void>.delayed(latency);

    if (items.isEmpty) {
      throw const ApiException('Keranjang kosong.', statusCode: 422);
    }

    final number = _nextNumber();
    final record = _MockOrderRecord(
      id: 'mock-$number',
      orderNumber: number,
      createdAt: DateTime.now(),
      orderType: orderType,
      total: total,
      items: items.map(_toOrderItem).toList(),
      paymentMethod: paymentMethod,
    );

    _records.add(record);
    return record.toOrder();
  }

  @override
  Future<void> cancelOrder(String orderId) async {
    await Future<void>.delayed(latency);

    final index = _records.indexWhere((record) => record.id == orderId);
    if (index == -1) {
      throw const ApiException('Pesanan tidak ditemukan.', statusCode: 404);
    }

    final record = _records[index];
    final current = record.toOrder();
    if (current.status != OrderStatus.received || current.paid) {
      throw const ApiException(
        'Pesanan sudah diproses kasir dan tidak dapat dibatalkan dari aplikasi. Hubungi kasir.',
        statusCode: 422,
      );
    }

    record.cancelled = true;
  }

  @override
  Future<void> submitReviews(
    String orderId,
    List<ProductReviewDraft> reviews,
  ) async {
    await Future<void>.delayed(latency);

    final index = _records.indexWhere((record) => record.id == orderId);
    if (index == -1) {
      throw const ApiException('Pesanan tidak ditemukan.', statusCode: 404);
    }

    final record = _records[index];
    if (record.status != OrderStatus.completed) {
      throw const ApiException(
        'Review hanya bisa diberikan untuk pesanan yang sudah selesai',
        statusCode: 422,
      );
    }

    final inOrder = record.items.map((item) => item.menuItemId).toSet();
    for (final review in reviews) {
      if (!inOrder.contains(review.menuItemId)) {
        throw const ApiException('Produk tidak ada di pesanan ini',
            statusCode: 422);
      }
      if (record.reviewed.contains(review.menuItemId)) {
        throw const ApiException(
          'Produk ini sudah pernah diulas pada pesanan ini',
          statusCode: 422,
        );
      }
    }
    record.reviewed.addAll(reviews.map((review) => review.menuItemId));
  }

  OrderItem _toOrderItem(CartItemModel item) {
    final summary = item.optionsSummary;

    return OrderItem(
      name: item.product.name,
      imagePath: item.product.imageUrl ?? '',
      quantity: item.quantity,
      price: item.product.price,
      variant: summary.isEmpty ? null : summary,
      menuItemId: item.product.id,
      size: item.size,
      ice: OptionLabels.toApiLevel(item.ice),
      sugar: OptionLabels.toApiLevel(item.sugar),
    );
  }

  String _nextNumber() {
    _counter++;
    return 'CP${_counter.toString().padLeft(3, '0')}';
  }

  void _seedHistory() {
    final now = DateTime.now();

    int totalOf(List<OrderItem> items) {
      final subtotal = items.fold<int>(0, (sum, i) => sum + i.subtotal);
      return subtotal + (subtotal * AppConstants.taxRate).round();
    }

    final first = [
      const OrderItem(
        name: 'Coffee Latte',
        imagePath: 'assets/images/latte.jpg',
        quantity: 2,
        price: 22000,
        variant: 'Regular  |  Normal Ice  |  Less Sugar',
        menuItemId: 'p1',
        size: 'Regular',
        ice: 'Normal',
        sugar: 'Less',
      ),
      const OrderItem(
        name: 'Croissant Butter',
        imagePath: 'assets/images/latte.jpg',
        quantity: 1,
        price: 19000,
        menuItemId: 'p5',
      ),
    ];
    final second = [
      const OrderItem(
        name: 'Matcha Latte',
        imagePath: 'assets/images/latte.jpg',
        quantity: 1,
        price: 24000,
        variant: 'Large  |  Less Ice  |  Normal Sugar',
        menuItemId: 'p3',
        size: 'Large',
        ice: 'Less',
        sugar: 'Normal',
      ),
    ];

    final firstNumber = _nextNumber();
    _records.add(
      _MockOrderRecord(
        id: 'mock-$firstNumber',
        orderNumber: firstNumber,
        createdAt: now.subtract(const Duration(days: 3)),
        orderType: 'Pick Up',
        total: totalOf(first),
        items: first,
        fixedStatus: OrderStatus.completed,
        fixedPaid: true,
      ),
    );

    final secondNumber = _nextNumber();
    _records.add(
      _MockOrderRecord(
        id: 'mock-$secondNumber',
        orderNumber: secondNumber,
        createdAt: now.subtract(const Duration(days: 1)),
        orderType: 'Dine In',
        total: totalOf(second),
        items: second,
        fixedStatus: OrderStatus.cancelled,
      ),
    );
  }
}

class _MockOrderRecord {
  final String id;
  final String orderNumber;
  final DateTime createdAt;
  final String orderType;
  final int total;
  final List<OrderItem> items;
  final OrderStatus? fixedStatus;
  final PaymentMethod paymentMethod;
  final bool? fixedPaid;
  bool cancelled = false;

  /// ID menu yang sudah diulas pada pesanan ini.
  final Set<String> reviewed = {};

  _MockOrderRecord({
    required this.id,
    required this.orderNumber,
    required this.createdAt,
    required this.orderType,
    required this.total,
    required this.items,
    this.fixedStatus,
    this.paymentMethod = PaymentMethod.qris,
    this.fixedPaid,
  });

  OrderStatus get status {
    if (fixedStatus != null) return fixedStatus!;
    if (cancelled) return OrderStatus.cancelled;

    final seconds = DateTime.now().difference(createdAt).inSeconds;
    if (seconds < 20) return OrderStatus.received;
    if (seconds < 45) return OrderStatus.preparing;
    if (seconds < 70) return OrderStatus.ready;
    return OrderStatus.completed;
  }

  /// Lunas otomatis setelah beberapa detik; pesanan batal tidak pernah lunas.
  bool get paid {
    if (fixedPaid != null) return fixedPaid!;
    if (cancelled || fixedStatus == OrderStatus.cancelled) return false;
    final seconds = DateTime.now().difference(createdAt).inSeconds;
    return seconds >= (paymentMethod == PaymentMethod.qris ? 12 : 15);
  }

  OrderModel toOrder() {
    final isPaid = paid;
    final currentStatus = status;
    return OrderModel(
      id: id,
      orderNumber: orderNumber,
      date: createdAt,
      orderType: orderType,
      status: currentStatus,
      items: items,
      total: total,
      reviewedItemIds: Set.of(reviewed),
      paymentMethod: paymentMethod,
      paid: isPaid,
      cashReceived:
          isPaid && paymentMethod == PaymentMethod.cash ? _roundUp(total) : null,
      cashierName: isPaid ? 'Kasir Demo' : null,
      qrisPayload: paymentMethod == PaymentMethod.qris &&
              !isPaid &&
              currentStatus != OrderStatus.cancelled
          ? 'MOCK-QRIS-$orderNumber-$total'
          : null,
    );
  }

  /// Uang tunai simulasi: dibulatkan ke atas ke kelipatan Rp 10.000.
  static int _roundUp(int amount) => ((amount + 9999) ~/ 10000) * 10000;
}
