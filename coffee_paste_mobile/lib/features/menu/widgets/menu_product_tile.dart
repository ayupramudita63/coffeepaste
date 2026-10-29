import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/models/product_model.dart';
import '../../../shared/widgets/app_image.dart';

class MenuProductTile extends StatelessWidget {
  final ProductModel product;
  final VoidCallback onTap;
  final VoidCallback onAddTap;

  const MenuProductTile({
    super.key,
    required this.product,
    required this.onTap,
    required this.onAddTap,
  });

  String _formatPrice(int price) {
    final s = price.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      final posFromRight = s.length - i;
      buffer.write(s[i]);
      if (posFromRight > 1 && posFromRight % 3 == 1) buffer.write('.');
    }
    return 'Rp $buffer';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.surfaceMuted),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: AspectRatio(
                aspectRatio: 4 / 3,
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
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    product.name,
                    style: AppTextStyles.productName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.description,
                    style: AppTextStyles.ratingText,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _formatPrice(product.price),
                          style: AppTextStyles.productPrice,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      GestureDetector(
                        onTap: onAddTap,
                        child: Container(
                          width: 26,
                          height: 26,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: HugeIcon(
                            icon: HugeIcons.strokeRoundedCirclePlus,
                            size: 14,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}