import 'package:coffee_paste/core/storage/theme_storage.dart';
import 'package:coffee_paste/core/theme/app_accent.dart';
import 'package:coffee_paste/core/theme/app_colors.dart';
import 'package:coffee_paste/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() => AppColors.apply(dark: false, accent: AppAccent.defaultColor));

  group('warna tema', () {
    test('bawaan memakai hijau Coffee Paste', () {
      final theme = ThemeProvider(storage: InMemoryThemeStorage());

      expect(AppAccent.isDefault(theme.accent), isTrue);
      expect(AppColors.primary, AppPalette.light.primary);
    });

    test('setAccent mengubah warna utama dan menyimpannya', () async {
      final storage = InMemoryThemeStorage();
      final theme = ThemeProvider(storage: storage);
      final blue = AppAccent.presets.firstWhere((o) => o.id == 'biru').color;

      await theme.setAccent(blue);

      expect(AppAccent.same(theme.accent, blue), isTrue);
      expect(AppColors.primary, isNot(AppPalette.light.primary));
      expect(storage.accentValue, AppAccent.encode(blue));
    });

    test('pilihan tersimpan dibaca saat load', () async {
      final orange =
          AppAccent.presets.firstWhere((o) => o.id == 'oranye').color;
      final theme = ThemeProvider(
        storage: InMemoryThemeStorage(null, AppAccent.encode(orange)),
      );

      await theme.load();

      expect(AppAccent.same(theme.accent, orange), isTrue);
    });

    test('data tersimpan yang rusak dipakai sebagai warna bawaan', () async {
      final theme = ThemeProvider(
        storage: InMemoryThemeStorage(null, 'bukan-warna'),
      );

      await theme.load();

      expect(AppAccent.isDefault(theme.accent), isTrue);
    });

    test('warna terlalu terang disesuaikan agar teks putih terbaca', () {
      final adjusted = AppAccent.normalize(const Color(0xFFFFEB3B));

      expect(HSLColor.fromColor(adjusted).lightness, lessThanOrEqualTo(0.481));
    });

    test('resetAccent mengembalikan warna bawaan', () async {
      final theme = ThemeProvider(storage: InMemoryThemeStorage());
      await theme.setAccent(const Color(0xFF8A44BF));

      await theme.resetAccent();

      expect(AppAccent.isDefault(theme.accent), isTrue);
    });

    test('mode gelap memakai versi aksen yang lebih terang', () async {
      final theme = ThemeProvider(storage: InMemoryThemeStorage());
      await theme.setAccent(const Color(0xFF0A6FD8));
      final light = HSLColor.fromColor(AppColors.primary).lightness;

      await theme.setMode(ThemeMode.dark);
      final dark = HSLColor.fromColor(AppColors.primary).lightness;

      expect(dark, greaterThan(light));
    });
  });
}
