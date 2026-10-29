import '../core/network/api_client.dart';
import '../core/network/api_exception.dart';
import '../core/storage/token_storage.dart';
import '../features/auth/data/auth_repository.dart';
import '../features/auth/data/google_sign_in_service.dart';
import '../features/auth/data/user_model.dart';
import 'base_provider.dart';

class AuthProvider extends BaseProvider {
  final AuthRepository _repository;
  final ApiClient _client;
  final TokenStorage _storage;
  final GoogleSignInService? _googleSignIn;

  UserModel? _user;
  bool _initialized = false;
  Future<void>? _restoreFuture;

  AuthProvider(
    this._repository,
    this._client,
    this._storage, {
    GoogleSignInService? googleSignIn,
  }) : _googleSignIn = googleSignIn {
    // Token ditolak server (kedaluwarsa) -> keluar otomatis.
    // Router (guard) yang memindahkan pengguna ke halaman login.
    _client.onUnauthorized = () {
      logout();
    };
  }

  UserModel? get user => _user;

  /// true setelah [restoreSession] selesai (berhasil atau tidak).
  bool get isInitialized => _initialized;

  bool get isAuthenticated => _user != null && _client.hasToken;

  /// Memulihkan sesi dari penyimpanan aman. Aman dipanggil berkali-kali.
  Future<void> restoreSession() => _restoreFuture ??= _restore();

  Future<void> _restore() async {
    try {
      final token = await _storage.readToken();
      final user = await _storage.readUser();

      if (token != null && token.isNotEmpty && user != null) {
        _client.setToken(token);
        _user = user;
      } else if (token != null || user != null) {
        // Sesi tersimpan tidak lengkap -> bersihkan.
        await _storage.clear();
      }
    } catch (_) {
      // Penyimpanan tidak terbaca -> anggap belum login.
      try {
        await _storage.clear();
      } catch (_) {}
    }

    _initialized = true;
    notifyListeners();
  }

  /// Mengembalikan true jika berhasil. Pesan error ada di [errorMessage].
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    setLoading();
    try {
      final result = await _repository.login(
        email: email,
        password: password,
      );
      await _persist(result.token, result.user);
      _client.setToken(result.token);
      _user = result.user;
      setSuccess();
      return true;
    } catch (error) {
      setError(error);
      return false;
    }
  }

  /// Login dengan akun Google. Mengembalikan true jika berhasil. Bila pengguna
  /// membatalkan, mengembalikan false tanpa pesan error ([errorMessage] null).
  Future<bool> loginWithGoogle() async {
    final google = _googleSignIn;
    if (google == null) {
      setError(const ApiException('Login Google tidak tersedia.'));
      return false;
    }

    setLoading();
    try {
      final idToken = await google.getIdToken();
      if (idToken == null) {
        resetStatus(); // dibatalkan pengguna
        return false;
      }
      final result = await _repository.loginWithGoogle(idToken: idToken);
      await _persist(result.token, result.user);
      _client.setToken(result.token);
      _user = result.user;
      setSuccess();
      return true;
    } catch (error) {
      setError(error);
      // Lupakan akun Google di perangkat agar percobaan berikut menampilkan pemilih akun.
      await google.signOut();
      return false;
    }
  }

  /// Memulai sesi dari sumber lain (mis. token yang sudah divalidasi).
  Future<void> startSession({
    required String token,
    required UserModel user,
  }) async {
    await _persist(token, user);
    _client.setToken(token);
    _user = user;
    setSuccess();
  }

  Future<void> _persist(String token, UserModel user) async {
    try {
      await _storage.saveSession(token: token, user: user);
    } catch (_) {
      // Gagal menyimpan tidak boleh menggagalkan login;
      // sesi tetap aktif sampai aplikasi ditutup.
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    setLoading();
    try {
      await _repository.register(
        name: name,
        email: email,
        phone: phone,
        password: password,
      );
      setSuccess();
      return true;
    } catch (error) {
      setError(error);
      return false;
    }
  }

  /// Mengembalikan true jika berhasil. Server mencabut token lama, jadi token
  /// baru dari respons langsung dipakai agar pengguna tidak ter-logout.
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    setLoading();
    try {
      final newToken = await _repository.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      final user = _user;
      if (newToken != null && newToken.isNotEmpty) {
        _client.setToken(newToken);
        if (user != null) await _persist(newToken, user);
      }
      setSuccess();
      return true;
    } catch (error) {
      setError(error);
      return false;
    }
  }

  Future<bool> forgotPassword({required String email}) async {
    setLoading();
    try {
      await _repository.forgotPassword(email: email);
      setSuccess();
      return true;
    } catch (error) {
      setError(error);
      return false;
    }
  }

  Future<void> logout() async {
    _client.clearToken();
    _user = null;
    resetStatus();
    try {
      await _storage.clear();
    } catch (_) {}
    await _googleSignIn?.signOut();
  }
}
