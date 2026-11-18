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
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 1),
                Text(
                  subtitle!,
                  style: AppTextStyles.greetingSubtitle.copyWith(
                    fontSize: 12,
                  ),
                ),
              ],
            ],
          ),
        ),
        GestureDetector(
          onTap: onSeeAll,
          behavior: HitTestBehavior.opaque,
          child: Row(
            children: [
              Text(
                'Lihat Semua',
                style: AppTextStyles.sectionAction.copyWith(
                  fontSize: 13,
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: AppColors.primary,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
