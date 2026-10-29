import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// Judul bagian di Home + tombol "Lihat Semua".
class HomeSectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final VoidCallback onSeeAll;

  const HomeSectionHeader({
    super.key,
    required this.title,
    required this.onSeeAll,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.sectionTitle.copyWith(
                  fontSize: 16,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 1),
                Text(
                  subtitle!,
                  style: AppTextStyles.greetingSubtitle.copyWith(
                    fontSize: 11.5,
                  ),
                ),
              ],
            ],
          ),
        ),
        GestureDetector(
          onTap: onSeeAll,
          child: Row(
            children: [
              Text(
                'Lihat Semua',
                style: AppTextStyles.sectionAction.copyWith(
                  fontSize: 12,
                ),
              ),
              const SizedBox(width: 3),
              const Icon(
                Icons.arrow_forward,
                size: 13,
                color: AppColors.primary,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
