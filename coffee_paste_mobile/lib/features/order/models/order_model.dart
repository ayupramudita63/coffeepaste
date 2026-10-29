import '../../../core/constants/app_constants.dart';
import '../../../core/network/api_config.dart';
import '../../../core/utils/json_utils.dart';
import '../../../core/utils/option_labels.dart';

/// Satu baris produk di dalam pesanan.
class OrderItem {
  final String name;
  final String imagePath;
  final int quantity;
  final int price;

  /// ID menu di backend (null untuk data lama / mock tanpa ID). Dipakai untuk
  /// "Pesan Lagi" dan ulasan per produk.
  final String? menuItemId;

  /// Pilihan minuman dalam nilai backend: size Regular|Large, ice/sugar Normal|Less|No.
  /// null untuk item non-minuman.
  final String? size;
  final String? ice;
  final String? sugar;

  /// Ringkasan pilihan, contoh: "Large  |  Less Ice  |  Normal Sugar".
  final String? variant;

  const OrderItem({
    required this.name,
    required this.imagePath,
    required this.quantity,
    required this.price,
    this.variant,
    this.menuItemId,
    this.size,
    this.ice,
    this.sugar,
  });

  int get subtotal => price * quantity;

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    final menu = JsonUtils.asMap(
      JsonUtils.pick(json, ['menu', 'product']),
    );

    final name = JsonUtils.asString(
      JsonUtils.pick(json, ['name', 'menu_name', 'product_name', 'nama']) ??
          menu?['name'],
      fallback: 'Menu',
    );

    final image = JsonUtils.asNullableString(
      JsonUtils.pick(json, ['image_url', 'imageUrl', 'image', 'photo']) ??
          (menu == null
              ? null
              : JsonUtils.pick(menu, ['image_url', 'imageUrl', 'image'])),
    );

    return OrderItem(
      name: name,
      imagePath: ApiConfig.resolveImageUrl(image) ?? '',
      quantity: JsonUtils.asInt(
        JsonUtils.pick(json, ['quantity', 'qty', 'jumlah']),
        fallback: 1,
      ),
      price: JsonUtils.asInt(
        JsonUtils.pick(json, ['price', 'harga', 'unit_price']) ??
            menu?['price'],
      ),
      variant: _parseVariant(json),
      menuItemId: JsonUtils.asNullableString(
        JsonUtils.pick(json, ['menuItemId', 'menu_item_id']) ?? menu?['id'],
      ),
      size: JsonUtils.asNullableString(json['size']),
      ice: JsonUtils.asNullableString(json['ice']),
      sugar: JsonUtils.asNullableString(json['sugar']),
    );
  }

  static String? _parseVariant(Map<String, dynamic> json) {
    final direct = JsonUtils.asNullableString(
      JsonUtils.pick(json, ['variant', 'notes', 'note', 'catatan']),
    );
    if (direct != null) return direct;

    final parts = <String>[];
    final size = JsonUtils.asNullableString(json['size']);
    final ice = JsonUtils.asNullableString(json['ice']);
    final sugar = JsonUtils.asNullableString(json['sugar']);

    if (size != null) parts.add(size);
    if (ice != null) parts.add(OptionLabels.iceLabel(ice));
    if (sugar != null) parts.add(OptionLabels.sugarLabel(sugar));

    return parts.isEmpty ? null : parts.join('  |  ');
  }
}

/// Status pesanan. Urutan enum mengikuti alur pesanan.
enum OrderStatus {
  received,
  preparing,
  ready,
  completed,
  cancelled;

  /// Posisi pada progress bar (0 = diterima, 1 = diproses, 2 = siap diambil).
  /// Pesanan selesai/dibatalkan tidak lagi memakai progress bar.
  int get stepIndex => switch (this) {
        OrderStatus.received => 0,
        OrderStatus.preparing => 1,
        OrderStatus.ready => 2,
        OrderStatus.completed => 3,
        OrderStatus.cancelled => 3,
      };

  /// Sedang berlangsung: belum selesai dan belum dibatalkan.
  bool get isOngoing =>
      this == OrderStatus.received ||
      this == OrderStatus.preparing ||
      this == OrderStatus.ready;

