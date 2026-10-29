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

  @override
  Future<void> forgotPassword({required String email}) async {
    await Future<void>.delayed(latency);

    if (!_accounts.containsKey(email.trim().toLowerCase())) {
      throw const ApiException('Email tidak terdaftar.', statusCode: 404);
    }
  }
}

class _MockAccount {
  final UserModel user;
  final String password;

  const _MockAccount({required this.user, required this.password});
}
