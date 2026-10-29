import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// Tampilan ketika produk yang dicari tidak ditemukan.
class HomeEmptySearchResult extends StatelessWidget {
  const HomeEmptySearchResult({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.search_off,
              size: 44,
              color: AppColors.primary.withOpacity(0.7),
            ),
            const SizedBox(height: 10),
            const Text(
              'Produk tidak ditemukan',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Coba kata kunci lainnya.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
