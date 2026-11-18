import 'user_model.dart';

/// Kontrak data autentikasi (lihat catatan di MenuRepository).
/// Aturan OTP lupa password; harus sama dengan backend (internal/handler/auth_otp.go).
class PasswordOtpRules {
  PasswordOtpRules._();

  static const int length = 6;
  static const int validityMinutes = 10;

  /// Jeda minta ulang. Server mengabaikan permintaan yang lebih cepat dari ini.
  static const Duration resendCooldown = Duration(seconds: 60);
}

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

  /// Lupa password lewat OTP, tiga langkah:
  /// 1. [requestPasswordOtp]: kode 6 digit dikirim ke email. Server selalu sukses,
  ///    termasuk untuk email yang tidak terdaftar (tidak membocorkan akun).
  /// 2. [verifyPasswordOtp]: memeriksa kode (belum memakainya) agar layar bisa lanjut.
  /// 3. [resetPasswordWithOtp]: kode dicek ulang lalu password diganti; semua sesi lama dicabut.
  Future<void> requestPasswordOtp({required String email});

  Future<void> verifyPasswordOtp({required String email, required String code});

  Future<void> resetPasswordWithOtp({
    required String email,
    required String code,
    required String newPassword,
  });

  /// Mengembalikan token baru bila server menerbitkannya (semua token lama
  /// dicabut setelah password diganti), atau null bila tidak ada.
  Future<String?> changePassword({
    required String currentPassword,
    required String newPassword,
  });
}
