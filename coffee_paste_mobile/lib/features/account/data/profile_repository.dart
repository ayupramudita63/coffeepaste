import '../../auth/data/user_model.dart';

/// Kontrak data profil customer (lihat catatan di MenuRepository).
abstract class ProfileRepository {
  Future<UserModel> fetchProfile();

  /// Email tidak diubah lewat sini (pakai [requestEmailChange]). [gender] dan
  /// [birthDate] kosong = dikosongkan; [birthDate] berformat YYYY-MM-DD.
  Future<UserModel> updateProfile({
    required String name,
    required String phone,
    required String gender,
    required String birthDate,
  });

  /// Meminta kode verifikasi ke [email] baru. Mengembalikan email yang menunggu verifikasi.
  /// Melempar ApiException bila password salah, email sudah dipakai, dsb.
  Future<String> requestEmailChange({
    required String email,
    required String currentPassword,
  });

  /// Memverifikasi kode 6 digit. Mengembalikan email baru yang sudah aktif.
  Future<String> verifyEmailChange({
    required String email,
    required String code,
  });

  /// Membatalkan permintaan ganti email yang menunggu verifikasi.
  Future<void> cancelEmailChange();
}
