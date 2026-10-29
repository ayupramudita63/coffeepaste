import '../../cart/cart_item_model.dart';
import '../models/order_model.dart';
import '../models/product_review_draft.dart';

/// Kontrak data pesanan (lihat catatan di MenuRepository).
abstract class OrderRepository {
  /// Pesanan customer yang sedang login, terbaru di atas.
  Future<List<OrderModel>> fetchOrders();

  Future<OrderModel> createOrder({
    required List<CartItemModel> items,
    required String orderType,
    required PaymentMethod paymentMethod,
    required int subtotal,
    required int tax,
    required int total,
  });

  Future<void> cancelOrder(String orderId);

  /// Kirim ulasan per produk untuk pesanan yang sudah selesai.
  /// Melempar ApiException bila ditolak (mis. produk sudah pernah diulas).
  Future<void> submitReviews(String orderId, List<ProductReviewDraft> reviews);
}
