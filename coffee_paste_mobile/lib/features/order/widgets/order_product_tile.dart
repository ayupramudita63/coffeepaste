import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../models/order_model.dart';
import '../../../shared/widgets/app_image.dart';

/// Satu baris produk di dalam kartu pesanan.
///
/// [compact] = true dipakai di kartu Riwayat (ukuran lebih kecil).
class OrderProductTile extends StatelessWidget {
  final OrderItem item;
  final bool compact;

  const OrderProductTile({
    super.key,
    required this.item,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final imageSize = compact ? 62.0 : 74.0;
    final hasVariant = item.variant != null && item.variant!.isNotEmpty;

    return Row(
      crossAxisAlignment:
          compact ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(compact ? 10 : 12),
          child: appImage(item.imagePath,
            width: imageSize,
            height: imageSize,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: imageSize,
                height: imageSize,
                color: AppColors.background,
                child: Icon(
                  Icons.coffee,
                  color: AppColors.primary,
                ),
              );
            },
          ),
        ),
        SizedBox(width: compact ? 12 : 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.name,
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: compact ? 14 : 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (hasVariant) ...[
                SizedBox(height: compact ? 4 : 5),
                Text(
                  item.variant!,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: compact ? 11 : 12,
                  ),
                ),
              ],
              SizedBox(height: compact ? 5 : 8),
              Text(
                '× ${item.quantity}',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: compact ? 12 : 13,
                ),
              ),
            ],
          ),
        ),
        if (!compact) const SizedBox(width: 8),
        Text(
          formatRupiah(item.subtotal),
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: compact ? 13 : 14,
            fontWeight: compact ? null : FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
