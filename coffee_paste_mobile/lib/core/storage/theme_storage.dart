import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Penyimpanan pilihan tampilan: mode ('system', 'light', 'dark') dan
/// warna tema (kode warna heksadesimal).
abstract class ThemeStorage {
  Future<String?> read();

  Future<void> save(String value);

  Future<String?> readAccent();

  Future<void> saveAccent(String value);
}

/// Memakai flutter_secure_storage yang sudah dipakai untuk token login,
/// jadi tidak perlu dependensi baru.
class SecureThemeStorage implements ThemeStorage {
  static const String key = 'theme_mode';
  static const String accentKey = 'theme_accent';

  final FlutterSecureStorage _storage;

  SecureThemeStorage({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(encryptedSharedPreferences: true),
            );

  @override
  Future<String?> read() => _storage.read(key: key);

  @override
  Future<void> save(String value) => _storage.write(key: key, value: value);

  @override
  Future<String?> readAccent() => _storage.read(key: accentKey);

  @override
  Future<void> saveAccent(String value) =>
      _storage.write(key: accentKey, value: value);
}

/// Dipakai untuk test.
class InMemoryThemeStorage implements ThemeStorage {
  String? value;
  String? accentValue;

  InMemoryThemeStorage([this.value, this.accentValue]);

  @override
  Future<String?> read() async => value;

  @override
  Future<void> save(String value) async => this.value = value;

  @override
  Future<String?> readAccent() async => accentValue;

  @override
  Future<void> saveAccent(String value) async => accentValue = value;
}
