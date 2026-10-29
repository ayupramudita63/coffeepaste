import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/utils/json_utils.dart';
import '../../auth/data/user_model.dart';
import 'profile_repository.dart';

class ApiProfileRepository implements ProfileRepository {
  final ApiClient _client;

  ApiProfileRepository(this._client);

  @override
  Future<UserModel> fetchProfile() async {
    final body = await _client.get(ApiEndpoints.profile);
    return _parse(body);
  }

  @override
  Future<UserModel> updateProfile({
    required String name,
    required String phone,
    required String gender,
    required String birthDate,
  }) async {
    final body = await _client.put(
      ApiEndpoints.profile,
      data: {
        'name': name,
        'phone': phone,
        'gender': gender,
        'birthDate': birthDate,
      },
    );
    return _parse(body);
  }

  @override
  Future<String> requestEmailChange({
    required String email,
    required String currentPassword,
  }) async {
    final body = await _client.post(
      ApiEndpoints.changeEmail,
      data: {'email': email, 'currentPassword': currentPassword},
    );
    final map = JsonUtils.asMap(body);
    return JsonUtils.asString(map?['pendingEmail'], fallback: email);
  }

  @override
  Future<String> verifyEmailChange({
    required String email,
    required String code,
  }) async {
    final body = await _client.post(
      ApiEndpoints.verifyEmail,
      data: {'email': email, 'code': code},
    );
    final map = JsonUtils.asMap(body);
    return JsonUtils.asString(map?['email'], fallback: email);
  }

  @override
  Future<void> cancelEmailChange() async {
    await _client.delete(ApiEndpoints.changeEmail);
  }

  UserModel _parse(dynamic body) {
    final map = JsonUtils.asMap(body);
    if (map == null) {
      throw const ApiException('Respons profil dari server tidak valid.');
    }
    return UserModel.fromJson(map);
  }
}