  /// Membaca status dari backend (Indonesia maupun Inggris).
  static OrderStatus fromApi(String? raw) {
    final text = (raw ?? '')
        .toLowerCase()
        .replaceAll('_', ' ')
        .replaceAll('-', ' ')
        .trim();

    switch (text) {
      case 'diproses':
      case 'proses':
      case 'processing':
      case 'preparing':
        return OrderStatus.preparing;
      case 'siap':
      case 'siap diambil':
      case 'ready':
      case 'ready for pickup':
        return OrderStatus.ready;
      case 'selesai':
      case 'completed':
      case 'complete':
      case 'done':
        return OrderStatus.completed;
      case 'dibatalkan':
      case 'batal':
      case 'cancelled':
      case 'canceled':
        return OrderStatus.cancelled;
      case 'baru':
      case 'new':
      case 'pending':
      case 'received':
      default:
        return OrderStatus.received;
    }
  }
}

/// Metode pembayaran yang bisa dipilih customer.
enum PaymentMethod {
  qris('QRIS', 'QRIS'),
  cash('Tunai (Cash)', 'Tunai');

  const PaymentMethod(this.apiValue, this.label);

  /// Nilai yang dikirim/diterima backend.
  final String apiValue;

  /// Teks untuk tampilan.
  final String label;

  /// Nilai kosong dianggap QRIS (versi lama aplikasi hanya mengenal QRIS).
  static PaymentMethod fromApi(String? raw) {
    if (raw == null || raw.trim().isEmpty) return PaymentMethod.qris;
    return raw.toLowerCase().contains('qris')
        ? PaymentMethod.qris
        : PaymentMethod.cash;
  }
}

/// Satu-satunya model pesanan di aplikasi.
///
/// Immutable: untuk mengubah status gunakan [copyWith].
class OrderModel {
  /// ID di database (dipakai untuk cancel / detail).
  final String id;
  final String orderNumber;
  final DateTime date;
  final String orderType;
  final OrderStatus status;
  final List<OrderItem> items;

  /// Total akhir yang dibayar (sudah termasuk pajak).
  final int total;

  /// ID menu pada pesanan ini yang sudah diulas customer.
  final Set<String> reviewedItemIds;

  final PaymentMethod paymentMethod;

  /// true setelah pembayaran dikonfirmasi (QRIS berhasil / kasir menerima uang tunai).
  final bool paid;

  /// Uang tunai yang diterima kasir (hanya pembayaran tunai yang sudah lunas).
  final int? cashReceived;

  /// Kasir yang menangani pesanan (null sebelum diproses/dikonfirmasi).
  final String? cashierName;

  /// PPN dari server; null = dihitung dari subtotal.
  final int? tax;

  /// Isi QR QRIS dinamis. Hanya ada untuk pesanan QRIS yang belum lunas.
  final String? qrisPayload;

  const OrderModel({
    this.id = '',
    required this.orderNumber,
    required this.date,
    required this.orderType,
    required this.status,
    required this.items,
    required this.total,
    this.reviewedItemIds = const {},
    this.paymentMethod = PaymentMethod.qris,
    this.paid = false,
    this.cashReceived,
    this.cashierName,
    this.tax,
    this.qrisPayload,
  });

  /// Nomor pesanan untuk tampilan, selalu satu tanda "#" (server mengirim "#CP00001").
  String get orderLabel => '#${orderNumber.replaceFirst('#', '')}';

  /// PPN pesanan.
  int get taxAmount => tax ?? (subtotal * AppConstants.taxRate).round();

  /// Kembalian untuk pembayaran tunai yang sudah lunas.
  int get change {
    final received = cashReceived;
    if (received == null) return 0;
    return received > total ? received - total : 0;
  }

  /// Boleh dibatalkan customer: kasir belum memproses dan belum dibayar
  /// (aturan final ada di backend).
  bool get canCancel => status == OrderStatus.received && !paid;

  /// Masih menunggu pembayaran.
  bool get awaitingPayment => !paid && status != OrderStatus.cancelled;

  /// Produk yang masih bisa diulas: hanya pesanan selesai, tiap produk satu kali
  /// (produk yang sama dengan pilihan berbeda dihitung satu).
  List<OrderItem> get reviewableItems {
    if (status != OrderStatus.completed) return const [];
    final seen = <String>{};
    return [
      for (final item in items)
        if (item.menuItemId != null &&
            !reviewedItemIds.contains(item.menuItemId) &&
            seen.add(item.menuItemId!))
          item,
    ];
  }

