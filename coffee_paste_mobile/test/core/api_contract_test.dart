import 'package:coffee_paste/core/network/api_endpoints.dart';
import 'package:coffee_paste/core/utils/option_labels.dart';
import 'package:coffee_paste/features/order/models/order_model.dart';
import 'package:coffee_paste/shared/models/product_model.dart';
import 'package:flutter_test/flutter_test.dart';

/// Memastikan format JSON backend Go terbaca benar oleh aplikasi.
void main() {
  test('label pilihan layar <-> nilai backend', () {
    expect(OptionLabels.toApiLevel('Less Ice'), 'Less');
    expect(OptionLabels.toApiLevel('No Sugar'), 'No');
    expect(OptionLabels.toApiLevel('Normal'), 'Normal');
    expect(OptionLabels.toApiLevel(null), isNull);
    expect(OptionLabels.iceLabel('Less'), 'Less Ice');
    expect(OptionLabels.sugarLabel('No'), 'No Sugar');
  });

  test('tipe pesanan dikirim sebagai Dine In / Take Away', () {
    expect(OrderModel.orderTypeToApi('Pick Up'), 'Take Away');
    expect(OrderModel.orderTypeToApi('Dine In'), 'Dine In');
    expect(OrderModel.orderTypeLabel('Take Away'), 'Pick Up');
  });

  test('ID pesanan "#CP00001" di-encode pada URL batal', () {
    expect(ApiEndpoints.cancelOrder('#CP00001'), '/orders/%23CP00001/cancel');
  });

  test('menu dari GET /api/menu terbaca', () {
    final p = ProductModel.fromJson({
      'id': 3,
      'name': 'Latte',
      'category': 'Coffee',
      'categoryId': 'minuman-kopi',
      'price': 25000,
      'status': 'tersedia',
      'image': null,
      'description': 'Espresso dan susu',
    });
    expect(p.id, '3');
    expect(p.price, 25000);
    expect(p.isAvailable, isTrue);
    expect(p.categoryId, 'minuman-kopi');
    expect(p.isDrink, isTrue);
  });

  test('menu habis dan makanan', () {
    final p = ProductModel.fromJson({
      'id': 9,
      'name': 'Roti',
      'category': 'Makanan',
      'categoryId': 'makanan',
      'price': 15000,
      'status': 'habis',
    });
    expect(p.isAvailable, isFalse);
    expect(p.isDrink, isFalse);
  });

  test('pesanan dari GET /api/orders terbaca', () {
    final o = OrderModel.fromJson({
      'id': '#CP00007',
      'date': '2026-10-09T10:15:00',
      'orderType': 'Take Away',
      'status': 'menunggu',
      'subtotal': 49000,
      'tax': 5390,
      'total': 54390,
      'items': [
        {
          'name': 'Latte',
          'qty': 2,
          'price': 22000,
          'size': 'Large',
          'ice': 'Less',
          'sugar': 'Normal',
          'image': '/uploads/menu/a.jpg',
        },
      ],
    });
    expect(o.id, '#CP00007');
    expect(o.orderNumber, '#CP00007');
    expect(o.orderType, 'Pick Up');
    expect(o.status, OrderStatus.received);
    expect(o.isOngoing, isTrue);
    expect(o.total, 54390);
    expect(o.items.single.quantity, 2);
    expect(o.items.single.variant, 'Large  |  Less Ice  |  Normal Sugar');
  });
}
