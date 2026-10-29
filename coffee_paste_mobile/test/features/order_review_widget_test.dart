import 'package:coffee_paste/features/order/data/order_mock_repository.dart';
import 'package:coffee_paste/features/order/models/order_model.dart';
import 'package:coffee_paste/features/order/widgets/history_order_card.dart';
import 'package:coffee_paste/features/order/widgets/review_order_sheet.dart';
import 'package:coffee_paste/providers/order_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import '../support/order_fixtures.dart';

Widget _card(OrderModel order, {VoidCallback? onReview, VoidCallback? onReorder}) {
  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        child: HistoryOrderCard(
          order: order,
          onReview: onReview,
          onReorder: onReorder,
        ),
      ),
    ),
  );
}

void main() {
  group('HistoryOrderCard', () {
    testWidgets('selesai & belum diulas: ada Beri Ulasan dan Pesan Lagi',
        (tester) async {
      var reviewed = 0;
      var reordered = 0;
      await tester.pumpWidget(_card(
        sampleOrder('#CP1', OrderStatus.completed),
        onReview: () => reviewed++,
        onReorder: () => reordered++,
      ));

      await tester.ensureVisible(find.byKey(const Key('review-button')));
      await tester.tap(find.byKey(const Key('review-button')));
      await tester.ensureVisible(find.byKey(const Key('reorder-button')));
      await tester.tap(find.byKey(const Key('reorder-button')));

      expect(reviewed, 1);
      expect(reordered, 1);
      expect(find.byKey(const Key('reviewed-label')), findsNothing);
    });

    testWidgets('semua produk sudah diulas: tampil label, tombol ulasan hilang',
        (tester) async {
      await tester.pumpWidget(_card(
        sampleOrder('#CP1', OrderStatus.completed, reviewed: {'p1', 'p2'}),
      ));

      expect(find.byKey(const Key('reviewed-label')), findsOneWidget);
      expect(find.byKey(const Key('review-button')), findsNothing);
      expect(find.byKey(const Key('reorder-button')), findsOneWidget);
    });

    testWidgets('dibatalkan: hanya Pesan Lagi', (tester) async {
      await tester.pumpWidget(_card(sampleOrder('#CP1', OrderStatus.cancelled)));

      expect(find.byKey(const Key('review-button')), findsNothing);
      expect(find.byKey(const Key('reviewed-label')), findsNothing);
      expect(find.byKey(const Key('reorder-button')), findsOneWidget);
    });
  });

  group('ReviewOrderSheet', () {
    testWidgets('kirim aktif setelah memberi bintang, lalu sheet menutup',
        (tester) async {
      final provider = OrderProvider(MockOrderRepository(latency: Duration.zero));
      await tester.runAsync(provider.loadOrders);
      final order = provider.orders
          .firstWhere((o) => o.status == OrderStatus.completed);
      expect(order.reviewableItems, isNotEmpty);
      final firstId = order.reviewableItems.first.menuItemId!;

      await tester.pumpWidget(
        ChangeNotifierProvider<OrderProvider>.value(
          value: provider,
          child: MaterialApp(
            home: Builder(
              builder: (context) => Scaffold(
                body: Center(
                  child: ElevatedButton(
                    onPressed: () => ReviewOrderSheet.show(context, order),
                    child: const Text('Buka'),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Buka'));
      await tester.pumpAndSettle();

      final submit = find.byKey(const Key('review-submit'));
      expect(tester.widget<ElevatedButton>(submit).onPressed, isNull);

      await tester.tap(find.byKey(Key('star-$firstId-5')));
      await tester.pump();
      expect(tester.widget<ElevatedButton>(submit).onPressed, isNotNull);

      await tester.enterText(find.byKey(Key('comment-$firstId')), 'Mantap');
      await tester.tap(submit);
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('review-submit')), findsNothing);
      final updated = provider.orders.firstWhere((o) => o.id == order.id);
      expect(updated.reviewedItemIds, contains(firstId));
    });
  });
}
