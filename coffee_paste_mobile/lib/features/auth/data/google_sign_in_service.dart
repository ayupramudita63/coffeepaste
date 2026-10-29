import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../core/config/app_config.dart';
import '../../../core/network/api_exception.dart';

/// Mengambil ID token Google dari perangkat. Dipisah dari AuthRepository supaya
/// bagian yang bergantung pada plugin native mudah diganti saat test.
abstract class GoogleSignInService {
  /// Menampilkan pemilih akun Google. Mengembalikan ID token, atau null bila
  /// pengguna membatalkan. Melempar [ApiException] bila gagal.
  Future<String?> getIdToken();

  /// Melupakan akun Google di perangkat ini, supaya login berikutnya
  /// menampilkan pemilih akun lagi. Tidak pernah melempar.
  Future<void> signOut();
}

/// Mode mock (USE_MOCK=true): tidak menyentuh Google sama sekali.
class MockGoogleSignInService implements GoogleSignInService {
  @override
  Future<String?> getIdToken() async => 'mock-google-token';

  @override
  Future<void> signOut() async {}
}

/// Implementasi nyata memakai plugin google_sign_in.
class PluginGoogleSignInService implements GoogleSignInService {
  /// OAuth client ID bertipe **Web** (sama dengan GOOGLE_CLIENT_IDS di backend).
  /// Wajib di Android supaya Google mau menerbitkan ID token untuk backend.
  final String serverClientId;
  final GoogleSignIn _signIn;
  Future<void>? _init;

  PluginGoogleSignInService({
    required this.serverClientId,
    GoogleSignIn? signIn,
  }) : _signIn = signIn ?? GoogleSignIn.instance;

  Future<void> _ensureInitialized() {
    return _init ??= _signIn
        .initialize(serverClientId: serverClientId)
        .catchError((Object e) {
      _init = null; // izinkan percobaan ulang
      throw e;
    });
  }

  @override
  Future<String?> getIdToken() async {
    if (serverClientId.isEmpty) {
      throw const ApiException(
        'Login Google belum dikonfigurasi. Jalankan aplikasi dengan '
        '--dart-define=GOOGLE_SERVER_CLIENT_ID=<Web client ID>.',
      );
    }

    try {
      await _ensureInitialized();
      final account = await _signIn.authenticate();
      final idToken = account.authentication.idToken;
      if (idToken == null || idToken.isEmpty) {
        throw const ApiException(
          'Google tidak mengirim ID token. Pastikan GOOGLE_SERVER_CLIENT_ID '
          'adalah client ID bertipe Web.',
        );
      }
      return idToken;
    } on ApiException {
      rethrow;
    } on GoogleSignInException catch (e) {
      if (kDebugMode) {
        debugPrint('GoogleSignInException: ${e.code.name} ${e.description}');
      }
      switch (e.code) {
        case GoogleSignInExceptionCode.canceled:
        case GoogleSignInExceptionCode.interrupted:
          // Dibatalkan pengguna. (Di Android, salah SHA-1 / client ID juga
          // bisa tampil sebagai "canceled"; cek log debug di atas.)
          return null;
        case GoogleSignInExceptionCode.clientConfigurationError:
        case GoogleSignInExceptionCode.providerConfigurationError:
          throw const ApiException(
            'Login Google belum dikonfigurasi dengan benar di aplikasi ini. '
            'Periksa SHA-1, package name, dan client ID di Google Cloud Console.',
          );
        default:
          throw ApiException(
            'Login Google gagal (${e.code.name}). Coba lagi.',
          );
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Login Google error: $e');
      throw const ApiException('Login Google gagal. Coba lagi.');
    }
  }

  @override
  Future<void> signOut() async {
    if (_init == null) return; // belum pernah dipakai
    try {
      await _signIn.signOut();
    } catch (_) {}
  }
}

GoogleSignInService createGoogleSignInService() {
  if (AppConfig.useMock) return MockGoogleSignInService();
  return PluginGoogleSignInService(
    serverClientId: AppConfig.googleServerClientId,
  );
}