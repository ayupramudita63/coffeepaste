import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import 'dashed_divider.dart';
import 'price_row.dart';

/// Kartu "Rincian Pembayaran": subtotal, PPN, dan total pembayaran.
class PaymentSummaryCard extends StatelessWidget {
  final int subtotal;
  final int tax;
  final int total;

  const PaymentSummaryCard({
    super.key,
    required this.subtotal,
    required this.tax,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Column(
        children: [
          PriceRow(
            label: 'Subtotal',
            value: formatRupiah(subtotal),
          ),
          const SizedBox(height: 10),
          PriceRow(
            label: 'PPN (11%)',
            value: formatRupiah(tax),
          ),
          const SizedBox(height: 12),
          const DashedDivider(),
          const SizedBox(height: 12),
          PriceRow(
            label: 'Total Pembayaran',
            value: formatRupiah(total),
            bold: true,
          ),
        ],
      ),
    );
  }
}
