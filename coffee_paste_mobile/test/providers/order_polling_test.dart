import 'dart:async';

import 'package:fake_async/fake_async.dart';

import 'package:coffee_paste/core/network/api_exception.dart';
import 'package:coffee_paste/features/order/models/order_model.dart';
import 'package:coffee_paste/features/order/models/product_review_draft.dart';
import 'package:coffee_paste/providers/order_provider.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/order_fixtures.dart';

void main() {
  const tick = OrderProvider.pollInterval;

  group('polling status pesanan', () {
    test('status terbaru dari server muncul tanpa tarik-untuk-refresh', () {
      fakeAsync((async) {
        final repo =
            FakeOrderRepository([sampleOrder('#CP1', OrderStatus.received)]);
        final provider = OrderProvider(repo);
        var notified = 0;
        provider.addListener(() => notified++);

        provider.loadOrders();
        async.flushMicrotasks();
        expect(provider.orders.single.status, OrderStatus.received);

        repo.next = [sampleOrder('#CP1', OrderStatus.preparing)];
        provider.startPolling();
        async.elapse(tick);
        async.flushMicrotasks();

        expect(provider.orders.single.status, OrderStatus.preparing);

        // Data sama -> tidak ada rebuild tambahan.
        final before = notified;
        async.elapse(tick);
        async.flushMicrotasks();
        expect(notified, before);

        provider.stopPolling();
      });
    });

    test('tidak memanggil server bila tidak ada pesanan berlangsung', () {
      fakeAsync((async) {
        final repo =
            FakeOrderRepository([sampleOrder('#CP1', OrderStatus.completed)]);
        final provider = OrderProvider(repo);

        provider.loadOrders();
        async.flushMicrotasks();
        expect(repo.fetchCount, 1);

        provider.startPolling();
        async.elapse(tick * 5);
        async.flushMicrotasks();

        expect(repo.fetchCount, 1);
        provider.stopPolling();
      });
    });

    test('stopPolling menghentikan pengecekan', () {
      fakeAsync((async) {
        final repo =
            FakeOrderRepository([sampleOrder('#CP1', OrderStatus.received)]);
        final provider = OrderProvider(repo);
        provider.loadOrders();
        async.flushMicrotasks();

        provider.startPolling();
        async.elapse(tick);
        async.flushMicrotasks();
        final calls = repo.fetchCount;
        expect(calls, greaterThan(1));

        provider.stopPolling();
        expect(provider.isPolling, isFalse);
        async.elapse(tick * 5);
        async.flushMicrotasks();
        expect(repo.fetchCount, calls);
      });
    });

    test('startPolling berulang tidak membuat timer ganda', () {
      fakeAsync((async) {
        final repo =
            FakeOrderRepository([sampleOrder('#CP1', OrderStatus.received)]);
        final provider = OrderProvider(repo);
        provider.loadOrders();
        async.flushMicrotasks();
        final base = repo.fetchCount;

        provider.startPolling();
        provider.startPolling();
        provider.startPolling();
        async.elapse(tick);
        async.flushMicrotasks();

        expect(repo.fetchCount, base + 1);
        provider.stopPolling();
      });
    });

    test('jaringan putus: data lama tetap, tidak error', () {
      fakeAsync((async) {
        final repo =
            FakeOrderRepository([sampleOrder('#CP1', OrderStatus.received)]);
        final provider = OrderProvider(repo);
        provider.loadOrders();
        async.flushMicrotasks();

        repo.failFetch = true;
        provider.startPolling();
        async.elapse(tick);
        async.flushMicrotasks();

        expect(provider.orders.single.status, OrderStatus.received);
        expect(provider.isError, isFalse);

        // Setelah pulih, status baru ikut masuk.
        repo
          ..failFetch = false
          ..next = [sampleOrder('#CP1', OrderStatus.ready)];
        async.elapse(tick);
        async.flushMicrotasks();
        expect(provider.orders.single.status, OrderStatus.ready);

        provider.stopPolling();
      });
    });

    test('hasil fetch lama setelah logout tidak menimpa data kosong', () {
      fakeAsync((async) {
        final repo =
            FakeOrderRepository([sampleOrder('#CP1', OrderStatus.received)]);
        final provider = OrderProvider(repo);
        provider.loadOrders();
        async.flushMicrotasks();

        repo.gate = Completer<List<OrderModel>>();
        provider.refreshSilently();
        provider.clear(); // logout saat fetch masih berjalan
        repo.gate!.complete([sampleOrder('#CP9', OrderStatus.preparing)]);
        async.flushMicrotasks();

        expect(provider.orders, isEmpty);
      });
    });
  });

  group('pemicu notifikasi', () {
    test('memanggil listener dengan data lama & baru saat status berubah', () {
      fakeAsync((async) {
        final repo =
            FakeOrderRepository([sampleOrder('#CP1', OrderStatus.received)]);
        final seen = <String>[];
        final provider = OrderProvider(
          repo,
          onOrdersChanged: (previous, next) => seen.add(
              '${previous.map((o) => o.status.name).join(',')}->'
              '${next.map((o) => o.status.name).join(',')}'),
        );

        // Muat awal: daftar lama masih kosong (jadi baseline, bukan perubahan).
        provider.loadOrders();
        async.flushMicrotasks();
        expect(seen, ['->received']);

        repo.next = [sampleOrder('#CP1', OrderStatus.preparing)];
        provider.refreshSilently();
        async.flushMicrotasks();
        expect(seen.last, 'received->preparing');

        // Data sama -> listener tidak dipanggil lagi.
        final calls = seen.length;
        provider.refreshSilently();
        async.flushMicrotasks();
        expect(seen, hasLength(calls));

        // Perubahan lokal (membatalkan) bukan datang dari server: tidak memicu.
        provider.cancelOrder('#CP1').then((_) {});
        async.flushMicrotasks();
        expect(seen, hasLength(calls));
      });
    });
  });

  group('ulasan per produk', () {
    test('berhasil: produk yang diulas tidak muncul lagi di daftar ulasan', () {
      fakeAsync((async) {
        final order = sampleOrder('#CP1', OrderStatus.completed);
        final repo = FakeOrderRepository([order]);
        final provider = OrderProvider(repo);
        provider.loadOrders();
        async.flushMicrotasks();
        expect(provider.orders.single.reviewableItems, hasLength(2));

        bool? ok;
        provider
            .submitReviews(
              provider.orders.single,
              const [
                ProductReviewDraft(
                    menuItemId: 'p1', rating: 5, comment: 'Enak'),
              ],
            )
            .then((value) => ok = value);
        async.flushMicrotasks();

        expect(ok, isTrue);
        expect(repo.submitted.single.menuItemId, 'p1');
        expect(provider.orders.single.reviewedItemIds, {'p1'});
        expect(
          provider.orders.single.reviewableItems.map((i) => i.menuItemId),
          ['p2'],
        );
      });
    });

    test('gagal: pesan server tersedia dan status tidak berubah', () {
      fakeAsync((async) {
        final repo = FakeOrderRepository(
            [sampleOrder('#CP1', OrderStatus.completed)])
          ..submitError = const ApiException(
            'Produk ini sudah pernah diulas pada pesanan ini',
            statusCode: 422,
          );
        final provider = OrderProvider(repo);
        provider.loadOrders();
        async.flushMicrotasks();

        bool? ok;
        provider
            .submitReviews(
              provider.orders.single,
              const [ProductReviewDraft(menuItemId: 'p1', rating: 4)],
            )
            .then((value) => ok = value);
        async.flushMicrotasks();

        expect(ok, isFalse);
        expect(provider.submitError,
            'Produk ini sudah pernah diulas pada pesanan ini');
        expect(provider.orders.single.reviewedItemIds, isEmpty);
        expect(provider.isSubmitting, isFalse);
      });
    });
  });

  group('OrderModel', () {
    test('pesanan belum selesai atau dibatalkan tidak bisa diulas', () {
      expect(sampleOrder('#1', OrderStatus.preparing).reviewableItems, isEmpty);
      expect(sampleOrder('#1', OrderStatus.cancelled).reviewableItems, isEmpty);
    });

    test('isFullyReviewed hanya true bila semua produk sudah diulas', () {
      expect(sampleOrder('#1', OrderStatus.completed).isFullyReviewed, isFalse);
      expect(
        sampleOrder('#1', OrderStatus.completed, reviewed: {'p1'})
            .isFullyReviewed,
        isFalse,
      );
      expect(
        sampleOrder('#1', OrderStatus.completed, reviewed: {'p1', 'p2'})
            .isFullyReviewed,
        isTrue,
      );
      expect(
        sampleOrder('#1', OrderStatus.cancelled, reviewed: {'p1', 'p2'})
            .isFullyReviewed,
        isFalse,
      );
    });
  });
}
