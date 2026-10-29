import 'dart:async';

import 'package:coffee_paste/core/network/api_exception.dart';
import 'package:coffee_paste/features/cart/cart_item_model.dart';
import 'package:coffee_paste/features/order/data/order_repository.dart';
import 'package:coffee_paste/features/order/models/order_model.dart';
import 'package:coffee_paste/features/order/models/product_review_draft.dart';

/// Pesanan contoh: Latte (p1, minuman) dan Roti (p2, makanan).
OrderModel sampleOrder(
  String id,
  OrderStatus status, {
  Set<String> reviewed = const {},
  bool paid = false,
}) {
  return OrderModel(
    id: id,
    orderNumber: id,
    date: DateTime(2026, 10, 10, 9, 30),
    orderType: 'Pick Up',
    status: status,
    total: 40000,
    reviewedItemIds: reviewed,
    paid: paid,
    items: const [
      OrderItem(
        name: 'Latte',
        imagePath: '',
        quantity: 1,
        price: 22000,
        menuItemId: 'p1',
        size: 'Regular',
        ice: 'Normal',
        sugar: 'Normal',
      ),
      OrderItem(
        name: 'Roti',
        imagePath: '',
        quantity: 2,
        price: 9000,
        menuItemId: 'p2',
      ),
    ],
  );
}

/// Repository yang bisa diatur isinya, dihitung pemanggilannya, dan ditahan
/// (lewat [gate]) untuk menguji kondisi balapan.
class FakeOrderRepository implements OrderRepository {
  List<OrderModel> next;
  int fetchCount = 0;
  bool failFetch = false;
  Completer<List<OrderModel>>? gate;

  ApiException? submitError;
  final List<ProductReviewDraft> submitted = [];

  FakeOrderRepository(this.next);

  @override
  Future<List<OrderModel>> fetchOrders() async {
    fetchCount++;
    if (failFetch) throw Exception('offline');
    if (gate != null) return gate!.future;
    return next;
  }

  @override
  Future<void> submitReviews(
    String orderId,
    List<ProductReviewDraft> reviews,
  ) async {
    if (submitError != null) throw submitError!;
    submitted.addAll(reviews);
  }

  @override
  Future<OrderModel> createOrder({
    required List<CartItemModel> items,
    required String orderType,
    required PaymentMethod paymentMethod,
    required int subtotal,
    required int tax,
    required int total,
  }) =>
      throw UnimplementedError();

  @override
  Future<void> cancelOrder(String orderId) => throw UnimplementedError();
}
