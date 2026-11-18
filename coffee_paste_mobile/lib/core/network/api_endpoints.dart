/// Semua path endpoint ada di sini. Kalau route di backend Go berbeda,
/// cukup ubah file ini.
class ApiEndpoints {
  ApiEndpoints._();

  // Auth
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String googleLogin = '/auth/google';

  /// Lupa password lewat kode OTP 6 digit. Sengaja bukan `/auth/forgot-password`
  /// (tautan token milik web) supaya alur web tidak terpengaruh.
  static const String forgotPasswordOtp = '/auth/forgot-password/otp';
  static const String verifyPasswordOtp = '/auth/forgot-password/otp/verify';
  static const String resetPasswordOtp = '/auth/reset-password/otp';

  // Akun (token customer)
  static const String profile = '/profile';
  static const String changePassword = '/profile/password';

  /// Ganti email: kode 6 digit dikirim ke email baru, lalu diverifikasi.
  static const String changeEmail = '/profile/email';
  static const String verifyEmail = '/profile/email/verify';

  /// Token perangkat untuk push notification (POST simpan, DELETE cabut).
  static const String devices = '/devices';

  // Menu (publik, tanpa token)
  static const String categories = '/menu/categories';
  static const String menus = '/menu';

  // Pesanan (token customer)
  static const String orders = '/orders';

  /// ID pesanan dari server berbentuk "#CP00001"; "#" harus di-encode
  /// (%23) supaya tidak dianggap fragment URL.
  static String cancelOrder(String id) =>
      '/orders/${Uri.encodeComponent(id)}/cancel';

  /// Ulasan per produk dari satu pesanan yang sudah selesai.
  static String orderReviews(String id) =>
      '/orders/${Uri.encodeComponent(id)}/reviews';
}
