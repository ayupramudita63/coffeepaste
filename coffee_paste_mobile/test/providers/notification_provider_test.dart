import 'package:coffee_paste/core/notifications/notification_service.dart';
import 'package:coffee_paste/features/order/models/order_model.dart';
import 'package:coffee_paste/providers/notification_provider.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fakes.dart';
import '../support/order_fixtures.dart';

void main() {
  late FakeNotificationService service;
  late InMemoryNotificationPreferenceStore store;
  late NotificationProvider provider;

  setUp(() {
    service = FakeNotificationService();
    store = InMemoryNotificationPreferenceStore();
    provider = NotificationProvider(service: service, store: store);
  });

  /// Biarkan pemanggilan notifikasi (yang tidak di-await provider) selesai.
  Future<void> settle() async => Future<void>.delayed(Duration.zero);

  group('preferensi notifikasi', () {
    test('bawaan menyala, sakelar menulis ke penyimpanan, dan bertahan', () async {
      await provider.ensureStarted();
      expect(provider.isLoaded, isTrue);
      expect(provider.orderEnabled, isTrue);
      expect(provider.paymentEnabled, isTrue);

      await provider.setOrderEnabled(false);
      expect(provider.orderEnabled, isFalse);
      expect(await store.readBool(NotificationProvider.orderKey), isFalse);

      // Instance baru (mis. setelah aplikasi dibuka ulang) memakai pilihan sama.
      final reopened = NotificationProvider(
        service: FakeNotificationService(),
        store: store,
      );
      await reopened.ensureStarted();
      expect(reopened.orderEnabled, isFalse);
      expect(reopened.paymentEnabled, isTrue);
    });

    test('menyalakan sakelar kembali meminta izin sistem', () async {
      await provider.ensureStarted();
      expect(service.permissionRequests, 0);

      await provider.setOrderEnabled(false);
      expect(service.permissionRequests, 0);

      await provider.setOrderEnabled(true);
      expect(service.permissionRequests, 1);
    });

    test('izin sistem ditolak: systemEnabled false', () async {
      service.systemEnabled = false;
      await provider.ensureStarted();
      expect(provider.systemEnabled, isFalse);

      service.permissionGranted = false;
      expect(await provider.requestPermission(), isFalse);
      expect(provider.systemEnabled, isFalse);

      service.permissionGranted = true;
      expect(await provider.requestPermission(), isTrue);
      expect(provider.systemEnabled, isTrue);
    });

    test('service disiapkan sekali untuk beberapa pemanggilan', () async {
      await Future.wait([provider.ensureStarted(), provider.ensureStarted()]);
      await provider.ensureStarted();
      expect(service.initCalls, 1);
    });
  });

  group('perubahan pesanan memicu notifikasi', () {
    Future<void> load() => provider.ensureStarted();

    test('status berubah -> notifikasi pesanan dengan payload pesanan', () async {
      await load();
      provider.onOrdersChanged(
        [sampleOrder('#CP1', OrderStatus.received)],
        [sampleOrder('#CP1', OrderStatus.ready)],
      );
      await settle();

      expect(service.shown, hasLength(1));
      final shown = service.shown.single;
      expect(shown.category, NotificationCategory.order);
      expect(shown.title, 'Pesanan siap diambil');
      expect(shown.payload, 'order:#CP1');
    });

    test('pembayaran lunas -> notifikasi pembayaran', () async {
      await load();
      provider.onOrdersChanged(
        [sampleOrder('#CP1', OrderStatus.received, paid: false)],
        [sampleOrder('#CP1', OrderStatus.received, paid: true)],
      );
      await settle();

      expect(service.shown, hasLength(1));
      expect(service.shown.single.category, NotificationCategory.payment);
      expect(service.shown.single.title, 'Pembayaran lunas');
    });

    test('status dan pembayaran berbarengan -> kirim dua notifikasi', () async {
      await load();
      provider.onOrdersChanged(
        [sampleOrder('#CP1', OrderStatus.received)],
        [sampleOrder('#CP1', OrderStatus.preparing, paid: true)],
      );
      await settle();

      expect(
        service.shown.map((n) => n.category),
        containsAll([
          NotificationCategory.payment,
          NotificationCategory.order,
        ]),
      );
    });

    test('muat awal (daftar lama kosong) tidak mengirim notifikasi', () async {
      await load();
      provider.onOrdersChanged(
        const [],
        [sampleOrder('#CP1', OrderStatus.preparing, paid: true)],
      );
      await settle();

      expect(service.shown, isEmpty);
    });

    test('data tanpa perubahan atau pesanan baru tidak memberi tahu', () async {
      await load();
      final orders = [sampleOrder('#CP1', OrderStatus.preparing)];

      provider.onOrdersChanged(orders, orders);
      provider.onOrdersChanged(orders, [sampleOrder('#CP9', OrderStatus.ready)]);
      await settle();

      expect(service.shown, isEmpty);
    });

    test('sakelar mati menahan notifikasi sesuai katanya', () async {
      await load();
      await provider.setOrderEnabled(false);
      await provider.setPaymentEnabled(false);

      provider.onOrdersChanged(
        [sampleOrder('#CP1', OrderStatus.received)],
        [sampleOrder('#CP1', OrderStatus.ready, paid: true)],
      );
      await settle();

      expect(service.shown, isEmpty);
    });

    test('sakelar mati hanya menahan jenisnya', () async {
      await load();
      await provider.setOrderEnabled(false);

      provider.onOrdersChanged(
        [sampleOrder('#CP1', OrderStatus.received)],
        [sampleOrder('#CP1', OrderStatus.ready, paid: true)],
      );
      await settle();

      expect(service.shown, hasLength(1));
      expect(service.shown.single.category, NotificationCategory.payment);
    });

    test('preferensi belum dibaca: tidak ada notifikasi nebak-nebak', () async {
      provider.onOrdersChanged(
        [sampleOrder('#CP1', OrderStatus.received)],
        [sampleOrder('#CP1', OrderStatus.ready)],
      );
      await settle();

      expect(service.shown, isEmpty);
      expect(provider.isLoaded, isFalse);
    });
  });

  group('notifikasi percobaan', () {
    test('kirim satu notifikasi selama ada sakelar yang menyala', () async {
      await provider.sendTestNotification();

      expect(service.shown, hasLength(1));
      expect(service.shown.single.title, 'Notifikasi percobaan');
    });

    test('semua sakelar mati: tidak ada notifikasi', () async {
      await provider.ensureStarted();
      await provider.setOrderEnabled(false);
      await provider.setPaymentEnabled(false);
      await provider.sendTestNotification();

      expect(service.shown, isEmpty);
    });

    test('izin ditolak: coba minta izin dulu, tetap tidak dikirim', () async {
      service.permissionGranted = false;
      service.systemEnabled = false;

      await provider.sendTestNotification();

      expect(service.permissionRequests, greaterThanOrEqualTo(1));
      expect(service.shown, isEmpty);
      expect(provider.systemEnabled, isFalse);
    });
  });
}
