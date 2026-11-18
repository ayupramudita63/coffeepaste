import 'package:flutter/cupertino.dart' show CupertinoPageTransitionsBuilder;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme =>
      _build(AppColors.paletteFor(dark: false));

  static ThemeData get darkTheme => _build(AppColors.paletteFor(dark: true));

  static ThemeData _build(AppPalette p) {
    final base = ThemeData(
      useMaterial3: true,
      brightness: p.brightness,
      colorSchemeSeed: p.primary,
    );

    final buttonShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(14),
    );
    final buttonText = GoogleFonts.poppins(
      fontSize: 15,
      fontWeight: FontWeight.w600,
    );

    return base.copyWith(
      scaffoldBackgroundColor: p.background,
      canvasColor: p.background,
      textTheme: _textTheme(base, p),
      // Tanpa riak Material: sentuhan terasa seperti iOS.
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
      // Transisi geser ala iOS dan usap dari tepi kiri untuk kembali.
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.windows: CupertinoPageTransitionsBuilder(),
          TargetPlatform.linux: CupertinoPageTransitionsBuilder(),
          TargetPlatform.fuchsia: CupertinoPageTransitionsBuilder(),
        },
      ),
      colorScheme: base.colorScheme.copyWith(
        primary: p.primary,
        onPrimary: p.textOnPrimary,
        surface: p.surface,
        onSurface: p.textPrimary,
      ),
      dividerColor: p.border,
      dividerTheme: DividerThemeData(
        color: p.border,
        thickness: 0.5,
        space: 0.5,
      ),
      cardColor: p.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: p.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        foregroundColor: p.textPrimary,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: p.surface,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: p.primary,
          foregroundColor: p.textOnPrimary,
          elevation: 0,
          minimumSize: const Size(0, 50),
          shape: buttonShape,
          textStyle: buttonText,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: p.primary,
          foregroundColor: p.textOnPrimary,
          elevation: 0,
          shape: buttonShape,
          textStyle: buttonText,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: p.primary,
          side: BorderSide(color: p.primary.withOpacity(0.35)),
          shape: buttonShape,
          textStyle: buttonText,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: p.primary),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: p.primary),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }

  static TextTheme _textTheme(ThemeData base, AppPalette p) {
    final poppins = GoogleFonts.poppinsTextTheme(base.textTheme);
    // Mode terang tetap memakai warna teks bawaan; mode gelap perlu
    // warna teks terang agar terbaca.
    if (p.brightness == Brightness.light) return poppins;
    return poppins.apply(
      bodyColor: p.textPrimary,
      displayColor: p.textPrimary,
    );
  }
}
