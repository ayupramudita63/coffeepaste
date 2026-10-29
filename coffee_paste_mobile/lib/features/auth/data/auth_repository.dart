import 'user_model.dart';

/// Kontrak data autentikasi (lihat catatan di MenuRepository).
abstract class AuthRepository {
  Future<AuthResult> login({
    required String email,
    required String password,
  });

  /// Menukar ID token Google dengan sesi aplikasi (server memverifikasi token).
  Future<AuthResult> loginWithGoogle({required String idToken});

  Future<void> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  });

  Future<void> forgotPassword({required String email});

  /// Mengembalikan token baru bila server menerbitkannya (semua token lama
  /// dicabut setelah password diganti), atau null bila tidak ada.
  Future<String?> changePassword({
    required String currentPassword,
    required String newPassword,
  });
}
