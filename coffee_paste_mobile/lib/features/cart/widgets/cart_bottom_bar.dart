import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// Bar bawah berisi tombol "Pesan Sekarang".
class CartBottomBar extends StatelessWidget {
  final VoidCallback onOrderTap;

  const CartBottomBar({
    super.key,
    required this.onOrderTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
      decoration: BoxDecoration(
        color: AppColors.authBackground,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: onOrderTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            padding: const EdgeInsets.symmetric(
              vertical: 18,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            elevation: 0,
          ),
          child: Text(
            'Pesan Sekarang',
            style: AppTextStyles.productName.copyWith(
              color: AppColors.textOnPrimary,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}
