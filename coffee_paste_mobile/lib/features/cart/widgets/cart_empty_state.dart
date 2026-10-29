import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// Tampilan ketika keranjang masih kosong.
class CartEmptyState extends StatelessWidget {
  const CartEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: HugeIcon(
                icon: HugeIcons.strokeRoundedShoppingCart01,
                size: 40,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Keranjang masih kosong',
            style: AppTextStyles.sectionTitle,
          ),
          const SizedBox(height: 6),
          Text(
            'Yuk, pilih menu favoritmu dulu.',
            style: AppTextStyles.greetingSubtitle,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).maybePop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(
                horizontal: 28,
                vertical: 14,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              elevation: 0,
            ),
            child: Text(
              'Lihat Menu',
              style: AppTextStyles.productName.copyWith(
                color: AppColors.textOnPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
