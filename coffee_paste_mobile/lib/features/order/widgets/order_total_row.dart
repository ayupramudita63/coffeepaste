import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';

/// Baris "Total" + nominal di bagian bawah kartu pesanan.
class OrderTotalRow extends StatelessWidget {
  final int total;
  final bool compact;

  const OrderTotalRow({
    super.key,
    required this.total,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Total',
          style: TextStyle(
            fontSize: compact ? 14 : 16,
            color: compact ? AppColors.textSecondary : AppColors.primary,
            fontWeight: compact ? null : FontWeight.w600,
          ),
        ),
        Text(
          formatRupiah(total),
          style: TextStyle(
            fontSize: compact ? 17 : 21,
            color: AppColors.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
