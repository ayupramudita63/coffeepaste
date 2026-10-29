import 'dart:io';
import 'package:flutter/material.dart';

import '../core/network/api_exception.dart';
import '../features/account/data/profile_repository.dart';
import '../features/auth/data/user_model.dart';

/// Profil customer yang sedang login. Data disimpan di server; foto profil
/// masih lokal (belum ada endpoint upload untuk customer).
class UserProvider extends ChangeNotifier {
  static const List<String> _months = [
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
  ];

  final ProfileRepository _repository;

  UserProvider(this._repository);

  File? _avatarFile;

  /// ID akun, dipakai mencocokkan profil dari server (email bisa berubah).
  String _userId = '';
  String _name = '';
  String _email = '';

  /// Email baru yang menunggu verifikasi kode (kosong bila tidak ada).
  String _pendingEmail = '';
  String _phone = '';
  String _gender = '';

  /// Format YYYY-MM-DD, kosong bila belum diisi.
  String _birthDateIso = '';

  bool _isSaving = false;

  File? get avatarFile => _avatarFile;
  String get name => _name;
  String get email => _email;
  String get pendingEmail => _pendingEmail;
  String get phone => _phone;
  String get gender => _gender;
  String get birthDateIso => _birthDateIso;
  bool get isSaving => _isSaving;

  /// Tanggal lahir untuk tampilan, contoh "12 Juli 2004". Kosong bila belum diisi.
  String get birthDate {
    final date = DateTime.tryParse(_birthDateIso);
    if (date == null) return '';
    return '${date.day} ${_months[date.month - 1]} ${date.year}';
  }

  /// Mengisi profil dari data akun (hasil login atau profil dari server).
  void applyUser(UserModel user) {
    if (user.id.isNotEmpty) _userId = user.id;
    _pendingEmail = user.pendingEmail;
    if (user.name.isNotEmpty) _name = user.name;
    if (user.email.isNotEmpty) _email = user.email;
    _phone = user.phone;
    _gender = user.gender;
    _birthDateIso = user.birthDate;
    notifyListeners();
  }

  /// Mengosongkan data saat logout supaya tidak terlihat akun berikutnya.
  void clear() {
    _avatarFile = null;
    _userId = _name = _email = _phone = _gender = _birthDateIso = '';
    _pendingEmail = '';
    notifyListeners();
  }

  /// Memuat profil lengkap (telepon, jenis kelamin, tanggal lahir) dari server.
  /// Gagal memuat bukan error fatal: data dari login tetap dipakai.
  Future<void> loadProfile() async {
    try {
      final profile = await _repository.fetchProfile();
      // Abaikan bila bukan akun yang sedang aktif (mis. sudah ganti akun).
      // Dicocokkan lewat ID karena email bisa berubah; email hanya cadangan.
      if (_userId.isNotEmpty && profile.id.isNotEmpty) {
        if (profile.id != _userId) return;
      } else if (_email.isNotEmpty &&
          profile.email.toLowerCase() != _email.toLowerCase()) {
        return;
      }
      applyUser(profile);
    } catch (_) {}
  }

  /// Menyimpan perubahan profil. Mengembalikan null bila berhasil, atau pesan error.
  /// Parameter yang tidak diisi memakai nilai saat ini.
  Future<String?> saveProfile({
    String? name,
    String? phone,
    String? gender,
    String? birthDateIso,
  }) async {
    if (_isSaving) return 'Sedang menyimpan, tunggu sebentar.';
    _isSaving = true;
    notifyListeners();

    try {
      final updated = await _repository.updateProfile(
        name: name ?? _name,
        phone: phone ?? _phone,
        gender: gender ?? _gender,
        birthDate: birthDateIso ?? _birthDateIso,
      );
      _isSaving = false;
      applyUser(updated);
      return null;
    } on ApiException catch (error) {
      _isSaving = false;
      notifyListeners();
      return error.message;
    } catch (_) {
      _isSaving = false;
      notifyListeners();
      return 'Gagal menyimpan. Coba lagi.';
    }
  }

  /// Meminta kode verifikasi ke [newEmail]. Mengembalikan null bila berhasil, atau pesan error.
  Future<String?> requestEmailChange({
    required String newEmail,
    required String currentPassword,
  }) async {
    try {
      final pending = await _repository.requestEmailChange(
        email: newEmail,
        currentPassword: currentPassword,
      );
      _pendingEmail = pending;
      notifyListeners();
      return null;
    } on ApiException catch (error) {
      return error.message;
    } catch (_) {
      return 'Gagal mengirim kode. Coba lagi.';
    }
  }

  /// Memverifikasi kode untuk email yang menunggu. Mengembalikan null bila berhasil.
  Future<String?> verifyEmailChange(String code) async {
    final pending = _pendingEmail;
    if (pending.isEmpty) return 'Tidak ada permintaan ganti email.';
    try {
      final confirmed = await _repository.verifyEmailChange(
        email: pending,
        code: code,
      );
      _email = confirmed;
      _pendingEmail = '';
      notifyListeners();
      return null;
    } on ApiException catch (error) {
      return error.message;
    } catch (_) {
      return 'Gagal memverifikasi kode. Coba lagi.';
    }
  }

  /// Membatalkan permintaan ganti email. Mengembalikan null bila berhasil.
  Future<String?> cancelEmailChange() async {
    try {
      await _repository.cancelEmailChange();
      _pendingEmail = '';
      notifyListeners();
      return null;
    } on ApiException catch (error) {
      return error.message;
    } catch (_) {
      return 'Gagal membatalkan. Coba lagi.';
    }
  }

  void updateAvatar(File file) {
    _avatarFile = file;
    notifyListeners();
  }
}
