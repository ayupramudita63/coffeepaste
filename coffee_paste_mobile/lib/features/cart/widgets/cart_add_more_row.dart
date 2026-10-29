import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// "Ada tambahan lagi?" + tombol Tambah.
class CartAddMoreRow extends StatelessWidget {
  final VoidCallback onAddTap;

  const CartAddMoreRow({
    super.key,
    required this.onAddTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ada tambahan lagi?',
                style: AppTextStyles.sectionTitle,
              ),
              const SizedBox(height: 4),
              Text(
                'Kamu masih bisa tambah menu lain, ya.',
                style: AppTextStyles.greetingSubtitle.copyWith(
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        OutlinedButton.icon(
          onPressed: onAddTap,
          icon: const HugeIcon(
            icon: HugeIcons.strokeRoundedCirclePlus,
            size: 18,
            color: AppColors.primary,
          ),
          label: Text(
            'Tambah',
            style: AppTextStyles.sectionAction,
          ),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(
              color: AppColors.primary,
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
        ),
      ],
    );
  }
}
