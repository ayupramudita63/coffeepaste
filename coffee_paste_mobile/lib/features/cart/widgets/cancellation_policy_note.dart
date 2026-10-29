import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// Catatan kebijakan pembatalan di bawah rincian pembayaran.
class CancellationPolicyNote extends StatelessWidget {
  const CancellationPolicyNote({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(
          Icons.info_outline,
          size: 22,
          color: AppColors.textMuted,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Kebijakan Pembatalan',
                style: AppTextStyles.productName.copyWith(
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Pesanan masih bisa dibatalkan dari aplikasi selama '
                'belum dibayar dan belum diproses kasir. Setelah itu, '
                'pembatalan hanya bisa lewat kasir.',
                style: AppTextStyles.ratingText.copyWith(
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
