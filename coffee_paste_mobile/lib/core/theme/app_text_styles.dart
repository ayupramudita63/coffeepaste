import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  static TextStyle get greetingTitle => GoogleFonts.poppins(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        height: 1.25,
      );

  static TextStyle get greetingSubtitle => GoogleFonts.poppins(
        fontSize: 13,
        color: AppColors.textSecondary,
      );

  static TextStyle get sectionTitle => GoogleFonts.poppins(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      );

  static TextStyle get sectionAction => GoogleFonts.poppins(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: AppColors.primary,
      );

  static TextStyle get categoryLabel => GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
      );

  static TextStyle get productName => GoogleFonts.poppins(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      );

  static TextStyle get productPrice => GoogleFonts.poppins(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary,
      );

  static TextStyle get ratingText => GoogleFonts.poppins(
        fontSize: 12,
        color: AppColors.textSecondary,
      );

  static TextStyle get searchHint => GoogleFonts.poppins(
        fontSize: 13,
        color: AppColors.textMuted,
      );
}