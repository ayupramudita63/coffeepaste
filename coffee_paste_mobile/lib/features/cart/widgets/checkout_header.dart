import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// Judul "Checkout" dengan tombol kembali.
class CheckoutHeader extends StatelessWidget {
  const CheckoutHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: () => Navigator.of(context).maybePop(),
              child: Container(
                width: 42,
                height: 42,
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: HugeIcon(
                    icon: HugeIcons.strokeRoundedArrowLeft01,
                    size: 18,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
          ),
          Text(
            'Checkout',
            style: AppTextStyles.greetingTitle.copyWith(
              fontSize: 26,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
