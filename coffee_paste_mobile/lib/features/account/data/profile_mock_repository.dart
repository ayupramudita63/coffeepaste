import '../../../core/config/app_config.dart';
import '../../../core/network/api_exception.dart';
import '../../auth/data/user_model.dart';
import 'profile_repository.dart';

/// Profil palsu di memori (mode mock).
class MockProfileRepository implements ProfileRepository {
  final Duration latency;

  MockProfileRepository({this.latency = const Duration(milliseconds: 400)});

  UserModel _user = const UserModel(
    id: '1',
    name: 'Ayu Pramudita',
    email: AppConfig.demoEmail,
    phone: '+62 812 3456 7890',
    gender: 'Perempuan',
    birthDate: '2004-07-12',
  );

  /// Kode verifikasi tetap di mode mock.
  static const String mockCode = '123456';

  String? _pending;

  @override
  Future<UserModel> fetchProfile() async {
    await Future<void>.delayed(latency);
    return UserModel(
      id: _user.id,
      name: _user.name,
      email: _user.email,
      phone: _user.phone,
      gender: _user.gender,
      birthDate: _user.birthDate,
      pendingEmail: _pending ?? '',
    );
  }

  @override
  Future<String> requestEmailChange({
    required String email,
    required String currentPassword,
  }) async {
    await Future<void>.delayed(latency);
    if (currentPassword != AppConfig.demoPassword) {
      throw const ApiException('Password saat ini salah', statusCode: 422);
    }
    if (email.toLowerCase() == _user.email.toLowerCase()) {
      throw const ApiException('Email baru sama dengan email saat ini',
          statusCode: 422);
    }
    _pending = email;
    return email;
  }

  @override
  Future<String> verifyEmailChange({
    required String email,
    required String code,
  }) async {
    await Future<void>.delayed(latency);
    if (_pending == null || _pending != email || code != mockCode) {
      throw const ApiException('Kode verifikasi salah atau sudah kedaluwarsa',
          statusCode: 422);
    }
    _user = UserModel(
      id: _user.id,
      name: _user.name,
      email: email,
      phone: _user.phone,
      gender: _user.gender,
      birthDate: _user.birthDate,
    );
    _pending = null;
    return email;
  }

  @override
  Future<void> cancelEmailChange() async {
    await Future<void>.delayed(latency);
    _pending = null;
  }

  @override
  Future<UserModel> updateProfile({
    required String name,
    required String phone,
    required String gender,
    required String birthDate,
  }) async {
    await Future<void>.delayed(latency);
    _user = UserModel(
      id: _user.id,
      name: name,
      email: _user.email,
      phone: phone,
      gender: gender,
      birthDate: birthDate,
    );
    return _user;
  }
}
