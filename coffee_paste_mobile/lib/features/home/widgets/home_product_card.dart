import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_style.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../shared/models/product_model.dart';
import '../../../shared/widgets/app_image.dart';

/// Kartu produk kecil di baris geser Home. Tinggi kartu ditentukan oleh
/// pembungkusnya (semua kartu satu baris sama tinggi), jadi foto, nama,
/// harga, dan tombol tambah selalu berada di posisi yang sama.
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
        clipBehavior: Clip.antiAlias,
        decoration: AppStyle.card(radius: AppStyle.productRadius),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AspectRatio(
              aspectRatio: 1.25,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  product.imageUrl != null
                      ? appImage(
                          product.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              _placeholder(),
                        )
                      : _placeholder(),
                  if (isNew)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(8),
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
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.productName.copyWith(fontSize: 12),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      formatRupiah(product.price),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.productPrice.copyWith(
                        fontSize: 11.5,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Icon(
                          Icons.star_rounded,
                          size: 13,
                          color: AppColors.rating,
                        ),
                        const SizedBox(width: 2),
                        Expanded(
                          child: Text(
                            '${product.rating} (${product.ratingCount})',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.ratingText.copyWith(
                              fontSize: 10,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: onAddTap,
                          behavior: HitTestBehavior.opaque,
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.add_rounded,
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
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
      child: Icon(Icons.local_cafe, color: AppColors.primary, size: 28),
    );
  }
}
