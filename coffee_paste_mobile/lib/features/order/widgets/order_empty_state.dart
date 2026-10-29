import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// Tampilan ketika belum ada pesanan / riwayat.
class OrderEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const OrderEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 60,
              color: AppColors.primary.withOpacity(0.35),
            ),
            const SizedBox(height: 18),
            Text(
              title,
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
