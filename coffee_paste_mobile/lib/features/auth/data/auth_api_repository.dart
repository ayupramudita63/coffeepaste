import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/utils/json_utils.dart';
import 'auth_repository.dart';
import 'user_model.dart';

class ApiAuthRepository implements AuthRepository {
  final ApiClient _client;

  ApiAuthRepository(this._client);

  @override
  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    final body = await _client.post(
      ApiEndpoints.login,
      data: {'email': email, 'password': password},
    );

    return _parseAuthResult(body);
  }

  @override
  Future<AuthResult> loginWithGoogle({required String idToken}) async {
    final body = await _client.post(
      ApiEndpoints.googleLogin,
      data: {'idToken': idToken},
    );
    return _parseAuthResult(body);
  }

  AuthResult _parseAuthResult(dynamic body) {
    final map = JsonUtils.asMap(body);
    if (map == null) {
      throw const ApiException('Respons login dari server tidak valid.');
    }

    final token = JsonUtils.asString(
      JsonUtils.pick(map, ['token', 'access_token', 'accessToken']),
    );
    if (token.isEmpty) {
      throw const ApiException('Token tidak ditemukan pada respons server.');
    }

    final userMap = JsonUtils.asMap(map['user']) ?? map;
    final user = UserModel.fromJson(userMap);

    // Backend memakai satu endpoint login untuk admin, kasir, dan customer.
    // Aplikasi mobile hanya untuk customer.
    if (user.role != 'customer') {
      throw const ApiException(
        'Akun ini bukan akun pelanggan. Gunakan akun pelanggan untuk masuk di aplikasi.',
      );
    }

    return AuthResult(token: token, user: user);
  }

  @override
  Future<void> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    await _client.post(
      ApiEndpoints.register,
      data: {
        'name': name,
        'email': email,
        'phone': phone,
        'password': password,
      },
    );
  }

  @override
  Future<String?> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final body = await _client.put(
      ApiEndpoints.changePassword,
      data: {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      },
    );
    final map = JsonUtils.asMap(body);
    return map == null ? null : JsonUtils.asNullableString(map['token']);
  }

  @override
  Future<void> forgotPassword({required String email}) async {
    await _client.post(
      ApiEndpoints.forgotPassword,
      data: {'email': email},
    );
  }
}
