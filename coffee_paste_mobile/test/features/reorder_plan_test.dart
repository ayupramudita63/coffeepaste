import 'package:coffee_paste/features/order/models/order_model.dart';
import 'package:coffee_paste/features/order/reorder_plan.dart';
import 'package:coffee_paste/shared/models/product_model.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/order_fixtures.dart';

ProductModel _drink({int price = 25000, bool available = true}) => ProductModel(
      id: 'p1',
      name: 'Latte',
      price: price,
      categoryId: 'minuman-kopi',
      categoryName: 'Coffee',
      isAvailable: available,
    );

ProductModel _food({bool available = true}) => ProductModel(
      id: 'p2',
      name: 'Roti',
      price: 10000,
      categoryId: 'makanan',
      categoryName: 'Makanan',
      isAvailable: available,
    );

void main() {
  test('pilihan es/gula/ukuran dan jumlah disalin; harga dari menu terbaru', () {
    final order = OrderModel(
      id: '#CP1',
      orderNumber: '#CP1',
      date: DateTime(2026, 10, 10),
      orderType: 'Dine In',
      status: OrderStatus.completed,
      total: 0,
      items: const [
        OrderItem(
          name: 'Latte',
          imagePath: '',
          quantity: 2,
          price: 22000, // harga lama
          menuItemId: 'p1',
          size: 'Large',
          ice: 'Less',
          sugar: 'No',
        ),
        OrderItem(
          name: 'Roti',
          imagePath: '',
          quantity: 3,
          price: 9000,
          menuItemId: 'p2',
        ),
      ],
    );

    final plan = ReorderPlan.from(order, [_drink(), _food()]);

    expect(plan.unavailableNames, isEmpty);
    expect(plan.lines, hasLength(2));

    final latte = plan.lines[0];
    expect(latte.product.price, 25000);
    expect(latte.quantity, 2);
    expect(latte.size, 'Large');
    expect(latte.ice, 'Less Ice');
    expect(latte.sugar, 'No Sugar');

    final roti = plan.lines[1];
    expect(roti.quantity, 3);
    expect(roti.ice, isNull);
    expect(roti.sugar, isNull);
    expect(roti.size, isNull);
  });

  test('menu habis atau sudah dihapus dilewati dan namanya dilaporkan', () {
    final order = sampleOrder('#CP1', OrderStatus.completed);

    final soldOut = ReorderPlan.from(order, [_drink(), _food(available: false)]);
    expect(soldOut.lines.map((l) => l.product.id), ['p1']);
    expect(soldOut.unavailableNames, ['Roti']);

    final removed = ReorderPlan.from(order, [_drink()]);
    expect(removed.lines.map((l) => l.product.id), ['p1']);
    expect(removed.unavailableNames, ['Roti']);

    final none = ReorderPlan.from(order, const []);
    expect(none.lines, isEmpty);
    expect(none.unavailableNames, ['Latte', 'Roti']);
  });

  test('item tanpa menuItemId (data lama) dilewati', () {
    final order = OrderModel(
      id: '#CP1',
      orderNumber: '#CP1',
      date: DateTime(2026, 10, 10),
      orderType: 'Pick Up',
      status: OrderStatus.completed,
      total: 0,
      items: const [
        OrderItem(name: 'Menu Lama', imagePath: '', quantity: 1, price: 1000),
      ],
    );

    final plan = ReorderPlan.from(order, [_drink(), _food()]);
    expect(plan.lines, isEmpty);
    expect(plan.unavailableNames, ['Menu Lama']);
  });

  test('minuman tanpa pilihan tersimpan memakai default Normal/Regular', () {
    final order = OrderModel(
      id: '#CP1',
      orderNumber: '#CP1',
      date: DateTime(2026, 10, 10),
      orderType: 'Pick Up',
      status: OrderStatus.completed,
      total: 0,
      items: const [
        OrderItem(
          name: 'Latte',
          imagePath: '',
          quantity: 1,
          price: 22000,
          menuItemId: 'p1',
        ),
      ],
    );

    final line = ReorderPlan.from(order, [_drink()]).lines.single;
    expect(line.ice, 'Normal');
    expect(line.sugar, 'Normal');
    expect(line.size, 'Regular');
  });
}
