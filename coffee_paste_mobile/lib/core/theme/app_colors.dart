import 'package:flutter/material.dart';

import 'app_accent.dart';

/// Satu set warna lengkap untuk satu mode tampilan.
class AppPalette {
  final Brightness brightness;
  final Color primary;
  final Color primaryLight;
  final Color background;
  final Color authBackground;
  final Color surface;
  final Color surfaceMuted;
  final Color inputBackground;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color textOnPrimary;
  final Color border;
  final Color rating;
  final Color favorite;

  const AppPalette({
    required this.brightness,
    required this.primary,
    required this.primaryLight,
    required this.background,
    required this.authBackground,
    required this.surface,
    required this.surfaceMuted,
    required this.inputBackground,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.textOnPrimary,
    required this.border,
    required this.rating,
    required this.favorite,
  });

  /// Menyusun palet bergaya iOS (latar grup abu-abu lembut, kartu putih /
  /// abu gelap) yang diberi sedikit semburat warna aksen pilihan pengguna.
  factory AppPalette.build({required bool dark, required Color accent}) {
    final normalized = AppAccent.normalize(accent);
    final primary = dark ? AppAccent.forDark(normalized) : normalized;

    Color tint(Color base, double amount) => Color.lerp(base, primary, amount)!;

    if (dark) {
      return AppPalette(
        brightness: Brightness.dark,
        primary: primary,
        primaryLight: tint(const Color(0xFF1C1C1E), 0.26),
        background: tint(const Color(0xFF000000), 0.07),
        authBackground: tint(const Color(0xFF000000), 0.07),
        surface: tint(const Color(0xFF1C1C1E), 0.05),
        surfaceMuted: tint(const Color(0xFF2C2C2E), 0.05),
        inputBackground: tint(const Color(0xFF2C2C2E), 0.06),
        textPrimary: const Color(0xFFF5F5F7),
        textSecondary: const Color(0xFFA1A1A6),
        textMuted: const Color(0xFF727278),
        textOnPrimary: const Color(0xFFFFFFFF),
        border: tint(const Color(0xFF38383A), 0.05),
        rating: const Color(0xFFFFB340),
        favorite: const Color(0xFFFF6B60),
      );
    }

    return AppPalette(
      brightness: Brightness.light,
      primary: primary,
      primaryLight: tint(const Color(0xFFFFFFFF), 0.12),
      background: tint(const Color(0xFFF2F2F7), 0.04),
      authBackground: tint(const Color(0xFFF2F2F7), 0.04),
      surface: const Color(0xFFFFFFFF),
      surfaceMuted: tint(const Color(0xFFE9E9EE), 0.05),
      inputBackground: tint(const Color(0xFFEAEAEF), 0.04),
      textPrimary: const Color(0xFF1C1C1E),
      textSecondary: const Color(0xFF6C6C70),
      textMuted: const Color(0xFF9A9AA0),
      textOnPrimary: const Color(0xFFFFFFFF),
      border: const Color(0xFFE3E3E8),
      rating: const Color(0xFFFF9F0A),
      favorite: const Color(0xFFFF3B30),
    );
  }

  /// Palet bawaan (aksen hijau Coffee Paste).
  static final AppPalette light =
      AppPalette.build(dark: false, accent: AppAccent.defaultColor);

  static final AppPalette dark =
      AppPalette.build(dark: true, accent: AppAccent.defaultColor);
}

/// Warna aplikasi. Nilainya mengikuti mode tampilan dan warna tema yang
/// sedang aktif (diatur oleh `ThemeProvider`).
///
/// Karena nilainya bisa berubah, `AppColors.x` bukan konstanta: jangan
/// dipakai di dalam `const`.
class AppColors {
  AppColors._();

  static bool _dark = false;
  static Color _accent = AppAccent.defaultColor;
  static AppPalette _current = AppPalette.light;

  static AppPalette get current => _current;

  static bool get isDark => _current.brightness == Brightness.dark;

  /// Warna tema (aksen) yang dipilih pengguna.
  static Color get accent => _accent;

  /// Atur mode dan, bila diberikan, warna tema sekaligus.
  static void apply({required bool dark, Color? accent}) {
    _dark = dark;
    if (accent != null) _accent = AppAccent.normalize(accent);
    _current = AppPalette.build(dark: _dark, accent: _accent);
  }

  static void useDark(bool dark) => apply(dark: dark);

  /// Palet untuk mode tertentu dengan warna tema yang sedang aktif.
  static AppPalette paletteFor({required bool dark}) =>
      AppPalette.build(dark: dark, accent: _accent);

  /// Warna merek versi terang (untuk splash dan struk yang selalu berlatar
  /// putih/berwarna, apa pun mode tampilannya).
  static Color get brand => paletteFor(dark: false).primary;

  static Color get primary => _current.primary;
  static Color get primaryLight => _current.primaryLight;

  static Color get background => _current.background;
  static Color get authBackground => _current.authBackground;
  static Color get surface => _current.surface;
  static Color get surfaceMuted => _current.surfaceMuted;
  static Color get inputBackground => _current.inputBackground;

  static Color get textPrimary => _current.textPrimary;
  static Color get textSecondary => _current.textSecondary;
  static Color get textMuted => _current.textMuted;
  static Color get textOnPrimary => _current.textOnPrimary;

  static Color get border => _current.border;

  static Color get rating => _current.rating;
  static Color get favorite => _current.favorite;
}
