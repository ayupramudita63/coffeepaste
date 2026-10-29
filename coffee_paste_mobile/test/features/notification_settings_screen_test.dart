import 'package:coffee_paste/features/account/notification_settings_screen.dart';
import 'package:coffee_paste/providers/notification_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../support/fakes.dart';

void main() {
  late FakeNotificationService service;
  late InMemoryNotificationPreferenceStore store;
  late NotificationProvider provider;

  setUp(() {
    GoogleFonts.config.allowRuntimeFetching = false;
    service = FakeNotificationService();
    store = InMemoryNotificationPreferenceStore();
    provider = NotificationProvider(service: service, store: store);
  });

  Future<void> pumpScreen(WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider<NotificationProvider>.value(
        value: provider,
        child: const MaterialApp(home: NotificationSettingsScreen()),
      ),
    );
    // Satu pump tambahan supaya hasil baca preferensi tampil.
    await tester.pump(const Duration(milliseconds: 50));
  }

  Switch switchOf(WidgetTester tester, Key key) =>
      tester.widget<Switch>(find.byKey(key));

  group('NotificationSettingsScreen', () {
    testWidgets('memuat pilihan tersimpan lalu menyimpan perubahan',
        (tester) async {
      await store.writeBool(NotificationProvider.orderKey, false);
      await pumpScreen(tester);

      expect(
        switchOf(tester, const Key('order-notifications-switch')).value,
        isFalse,
      );
      expect(
        switchOf(tester, const Key('payment-notifications-switch')).value,
        isTrue,
      );

      await tester.tap(find.byKey(const Key('order-notifications-switch')));
      await tester.pump(const Duration(milliseconds: 50));

      expect(provider.orderEnabled, isTrue);
      expect(await store.readBool(NotificationProvider.orderKey), isTrue);
      // Menyalakan sakelar kembali meminta izin sistem sekali.
      expect(service.permissionRequests, 1);
    });

    testWidgets('izin sistem nonaktif: banner tampil lalu hilang setelah izin',
        (tester) async {
      service
        ..systemEnabled = false
        ..permissionGranted = true;
      await pumpScreen(tester);

      expect(find.textContaining('Izin notifikasi dari sistem nonaktif'),
          findsOneWidget);

      await tester.tap(find.text('Izinkan notifikasi'));
      await tester.pump(const Duration(milliseconds: 50));

      expect(service.permissionRequests, 1);
      expect(provider.systemEnabled, isTrue);
      expect(find.textContaining('Izin notifikasi dari sistem nonaktif'),
          findsNothing);
    });

    testWidgets('notifikasi percobaan benar-benar dikirim', (tester) async {
      await pumpScreen(tester);

      await tester.tap(find.byKey(const Key('test-notification')));
      await tester.pump(const Duration(milliseconds: 50));

      expect(service.shown, hasLength(1));
      expect(service.shown.single.title, 'Notifikasi percobaan');
    });

    testWidgets('semua sakelar mati: tombol percobaan nonaktif',
        (tester) async {
      await pumpScreen(tester);

      await tester.tap(find.byKey(const Key('order-notifications-switch')));
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(find.byKey(const Key('payment-notifications-switch')));
      await tester.pump(const Duration(milliseconds: 50));

      expect(provider.anyEnabled, isFalse);
      expect(
        tester.widget<OutlinedButton>(find.byKey(const Key('test-notification')))
            .onPressed,
        isNull,
      );

      await tester.tap(find.byKey(const Key('test-notification')));
      await tester.pump(const Duration(milliseconds: 50));
      expect(service.shown, isEmpty);
    });

    testWidgets('tombol kembali tidak menimbulkan error tanpa rute sebelumnya',
        (tester) async {
      await pumpScreen(tester);

      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pump(const Duration(milliseconds: 50));

      expect(tester.takeException(), isNull);
      expect(find.text('Notifikasi'), findsOneWidget);
    });
  });
}
