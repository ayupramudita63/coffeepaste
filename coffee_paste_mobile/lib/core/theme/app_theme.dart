import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    final base = ThemeData(useMaterial3: true, colorSchemeSeed: AppColors.primary);
    return base.copyWith(
      scaffoldBackgroundColor: AppColors.background,
      textTheme: GoogleFonts.poppinsTextTheme(base.textTheme),
      colorScheme: base.colorScheme.copyWith(primary: AppColors.primary),
    );
  }
}