import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:coffee_paste/core/router/app_router.dart';
import 'package:coffee_paste/core/theme/app_colors.dart';
import 'package:coffee_paste/core/theme/app_text_styles.dart';
import 'package:coffee_paste/shared/models/product_model.dart';
import 'package:coffee_paste/shared/widgets/cart_icon_button.dart';
import 'package:coffee_paste/features/menu/widgets/menu_product_tile.dart';

/// Halaman daftar produk yang dipakai ulang untuk tombol "Lihat Semua"
/// (Menu Terlaris, Menu Baru, dll).
class ProductListScreen extends StatelessWidget {
  final String title;
  final List<ProductModel> products;

  const ProductListScreen({
    super.key,
    required this.title,
    required this.products,
  });

  void _openProductDetail(BuildContext context, ProductModel product) {
    context.push(AppRoutes.productDetail, extra: product);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header: back, judul, keranjang
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              child: SizedBox(
                height: 44,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: GestureDetector(
                        onTap: () => Navigator.of(context).maybePop(),
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: const BoxDecoration(
                            color: AppColors.surface,
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: HugeIcon(
                              icon: HugeIcons.strokeRoundedArrowLeft01,
                              size: 18,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Text(
                      title,
                      style: AppTextStyles.sectionTitle.copyWith(fontSize: 22),
                    ),
                    const Align(
                      alignment: Alignment.centerRight,
                      child: CartIconButton(),
                    ),
                  ],
                ),
              ),
            ),

            // Daftar produk
            Expanded(
              child: products.isEmpty
                  ? Center(
                      child: Text(
                        'Belum ada menu',
                        style: AppTextStyles.ratingText,
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.68,
                      ),
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        final product = products[index];

                        return MenuProductTile(
                          product: product,
                          onTap: () => _openProductDetail(context, product),
                          onAddTap: () => _openProductDetail(context, product),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}