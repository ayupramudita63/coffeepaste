import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../core/storage/theme_storage.dart';
import '../core/theme/app_accent.dart';
import '../core/theme/app_colors.dart';

/// Pilihan tampilan: mode (ikuti sistem, terang, gelap) dan warna tema.
class ThemeProvider extends ChangeNotifier with WidgetsBindingObserver {
  final ThemeStorage _storage;

  ThemeMode _mode = ThemeMode.system;
  Color _accent = AppAccent.defaultColor;
  bool _observing = false;

  ThemeProvider({ThemeStorage? storage})
      : _storage = storage ?? InMemoryThemeStorage() {
    _applyPalette();
  }

  ThemeMode get mode => _mode;

  /// Warna tema (aksen) yang dipilih pengguna.
  Color get accent => _accent;

  /// Mode yang benar-benar tampil saat ini (sudah memperhitungkan sistem).
  bool get isDark => _resolveDark();

  /// Mulai memantau perubahan mode terang/gelap perangkat.
  /// Dipanggil sekali saat aplikasi dibuka.
  void startObserving() {
    if (_observing) return;
    _observing = true;
    WidgetsBinding.instance.addObserver(this);
  }

  /// Baca pilihan tersimpan. Panggil sebelum runApp agar tidak ada kedipan.
  Future<void> load() async {
    String? raw;
    try {
      raw = await _storage.read();
    } catch (_) {
      // Gagal membaca = pakai bawaan (ikuti sistem).
    }
    _mode = _parse(raw);

    try {
      _accent =
          AppAccent.decode(await _storage.readAccent()) ?? AppAccent.defaultColor;
    } catch (_) {
      // Gagal membaca = pakai warna bawaan.
    }
    _applyPalette();
    notifyListeners();
  }

  Future<void> setMode(ThemeMode mode) async {
    if (_mode == mode) return;

    _mode = mode;
    _applyPalette();
    notifyListeners();

    try {
      await _storage.save(_serialize(mode));
    } catch (_) {
      // Pilihan tetap berlaku selama aplikasi terbuka.
    }
  }

  /// Ganti warna tema. Warna yang terlalu terang disesuaikan otomatis agar
  /// teks putih di atas tombol tetap terbaca.
  Future<void> setAccent(Color color) async {
    final next = AppAccent.normalize(color);
    if (AppAccent.same(next, _accent)) return;

    _accent = next;
    _applyPalette();
    notifyListeners();

    try {
      await _storage.saveAccent(AppAccent.encode(next));
    } catch (_) {
      // Pilihan tetap berlaku selama aplikasi terbuka.
    }
  }

  Future<void> resetAccent() => setAccent(AppAccent.defaultColor);

  @override
  void didChangePlatformBrightness() {
    if (_mode != ThemeMode.system) return;
    _applyPalette();
    notifyListeners();
  }

  @override
  void dispose() {
    if (_observing) WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  bool _resolveDark() {
    switch (_mode) {
      case ThemeMode.dark:
        return true;
      case ThemeMode.light:
        return false;
      case ThemeMode.system:
        return ui.PlatformDispatcher.instance.platformBrightness ==
            Brightness.dark;
    }
  }

  void _applyPalette() =>
      AppColors.apply(dark: _resolveDark(), accent: _accent);

  static ThemeMode _parse(String? raw) {
    switch (raw) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  static String _serialize(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }
}
