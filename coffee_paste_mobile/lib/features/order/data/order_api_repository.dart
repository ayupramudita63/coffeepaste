import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/utils/json_utils.dart';
import '../../../core/utils/option_labels.dart';
import '../../cart/cart_item_model.dart';
import '../models/order_model.dart';
import '../models/product_review_draft.dart';
import 'order_repository.dart';

class ApiOrderRepository implements OrderRepository {
  final ApiClient _client;

  ApiOrderRepository(this._client);

  /// Pesanan milik customer yang sedang login. Terbaru di atas.
  @override
  Future<List<OrderModel>> fetchOrders() async {
    final body = await _client.get(ApiEndpoints.orders);

    final orders = JsonUtils.asMapList(
      body,
      wrapperKeys: const ['items', 'orders'],
    ).map(OrderModel.fromJson).toList();

    orders.sort((a, b) => b.date.compareTo(a.date));
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
    final body = await _client.post(
      ApiEndpoints.orders,
      // Harga, subtotal, PPN, dan total sengaja tidak dikirim: server
      // menghitungnya sendiri dari database supaya tidak bisa dimanipulasi.
      data: {
        'orderType': OrderModel.orderTypeToApi(orderType),
        'paymentMethod': paymentMethod.apiValue,
        'items': items.map(_itemToJson).toList(),
      },
    );

    final map = JsonUtils.asMap(body);
    if (map == null) {
      throw const ApiException('Respons pesanan dari server tidak valid.');
    }
    return OrderModel.fromJson(map);
  }

  @override
  Future<void> cancelOrder(String orderId) async {
    await _client.post(ApiEndpoints.cancelOrder(orderId));
  }

  @override
  Future<void> submitReviews(
    String orderId,
    List<ProductReviewDraft> reviews,
  ) async {
    await _client.post(
      ApiEndpoints.orderReviews(orderId),
      data: {'reviews': reviews.map((review) => review.toJson()).toList()},
    );
  }

  Map<String, dynamic> _itemToJson(CartItemModel item) {
    final id = item.product.id;

    return {
      'menuItemId': int.tryParse(id) ?? id,
      'qty': item.quantity,
      'size': item.size,
      'ice': OptionLabels.toApiLevel(item.ice),
      'sugar': OptionLabels.toApiLevel(item.sugar),
    };
  }
}
