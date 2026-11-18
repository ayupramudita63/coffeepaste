import 'package:flutter/material.dart';

/// Satu pilihan warna tema siap pakai.
class AccentOption {
  final String id;
  final String name;
  final Color color;

  const AccentOption(this.id, this.name, this.color);
}

/// Pilihan dan aturan warna tema (aksen) yang bisa diatur pengguna.
class AppAccent {
  AppAccent._();

  /// Hijau Coffee Paste (warna merek, bawaan).
  static const Color defaultColor = Color(0xFF255F38);

  static const List<AccentOption> presets = [
    AccentOption('hijau', 'Hijau', Color(0xFF255F38)),
    AccentOption('biru', 'Biru', Color(0xFF0A6FD8)),
    AccentOption('indigo', 'Indigo', Color(0xFF4A4AC4)),
    AccentOption('ungu', 'Ungu', Color(0xFF8A44BF)),
    AccentOption('pink', 'Pink', Color(0xFFC72C65)),
    AccentOption('merah', 'Merah', Color(0xFFD0342C)),
    AccentOption('oranye', 'Oranye', Color(0xFFD95A0B)),
    AccentOption('cokelat', 'Cokelat', Color(0xFF8B5E3C)),
    AccentOption('teal', 'Teal', Color(0xFF0E8A86)),
    AccentOption('grafit', 'Grafit', Color(0xFF3A3A3C)),
  ];

  static const double _minLightness = 0.20;
  static const double _maxLightness = 0.48;

  /// Menjaga warna tetap cukup gelap supaya teks putih di atas tombol
  /// dan ikon aksen tetap terbaca. Warna yang sudah sesuai tidak diubah.
  static Color normalize(Color color) {
    final hsl = HSLColor.fromColor(color);
    final lightness = hsl.lightness;
    if (lightness >= _minLightness && lightness <= _maxLightness) {
      return Color(color.toARGB32() | 0xFF000000);
    }
    return hsl
        .withLightness(lightness.clamp(_minLightness, _maxLightness).toDouble())
        .withAlpha(1.0)
        .toColor();
  }

  /// Versi aksen untuk mode gelap: dibuat lebih terang agar terbaca
  /// di latar gelap.
  static Color forDark(Color accent) {
    final hsl = HSLColor.fromColor(accent);
    final lightness = (hsl.lightness + 0.14).clamp(0.46, 0.64).toDouble();
    return hsl.withLightness(lightness).withAlpha(1.0).toColor();
  }

  static bool same(Color a, Color b) =>
      normalize(a).toARGB32() == normalize(b).toARGB32();

  static bool isDefault(Color color) => same(color, defaultColor);

  /// Dipakai untuk menyimpan pilihan warna.
  static String encode(Color color) =>
      normalize(color).toARGB32().toRadixString(16).padLeft(8, '0');

  static Color? decode(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    final value = int.tryParse(raw, radix: 16);
    if (value == null) return null;
    return normalize(Color(value));
  }
}
