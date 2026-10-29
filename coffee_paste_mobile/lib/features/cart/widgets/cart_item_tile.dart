import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/currency_formatter.dart';
import '../cart_item_model.dart';
import '../../../shared/widgets/app_image.dart';

class CartItemTile extends StatelessWidget {
  final CartItemModel item;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;

  const CartItemTile({
    super.key,
    required this.item,
    required this.onIncrease,
    required this.onDecrease,
  });

  @override
  Widget build(BuildContext context) {
    final product = item.product;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: 80,
              height: 80,
              child: product.imageUrl != null
                  ? appImage(product.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: AppColors.surfaceMuted,
                        child: const Icon(Icons.local_cafe, color: AppColors.primary),
                      ),
                    )
                  : Container(
                      color: AppColors.surfaceMuted,
                      child: const Icon(Icons.local_cafe, color: AppColors.primary),
                    ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: AppTextStyles.productName.copyWith(fontSize: 15),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (item.optionsSummary.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    item.optionsSummary,
                    style: AppTextStyles.ratingText,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 8),
                Text(
                  formatRupiah(item.subtotal),
                  style: AppTextStyles.productName.copyWith(
                    color: AppColors.primary,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _QuantityStepper(
            quantity: item.quantity,
            onIncrease: onIncrease,
            onDecrease: onDecrease,
          ),
        ],
      ),
    );
  }
}

class _QuantityStepper extends StatelessWidget {
  final int quantity;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;

  const _QuantityStepper({
    required this.quantity,
    required this.onIncrease,
    required this.onDecrease,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: onDecrease,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: HugeIcon(
                icon: HugeIcons.strokeRoundedRemove01,
                size: 16,
                color: AppColors.primary,
              ),
            ),
          ),
          Text('$quantity', style: AppTextStyles.productName),
          GestureDetector(
            onTap: onIncrease,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: HugeIcon(
                icon: HugeIcons.strokeRoundedAdd01,
                size: 16,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}