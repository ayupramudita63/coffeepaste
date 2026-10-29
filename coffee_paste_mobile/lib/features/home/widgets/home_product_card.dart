import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../shared/models/product_model.dart';
import '../../../shared/widgets/app_image.dart';

class HomeProductCard extends StatelessWidget {
  final ProductModel product;
  final bool isNew;
  final VoidCallback onTap;
  final VoidCallback onAddTap;

  const HomeProductCard({
    super.key,
    required this.product,
    required this.onTap,
    required this.onAddTap,
    this.isNew = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  child: AspectRatio(
                    aspectRatio: 1.3,
                    child: SizedBox(
                      width: double.infinity,
                      child: product.imageUrl != null
                          ? appImage(product.imageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  _placeholder(),
                            )
                          : _placeholder(),
                    ),
                  ),
                ),
                if (isNew)
                  Positioned(
                    top: 6,
                    left: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: const Text(
                        'NEW',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 8.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(9, 7, 7, 7),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.productName.copyWith(fontSize: 11.5),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    formatRupiah(product.price),
                    style: AppTextStyles.productPrice.copyWith(
                      fontSize: 11.5,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        size: 12,
                        color: AppColors.rating,
                      ),
                      const SizedBox(width: 2),
                      Expanded(
                        child: Text(
                          '${product.rating} (${product.ratingCount})',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.ratingText.copyWith(
                            fontSize: 9.5,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: onAddTap,
                        child: Container(
                          width: 22,
                          height: 22,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.add,
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

  Widget _placeholder() {
    return Container(
      color: AppColors.surfaceMuted,
      child: const Icon(Icons.local_cafe, color: AppColors.primary, size: 28),
    );
  }
}