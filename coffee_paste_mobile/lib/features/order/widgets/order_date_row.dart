import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/date_formatter.dart';

/// Ikon + tanggal pesanan.
class OrderDateRow extends StatelessWidget {
  final DateTime date;
  final bool compact;

  const OrderDateRow({
    super.key,
    required this.date,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          compact ? Icons.calendar_today_outlined : Icons.access_time,
          size: compact ? 17 : 20,
          color: AppColors.textSecondary,
        ),
        SizedBox(width: compact ? 8 : 10),
        Text(
          formatOrderDate(date),
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: compact ? 13 : 14,
          ),
        ),
      ],
    );
  }
}
