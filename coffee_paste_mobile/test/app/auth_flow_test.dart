import 'package:coffee_paste/core/config/app_config.dart';
import 'package:coffee_paste/core/router/app_router.dart';
import 'package:coffee_paste/core/storage/token_storage.dart';
import 'package:coffee_paste/features/account/account_screen.dart';
import 'package:coffee_paste/features/auth/data/auth_mock_repository.dart';
import 'package:coffee_paste/features/auth/forgot_password_screen.dart';
import 'package:coffee_paste/features/auth/login_screen.dart';
import 'package:coffee_paste/features/cart/cart_screen.dart';
import 'package:coffee_paste/features/main_navigation/main_navigation_screen.dart';
import 'package:coffee_paste/features/splash/splash_screen.dart';
import 'package:coffee_paste/providers/app_navigation_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../support/fakes.dart';
import '../support/test_app.dart';

void main() {
  testWidgets('belum login: splash lalu halaman login', (tester) async {
    await pumpCoffeePaste(tester, storage: InMemoryTokenStorage());

    expect(find.byType(SplashScreen), findsOneWidget);

    await passSplash(tester);

    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.byType(MainNavigationScreen), findsNothing);
  });

  testWidgets('sesi tersimpan: splash langsung ke Home tanpa login',
      (tester) async {
    final storage = InMemoryTokenStorage(token: 'mock-token-1', user: testUser);
    await pumpCoffeePaste(tester, storage: storage);

    await passSplash(tester);

    expect(find.byType(MainNavigationScreen), findsOneWidget);
    expect(find.byType(LoginScreen), findsNothing);
  });

  testWidgets('login berhasil: masuk ke Home dan token tersimpan',
      (tester) async {
    final storage = InMemoryTokenStorage();
    await pumpCoffeePaste(tester, storage: storage);
    await passSplash(tester);

    // Mode mock mengisi email & password demo otomatis.
    await tester.tap(find.text('Masuk'));
    await tester.pumpAndSettle();

    expect(find.byType(MainNavigationScreen), findsOneWidget);
    expect(find.byType(LoginScreen), findsNothing);
    expect(await storage.readToken(), 'mock-token-1');
  });

  testWidgets('login gagal: tetap di login dan tampil pesan error',
      (tester) async {
    final storage = InMemoryTokenStorage();
    await pumpCoffeePaste(tester, storage: storage);
    await passSplash(tester);

    await tester.enterText(find.byType(TextField).at(1), 'salah');
    await tester.tap(find.text('Masuk'));
    await tester.pumpAndSettle();

    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.text('Email atau password salah.'), findsOneWidget);
    expect(await storage.readToken(), isNull);
  });

  testWidgets('guard: belum login tidak bisa membuka halaman terlindungi',
      (tester) async {
    await pumpCoffeePaste(tester, storage: InMemoryTokenStorage());
    await passSplash(tester);

    GoRouter.of(tester.element(find.byType(LoginScreen))).go(AppRoutes.cart);
    await tester.pumpAndSettle();

    expect(find.byType(CartScreen), findsNothing);
    expect(find.byType(LoginScreen), findsOneWidget);
  });

  testWidgets('guard: sudah login tidak bisa kembali ke halaman login',
      (tester) async {
    final storage = InMemoryTokenStorage(token: 'mock-token-1', user: testUser);
    await pumpCoffeePaste(tester, storage: storage);
    await passSplash(tester);

    GoRouter.of(tester.element(find.byType(MainNavigationScreen)))
        .go(AppRoutes.login);
    await tester.pumpAndSettle();

    expect(find.byType(LoginScreen), findsNothing);
    expect(find.byType(MainNavigationScreen), findsOneWidget);
  });

  testWidgets('logout dari tab Akun: kembali ke login dan token terhapus',
      (tester) async {
    final storage = InMemoryTokenStorage(token: 'mock-token-1', user: testUser);
    await pumpCoffeePaste(tester, storage: storage);
    await passSplash(tester);

    // Buka tab Akun (index 3).
    tester
        .element(find.byType(MainNavigationScreen))
        .read<AppNavigationProvider>()
        .setTab(3);
    await tester.pumpAndSettle();
    expect(find.byType(AccountScreen), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Keluar'),
      200,
      scrollable: find.descendant(
        of: find.byType(AccountScreen),
        matching: find.byType(Scrollable),
      ),
    );
    await tester.tap(find.text('Keluar'));
    await tester.pumpAndSettle();

    // Dialog konfirmasi.
    expect(find.byType(AlertDialog), findsOneWidget);
    await tester.tap(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.text('Keluar'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.byType(MainNavigationScreen), findsNothing);
    expect(await storage.readToken(), isNull);
    expect(await storage.readUser(), isNull);
  });

  Finder fieldIn(String key) => find.descendant(
        of: find.byKey(Key(key)),
        matching: find.byType(TextField),
      );

  Future<void> openForgotPassword(WidgetTester tester) async {
    await tester.ensureVisible(find.text('Lupa Password?'));
    await tester.tap(find.text('Lupa Password?'));
    await tester.pumpAndSettle();
    expect(find.byType(ForgotPasswordScreen), findsOneWidget);
  }

  testWidgets('lupa password: email -> OTP -> password baru -> login',
      (tester) async {
    final storage = InMemoryTokenStorage();
    await pumpCoffeePaste(tester, storage: storage);
    await passSplash(tester);
    await openForgotPassword(tester);

    // Langkah 1: email
    await tester.enterText(fieldIn('forgot-email'), AppConfig.demoEmail);
    await tester.tap(find.byKey(const Key('forgot-send-otp')));
    await tester.pumpAndSettle();
    expect(find.text('Masukkan Kode OTP'), findsOneWidget);

    // Langkah 2: OTP (kirim ulang masih dikunci selama hitung mundur)
    expect(
      tester.widget<TextButton>(find.byKey(const Key('forgot-resend'))).onPressed,
      isNull,
    );
    await tester.enterText(fieldIn('forgot-otp'), MockAuthRepository.demoOtp);
    await tester.tap(find.byKey(const Key('forgot-verify-otp')));
    await tester.pumpAndSettle();
    expect(find.text('Password Baru'), findsOneWidget);

    // Langkah 3: password baru yang lemah ditolak, yang kuat diterima
    await tester.enterText(fieldIn('forgot-new-password'), 'lemah');
    await tester.enterText(fieldIn('forgot-confirm-password'), 'lemah');
    await tester.tap(find.byKey(const Key('forgot-save-password')));
    await tester.pumpAndSettle();
    expect(find.byType(ForgotPasswordScreen), findsOneWidget);

    await tester.enterText(fieldIn('forgot-new-password'), 'PasswordBaru1');
    await tester.enterText(fieldIn('forgot-confirm-password'), 'PasswordBaru1');
    await tester.tap(find.byKey(const Key('forgot-save-password')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    // Langsung ke login, dan kotak pesan sukses masih tampil di atasnya.
    expect(find.byType(LoginScreen), findsOneWidget);
    expect(
      find.text('Password berhasil diubah. Silakan masuk dengan password baru.'),
      findsOneWidget,
    );
    await tester.pumpAndSettle(); // tunggu kotak pesan hilang sendiri
    expect(
      find.text('Password berhasil diubah. Silakan masuk dengan password baru.'),
      findsNothing,
    );
    await tester.enterText(find.byType(TextField).at(1), 'PasswordBaru1');
    await tester.tap(find.text('Masuk'));
    await tester.pumpAndSettle();
    expect(find.byType(MainNavigationScreen), findsOneWidget);
  });

  testWidgets('lupa password: kode OTP salah tidak lanjut ke password baru',
      (tester) async {
    await pumpCoffeePaste(tester, storage: InMemoryTokenStorage());
    await passSplash(tester);
    await openForgotPassword(tester);

    await tester.enterText(fieldIn('forgot-email'), AppConfig.demoEmail);
    await tester.tap(find.byKey(const Key('forgot-send-otp')));
    await tester.pumpAndSettle();

    await tester.enterText(fieldIn('forgot-otp'), '000000');
    await tester.tap(find.byKey(const Key('forgot-verify-otp')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    expect(find.text('Kode OTP salah atau sudah kedaluwarsa'), findsOneWidget);
    expect(find.text('Masukkan Kode OTP'), findsOneWidget);
    expect(find.text('Password Baru'), findsNothing);

    // Tombol kembali: OTP -> email -> login
    await tester.tap(find.byKey(const Key('forgot-back')));
    await tester.pumpAndSettle();
    expect(find.text('Lupa Password?'), findsWidgets);
    await tester.tap(find.byKey(const Key('forgot-back')));
    await tester.pumpAndSettle();
    expect(find.byType(LoginScreen), findsOneWidget);
  });
}