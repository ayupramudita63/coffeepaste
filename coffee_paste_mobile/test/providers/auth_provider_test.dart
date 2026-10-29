import 'package:coffee_paste/core/config/app_config.dart';
import 'package:coffee_paste/core/network/api_client.dart';
import 'package:coffee_paste/core/network/api_exception.dart';
import 'package:coffee_paste/core/storage/token_storage.dart';
import 'package:coffee_paste/features/auth/data/auth_mock_repository.dart';
import 'package:coffee_paste/features/auth/data/google_sign_in_service.dart';
import 'package:coffee_paste/providers/auth_provider.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fakes.dart';

void main() {
  late ApiClient client;
  late InMemoryTokenStorage storage;

  AuthProvider buildProvider([
    TokenStorage? customStorage,
    GoogleSignInService? google,
  ]) {
    return AuthProvider(
      MockAuthRepository(latency: Duration.zero),
      client,
      customStorage ?? storage,
      googleSignIn: google,
    );
  }

  setUp(() {
    client = ApiClient();
    storage = InMemoryTokenStorage();
  });

  group('login', () {
    test('berhasil: sesi aktif dan token tersimpan', () async {
      final auth = buildProvider();

      final ok = await auth.login(
        email: AppConfig.demoEmail,
        password: AppConfig.demoPassword,
      );

      expect(ok, isTrue);
      expect(auth.isAuthenticated, isTrue);
      expect(auth.user?.email, AppConfig.demoEmail);
      expect(client.hasToken, isTrue);
      expect(await storage.readToken(), 'mock-token-1');
      expect((await storage.readUser())?.email, AppConfig.demoEmail);
    });

    test('password salah: tidak login dan tidak ada yang tersimpan', () async {
      final auth = buildProvider();

      final ok = await auth.login(
        email: AppConfig.demoEmail,
        password: 'salah',
      );

      expect(ok, isFalse);
      expect(auth.isAuthenticated, isFalse);
      expect(auth.errorMessage, 'Email atau password salah.');
      expect(await storage.readToken(), isNull);
      expect(await storage.readUser(), isNull);
    });

    test('gagal menyimpan ke storage tidak menggagalkan login', () async {
      final auth = buildProvider(ThrowingTokenStorage());

      final ok = await auth.login(
        email: AppConfig.demoEmail,
        password: AppConfig.demoPassword,
      );

      expect(ok, isTrue);
      expect(auth.isAuthenticated, isTrue);
    });
  });

  group('restoreSession', () {
    test('memulihkan sesi dari storage', () async {
      storage = InMemoryTokenStorage(token: 'mock-token-1', user: testUser);
      final auth = buildProvider();
      expect(auth.isInitialized, isFalse);

      await auth.restoreSession();

      expect(auth.isInitialized, isTrue);
      expect(auth.isAuthenticated, isTrue);
      expect(auth.user?.name, testUser.name);
      expect(client.hasToken, isTrue);
    });

    test('storage kosong: belum login tetapi sudah initialized', () async {
      final auth = buildProvider();

      await auth.restoreSession();

      expect(auth.isInitialized, isTrue);
      expect(auth.isAuthenticated, isFalse);
      expect(client.hasToken, isFalse);
    });

    test('sesi tersimpan tidak lengkap dibersihkan', () async {
      storage = InMemoryTokenStorage(token: 'mock-token-1');
      final auth = buildProvider();

      await auth.restoreSession();

      expect(auth.isAuthenticated, isFalse);
      expect(await storage.readToken(), isNull);
    });

    test('storage error dianggap belum login, tidak crash', () async {
      final auth = buildProvider(ThrowingTokenStorage());

      await auth.restoreSession();

      expect(auth.isInitialized, isTrue);
      expect(auth.isAuthenticated, isFalse);
    });

    test('aman dipanggil berulang', () async {
      storage = InMemoryTokenStorage(token: 'mock-token-1', user: testUser);
      final auth = buildProvider();

      final first = auth.restoreSession();
      final second = auth.restoreSession();

      expect(identical(first, second), isTrue);
      await first;
      expect(auth.isAuthenticated, isTrue);
    });

    test('memberi tahu listener saat selesai (router me-refresh)', () async {
      storage = InMemoryTokenStorage(token: 'mock-token-1', user: testUser);
      final auth = buildProvider();
      var notified = 0;
      auth.addListener(() => notified++);

      await auth.restoreSession();

      expect(notified, 1);
    });
  });

  group('logout', () {
    test('menghapus token di memori dan di storage', () async {
      final auth = buildProvider();
      await auth.login(
        email: AppConfig.demoEmail,
        password: AppConfig.demoPassword,
      );

      await auth.logout();

      expect(auth.isAuthenticated, isFalse);
      expect(auth.user, isNull);
      expect(client.hasToken, isFalse);
      expect(await storage.readToken(), isNull);
      expect(await storage.readUser(), isNull);
    });

    test('server membalas 401 -> keluar otomatis', () async {
      final auth = buildProvider();
      await auth.login(
        email: AppConfig.demoEmail,
        password: AppConfig.demoPassword,
      );

      client.onUnauthorized!();
      await Future<void>.delayed(Duration.zero);

      expect(auth.isAuthenticated, isFalse);
      expect(await storage.readToken(), isNull);
    });
  });

  group('loginWithGoogle', () {
    test('berhasil: sesi aktif dan token tersimpan', () async {
      final auth = buildProvider(null, FakeGoogleSignInService());

      final ok = await auth.loginWithGoogle();

      expect(ok, isTrue);
      expect(auth.isAuthenticated, isTrue);
      expect(client.hasToken, isTrue);
      expect(await storage.readToken(), 'mock-token-1');
    });

    test('dibatalkan pengguna: tidak login dan tanpa pesan error', () async {
      final auth = buildProvider(null, FakeGoogleSignInService(token: null));

      final ok = await auth.loginWithGoogle();

      expect(ok, isFalse);
      expect(auth.isAuthenticated, isFalse);
      expect(auth.errorMessage, isNull);
      expect(auth.isLoading, isFalse);
    });

    test('gagal: pesan error tersedia dan akun Google dilupakan', () async {
      final google = FakeGoogleSignInService(
        error: const ApiException('Login Google gagal.'),
      );
      final auth = buildProvider(null, google);

      final ok = await auth.loginWithGoogle();

      expect(ok, isFalse);
      expect(auth.isAuthenticated, isFalse);
      expect(auth.errorMessage, 'Login Google gagal.');
      expect(google.signOutCalls, 1);
    });

    test('tanpa layanan Google: gagal dengan pesan', () async {
      final auth = buildProvider();

      final ok = await auth.loginWithGoogle();

      expect(ok, isFalse);
      expect(auth.errorMessage, 'Login Google tidak tersedia.');
    });

    test('logout ikut keluar dari akun Google', () async {
      final google = FakeGoogleSignInService();
      final auth = buildProvider(null, google);
      await auth.loginWithGoogle();

      await auth.logout();

      expect(auth.isAuthenticated, isFalse);
      expect(google.signOutCalls, 1);
    });
  });

  group('startSession', () {
    test('memulai sesi dan menyimpannya', () async {
      final auth = buildProvider();

      await auth.startSession(token: 'token-x', user: testUser);

      expect(auth.isAuthenticated, isTrue);
      expect(await storage.readToken(), 'token-x');
    });
  });
}
