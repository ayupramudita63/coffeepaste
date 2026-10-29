import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../features/auth/data/user_model.dart';

/// Penyimpanan sesi login (token + profil singkat) di perangkat.
///
/// Implementasi aslinya [SecureTokenStorage] (Keychain di iOS, Keystore di
/// Android). [InMemoryTokenStorage] dipakai untuk test.
abstract class TokenStorage {
  Future<String?> readToken();

  Future<UserModel?> readUser();

  Future<void> saveSession({required String token, required UserModel user});

  Future<void> clear();
}

class SecureTokenStorage implements TokenStorage {
  static const String tokenKey = 'auth_token';
  static const String userKey = 'auth_user';

  final FlutterSecureStorage _storage;

  SecureTokenStorage({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(encryptedSharedPreferences: true),
            );

  @override
  Future<String?> readToken() => _storage.read(key: tokenKey);

  @override
  Future<UserModel?> readUser() async {
    final raw = await _storage.read(key: userKey);
    if (raw == null || raw.isEmpty) return null;

    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) return UserModel.fromJson(decoded);
    } catch (_) {
      // Data rusak dianggap tidak ada.
    }
    return null;
  }

  @override
  Future<void> saveSession({
    required String token,
    required UserModel user,
  }) async {
    await _storage.write(key: tokenKey, value: token);
    await _storage.write(key: userKey, value: jsonEncode(user.toJson()));
  }

  @override
  Future<void> clear() async {
    await _storage.delete(key: tokenKey);
    await _storage.delete(key: userKey);
  }
}

class InMemoryTokenStorage implements TokenStorage {
  String? _token;
  UserModel? _user;

  InMemoryTokenStorage({String? token, UserModel? user})
      : _token = token,
        _user = user;

  @override
  Future<String?> readToken() async => _token;

  @override
  Future<UserModel?> readUser() async => _user;

  @override
  Future<void> saveSession({
    required String token,
    required UserModel user,
  }) async {
    _token = token;
    _user = user;
  }

  @override
  Future<void> clear() async {
    _token = null;
    _user = null;
  }
}
