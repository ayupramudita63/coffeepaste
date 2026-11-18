import 'package:coffee_paste/features/cart/cart_item_model.dart';
import 'package:coffee_paste/shared/models/product_model.dart';
import 'package:flutter_test/flutter_test.dart';

ProductModel _drink({int price = 22000, int? large = 26000}) => ProductModel(
      id: 'p1',
      name: 'Iced Latte',
      price: price,
      priceLarge: large,
      categoryId: 'minuman-kopi',
      categoryName: 'Coffee',
    );

void main() {
  group('harga Regular dan Large', () {
    test('fromJson membaca priceLarge dari server', () {
      final p = ProductModel.fromJson({
        'id': 2,
        'name': 'Iced Latte',
        'category': 'Coffee',
        'price': 22000,
        'priceLarge': 26000,
      });
      expect(p.priceLarge, 26000);
      expect(p.priceFor('Regular'), 22000);
      expect(p.priceFor('Large'), 26000);
    });

    test('makanan: priceLarge null, harga tetap', () {
      final p = ProductModel.fromJson({
        'id': 8,
        'name': 'Nasi Goreng',
        'category': 'Makanan',
        'price': 28000,
        'priceLarge': null,
      });
      expect(p.priceLarge, isNull);
      expect(p.priceFor(null), 28000);
    });

    test('server lama tanpa priceLarge memakai Regular + 4.000', () {
      final p = _drink(large: null);
      expect(p.largePrice, 26000);
      expect(p.priceFor('Large'), 26000);
    });

    test('harga Large kustom dipakai apa adanya', () {
      expect(_drink(large: 30000).priceFor('Large'), 30000);
    });

    test('subtotal keranjang mengikuti ukuran', () {
      final regular = CartItemModel(
        product: _drink(),
        size: 'Regular',
        quantity: 2,
      );
      final large = CartItemModel(
        product: _drink(),
        size: 'Large',
        quantity: 2,
      );
      expect(regular.unitPrice, 22000);
      expect(regular.subtotal, 44000);
      expect(large.unitPrice, 26000);
      expect(large.subtotal, 52000);
      expect(regular.key, isNot(large.key));
    });
  });
}
