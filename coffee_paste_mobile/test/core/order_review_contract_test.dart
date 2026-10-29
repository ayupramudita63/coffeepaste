import 'package:coffee_paste/core/network/api_endpoints.dart';
import 'package:coffee_paste/core/utils/option_labels.dart';
import 'package:coffee_paste/features/order/models/order_model.dart';
import 'package:coffee_paste/features/order/models/product_review_draft.dart';
import 'package:coffee_paste/shared/models/product_model.dart';
import 'package:flutter_test/flutter_test.dart';

/// Format JSON backend untuk ulasan per produk dan "Pesan Lagi".
void main() {
  test('ID pesanan "#CP00001" di-encode pada URL ulasan', () {
    expect(
      ApiEndpoints.orderReviews('#CP00001'),
      '/orders/%23CP00001/reviews',
    );
  });

  test('body ulasan memakai menuItemId angka dan komentar dipangkas', () {
    const draft =
        ProductReviewDraft(menuItemId: '3', rating: 5, comment: '  Enak!  ');
    expect(draft.toJson(), {'menuItemId': 3, 'rating': 5, 'comment': 'Enak!'});

    const ratingOnly = ProductReviewDraft(menuItemId: '4', rating: 4);
    expect(ratingOnly.toJson()['comment'], '');
  });

  test('label es/gula backend -> label keranjang', () {
    expect(OptionLabels.cartIce('Normal'), 'Normal');
    expect(OptionLabels.cartIce('Less'), 'Less Ice');
    expect(OptionLabels.cartIce('No'), 'No Ice');
    expect(OptionLabels.cartSugar('Less'), 'Less Sugar');
    expect(OptionLabels.cartSugar('No'), 'No Sugar');
    expect(OptionLabels.cartSugar(null), isNull);
    // Dua arah konsisten dengan yang dikirim saat checkout.
    for (final raw in ['Normal', 'Less', 'No']) {
      expect(OptionLabels.toApiLevel(OptionLabels.cartIce(raw)), raw);
      expect(OptionLabels.toApiLevel(OptionLabels.cartSugar(raw)), raw);
    }
  });

  test('pesanan dari GET /api/orders memuat menuItemId dan reviewedItemIds', () {
    final o = OrderModel.fromJson({
      'id': '#CP00009',
      'date': '2026-10-09T10:15:00',
      'orderType': 'Dine In',
      'status': 'selesai',
      'total': 54390,
      'reviewedItemIds': [3],
      'items': [
        {
          'menuItemId': 3,
          'name': 'Latte',
          'qty': 1,
          'price': 22000,
          'size': 'Regular',
          'ice': 'No',
          'sugar': 'Less',
        },
        {'menuItemId': 5, 'name': 'Roti', 'qty': 2, 'price': 9000},
      ],
    });

    expect(o.status, OrderStatus.completed);
    expect(o.items.first.menuItemId, '3');
    expect(o.items.first.ice, 'No');
    expect(o.items.first.sugar, 'Less');
    expect(o.items.last.ice, isNull);
    expect(o.reviewedItemIds, {'3'});
    expect(o.reviewableItems.map((i) => i.menuItemId), ['5']);
  });

  test('pesanan lama tanpa reviewedItemIds tetap terbaca', () {
    final o = OrderModel.fromJson({
      'id': '#CP00001',
      'status': 'selesai',
      'items': [
        {'name': 'Latte', 'qty': 1, 'price': 22000},
      ],
    });
    expect(o.reviewedItemIds, isEmpty);
    expect(o.reviewableItems, isEmpty); // tanpa menuItemId tidak bisa diulas
  });

  test('menu dari GET /api/menu memuat rating dan ratingCount', () {
    final p = ProductModel.fromJson({
      'id': 3,
      'name': 'Latte',
      'category': 'Coffee',
      'categoryId': 'minuman-kopi',
      'price': 25000,
      'status': 'tersedia',
      'rating': 4.5,
      'ratingCount': 12,
    });
    expect(p.rating, 4.5);
    expect(p.ratingCount, 12);

    final unrated = ProductModel.fromJson({
      'id': 4,
      'name': 'Roti',
      'category': 'Makanan',
      'price': 10000,
      'rating': 0,
      'ratingCount': 0,
    });
    expect(unrated.ratingCount, 0);
  });
}
