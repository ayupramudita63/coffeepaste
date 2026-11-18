import 'package:coffee_paste/core/storage/theme_storage.dart';
import 'package:coffee_paste/core/theme/app_colors.dart';
import 'package:coffee_paste/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // AppColors bersifat global; kembalikan ke terang setelah tiap test.
  tearDown(() => AppColors.useDark(false));

  group('ThemeProvider', () {
    test('bawaan: ikuti sistem', () async {
      final theme = ThemeProvider(storage: InMemoryThemeStorage());

      await theme.load();

      expect(theme.mode, ThemeMode.system);
    });

    test('load membaca pilihan tersimpan', () async {
      final theme = ThemeProvider(storage: InMemoryThemeStorage('dark'));

      await theme.load();

      expect(theme.mode, ThemeMode.dark);
      expect(theme.isDark, isTrue);
      expect(AppColors.isDark, isTrue);
    });

    test('nilai tersimpan yang tidak dikenal dianggap ikut sistem', () async {
      final theme = ThemeProvider(storage: InMemoryThemeStorage('ungu'));

      await theme.load();

      expect(theme.mode, ThemeMode.system);
    });

    test('setMode mengganti warna, memberi tahu listener, dan menyimpan',
        () async {
      final storage = InMemoryThemeStorage();
      final theme = ThemeProvider(storage: storage);
      var notified = 0;
      theme.addListener(() => notified++);

      await theme.setMode(ThemeMode.dark);

      expect(theme.mode, ThemeMode.dark);
      expect(AppColors.background, AppPalette.dark.background);
      expect(storage.value, 'dark');
      expect(notified, 1);

      await theme.setMode(ThemeMode.light);

      expect(AppColors.background, AppPalette.light.background);
      expect(storage.value, 'light');
      expect(notified, 2);
    });

    test('setMode dengan pilihan yang sama tidak melakukan apa-apa', () async {
      final theme = ThemeProvider(storage: InMemoryThemeStorage());
      var notified = 0;
      theme.addListener(() => notified++);

      await theme.setMode(ThemeMode.system);

      expect(notified, 0);
    });
  });
}
