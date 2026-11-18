import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Ukuran dan gaya bersama supaya semua kartu seragam dan simetris:
/// jarak dalam sama di keempat sisi, sudut membulat sama, lebar penuh.
class AppStyle {
  AppStyle._();

  /// Jarak tepi layar kiri dan kanan.
  static const double screenPadding = 20;

  /// Jarak antar kartu (horizontal dan vertikal).
  static const double gap = 12;

  /// Jarak dalam kartu (sama di semua sisi).
  static const double cardPadding = 16;

  /// Sudut kartu besar, kartu produk, dan elemen kecil di dalam kartu.
  static const double cardRadius = 20;
  static const double productRadius = 18;
  static const double innerRadius = 14;

  /// Perbandingan lebar : tinggi kartu produk di grid 2 kolom.
  static const double productGridAspect = 0.66;

  static List<BoxShadow> get softShadow => AppColors.isDark
      ? const []
      : const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 14,
            offset: Offset(0, 3),
          ),
        ];

  /// Dekorasi kartu: putih/abu gelap, tanpa garis tepi, bayangan tipis.
  static BoxDecoration card({Color? color, double radius = cardRadius}) {
    return BoxDecoration(
      color: color ?? AppColors.surface,
      borderRadius: BorderRadius.circular(radius),
      boxShadow: softShadow,
    );
  }

  /// Garis pemisah tipis ala iOS.
  static Widget hairline({double indent = 0}) => Padding(
        padding: EdgeInsets.only(left: indent),
        child: Container(height: 0.5, color: AppColors.border),
      );
}
