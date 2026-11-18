import '../../../core/config/app_config.dart';
import '../../../core/network/api_exception.dart';
import 'auth_repository.dart';
import 'user_model.dart';

/// Repository palsu untuk login/register tanpa backend.
///
/// Akun demo: lihat AppConfig.demoEmail / AppConfig.demoPassword.
/// Akun hasil register selama aplikasi berjalan juga bisa dipakai login.
class MockAuthRepository implements AuthRepository {
  final Duration latency;

  MockAuthRepository({this.latency = const Duration(milliseconds: 700)});

  final Map<String, _MockAccount> _accounts = {
    AppConfig.demoEmail: const _MockAccount(
      user: UserModel(
        id: '1',
        name: 'Ayu Pramudita',
        email: AppConfig.demoEmail,
        phone: '+62 812 3456 7890',
      ),
      password: AppConfig.demoPassword,
    ),
  };

  int _nextId = 2;
  String? _currentEmail;

  @override
  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(latency);

    final account = _accounts[email.trim().toLowerCase()];
    if (account == null || account.password != password) {
      throw const ApiException(
        'Email atau password salah.',
        statusCode: 401,
      );
    }

    _currentEmail = account.user.email.toLowerCase();
    return AuthResult(token: 'mock-token-${account.user.id}', user: account.user);
  }

  @override
  Future<AuthResult> loginWithGoogle({required String idToken}) async {
    await Future<void>.delayed(latency);

    // Mode mock: semua token dianggap milik akun demo.
    final account = _accounts[AppConfig.demoEmail]!;
    _currentEmail = account.user.email.toLowerCase();
    return AuthResult(token: 'mock-token-${account.user.id}', user: account.user);
  }

  @override
  Future<void> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    await Future<void>.delayed(latency);

    final key = email.trim().toLowerCase();
    if (_accounts.containsKey(key)) {
      throw const ApiException('Email sudah terdaftar.', statusCode: 409);
    }

    _accounts[key] = _MockAccount(
      user: UserModel(
        id: '${_nextId++}',
        name: name,
        email: key,
        phone: phone,
      ),
      password: password,
    );
  }

  @override
  Future<String?> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await Future<void>.delayed(latency);

    final account = _accounts[_currentEmail];
    if (account == null) {
      throw const ApiException('Sesi berakhir.', statusCode: 401);
    }
    if (account.password != currentPassword) {
      throw const ApiException('Password saat ini salah', statusCode: 422);
    }
    _accounts[_currentEmail!] =
        _MockAccount(user: account.user, password: newPassword);
    return null;
  }

  /// Kode OTP yang selalu "terkirim" di mode mock.
  static const String demoOtp = '123456';
  static const int _maxOtpAttempts = 5;

  final Map<String, int> _otpAttempts = {}; // email -> percobaan salah (ada = OTP aktif)

  /// Meniru backend: selalu sukses, OTP hanya dibuat untuk email yang terdaftar.
  @override
  Future<void> requestPasswordOtp({required String email}) async {
    await Future<void>.delayed(latency);

    final key = email.trim().toLowerCase();
    if (_accounts.containsKey(key)) _otpAttempts[key] = 0;
  }

  @override
  Future<void> verifyPasswordOtp({
    required String email,
    required String code,
  }) async {
    await Future<void>.delayed(latency);
    _checkOtp(email.trim().toLowerCase(), code);
  }

  @override
  Future<void> resetPasswordWithOtp({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    await Future<void>.delayed(latency);

    final key = email.trim().toLowerCase();
    _checkOtp(key, code);
    final account = _accounts[key]!;
    _accounts[key] = _MockAccount(user: account.user, password: newPassword);
    _otpAttempts.remove(key); // OTP hanya sekali pakai
  }

  void _checkOtp(String key, String code) {
    final attempts = _otpAttempts[key];
    if (attempts == null) {
      throw const ApiException(
        'Kode OTP salah atau sudah kedaluwarsa',
        statusCode: 422,
      );
    }
    if (code == demoOtp) return;

    if (attempts + 1 >= _maxOtpAttempts) {
      _otpAttempts.remove(key);
      throw const ApiException(
        'Terlalu banyak kode salah. Minta kode OTP baru',
        statusCode: 422,
      );
    }
    _otpAttempts[key] = attempts + 1;
    throw const ApiException(
      'Kode OTP salah atau sudah kedaluwarsa',
      statusCode: 422,
    );
  }
}

class _MockAccount {
  final UserModel user;
  final String password;

  const _MockAccount({required this.user, required this.password});
}
