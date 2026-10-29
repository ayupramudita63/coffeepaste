import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// Satu baris rincian harga: label di kiri, nominal di kanan.
class PriceRow extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;

  const PriceRow({
    super.key,
    required this.label,
    required this.value,
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) {
    final style = bold
        ? AppTextStyles.productName.copyWith(
            fontSize: 15,
          )
        : AppTextStyles.greetingSubtitle.copyWith(
            color: AppColors.textPrimary,
          );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: style,
        ),
        Text(
          value,
          style: style,
        ),
      ],
    );
  }
}