  /// Pesanan selesai yang semua produknya sudah diulas.
  bool get isFullyReviewed =>
      status == OrderStatus.completed &&
      items.any((item) => item.menuItemId != null) &&
      reviewableItems.isEmpty;

  /// Jumlah harga semua item sebelum pajak.
  int get subtotal => items.fold(0, (sum, item) => sum + item.subtotal);

  bool get isOngoing => status.isOngoing;

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final id = JsonUtils.asString(JsonUtils.pick(json, ['id', 'order_id']));

    final itemsRaw = JsonUtils.asMapList(
      JsonUtils.pick(json, ['items', 'order_items', 'details']),
      wrapperKeys: const ['items'],
    );
    final items = itemsRaw.map(OrderItem.fromJson).toList();

    final computedSubtotal =
        items.fold<int>(0, (sum, item) => sum + item.subtotal);

    return OrderModel(
      id: id,
      orderNumber: JsonUtils.asString(
        JsonUtils.pick(json, [
          'order_number',
          'orderNumber',
          'invoice',
          'code',
          'no_pesanan',
        ]),
        fallback: id,
      ),
      date: JsonUtils.asDateTime(
            JsonUtils.pick(json, ['created_at', 'createdAt', 'date']),
          ) ??
          DateTime.now(),
      orderType: orderTypeLabel(
        JsonUtils.asNullableString(
          JsonUtils.pick(json, ['order_type', 'orderType', 'type']),
        ),
      ),
      status: OrderStatus.fromApi(
        JsonUtils.asNullableString(json['status']),
      ),
      items: items,
      total: JsonUtils.asInt(
        JsonUtils.pick(json, ['total', 'grand_total', 'total_amount']),
        fallback: computedSubtotal,
      ),
      reviewedItemIds: _parseIdSet(
        JsonUtils.pick(json, ['reviewedItemIds', 'reviewed_item_ids']),
      ),
      paymentMethod: PaymentMethod.fromApi(
        JsonUtils.asNullableString(
          JsonUtils.pick(json, ['paymentMethod', 'payment_method']),
        ),
      ),
      paid: JsonUtils.asNullableBool(json['paid']) ?? false,
      cashReceived: json['cashReceived'] == null
          ? null
          : JsonUtils.asInt(json['cashReceived']),
      cashierName: JsonUtils.asNullableString(
        JsonUtils.pick(json, ['cashierName', 'cashier_name']),
      ),
      tax: json['tax'] == null ? null : JsonUtils.asInt(json['tax']),
      qrisPayload: JsonUtils.asNullableString(json['qrisPayload']),
    );
  }

  static Set<String> _parseIdSet(dynamic raw) {
    if (raw is! List) return const {};
    return {
      for (final id in raw)
        if (JsonUtils.asNullableString(id) != null)
          JsonUtils.asNullableString(id)!,
    };
  }

  /// Label tampilan: "Pick Up" (backend: Take Away) / "Dine In".
  static String orderTypeLabel(String? raw) {
    final text = (raw ?? '').toLowerCase().replaceAll(RegExp(r'[_\-\s]'), '');
    if (text.contains('dine')) return 'Dine In';
    return 'Pick Up';
  }

  /// Nilai yang dikirim ke backend.
  static String orderTypeToApi(String label) {
    return label.toLowerCase().contains('dine') ? 'Dine In' : 'Take Away';
  }

  OrderModel copyWith({
    OrderStatus? status,
    Set<String>? reviewedItemIds,
    bool? paid,
    int? cashReceived,
    String? cashierName,
  }) {
    final nowPaid = paid ?? this.paid;
    return OrderModel(
      id: id,
      orderNumber: orderNumber,
      date: date,
      orderType: orderType,
      status: status ?? this.status,
      items: items,
      total: total,
      reviewedItemIds: reviewedItemIds ?? this.reviewedItemIds,
      paymentMethod: paymentMethod,
      paid: nowPaid,
      cashReceived: cashReceived ?? this.cashReceived,
      cashierName: cashierName ?? this.cashierName,
      tax: tax,
      // QR hanya berguna selama belum lunas dan belum dibatalkan.
      qrisPayload: (nowPaid || (status ?? this.status) == OrderStatus.cancelled)
          ? null
          : qrisPayload,
    );
  }
}
