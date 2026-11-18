import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_style.dart';
import '../../core/theme/app_text_styles.dart';
import '../../features/home/widgets/category_chip_row.dart';
import '../../providers/app_navigation_provider.dart';
import '../../providers/menu_provider.dart';
import '../../shared/widgets/error_retry_view.dart';
import '../../shared/widgets/ios_search_field.dart';
import '../../shared/models/product_model.dart';
import 'widgets/menu_product_tile.dart';
import '../../shared/widgets/cart_icon_button.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  String _searchQuery = '';

  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openProductDetail(ProductModel product) {
    context.push(AppRoutes.productDetail, extra: product);
  }

  @override
  Widget build(BuildContext context) {
    // Kategori terpilih dibaca dari provider, jadi otomatis mengikuti
    // kategori yang diklik di halaman Home.
    final selectedCategoryId =
        context.watch<AppNavigationProvider>().menuCategoryId;

    final menu = context.watch<MenuProvider>();

    final filteredProducts = menu.products.where((product) {
      final matchesCategory =
          selectedCategoryId == 'all' ||
          product.categoryId == selectedCategoryId;

      final matchesSearch =
          _searchQuery.isEmpty ||
          product.name.toLowerCase().contains(_searchQuery.toLowerCase());

      return matchesCategory && matchesSearch;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Judul besar ala iOS (rata kiri) + keranjang di kanan
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppStyle.screenPadding,
                14,
                AppStyle.screenPadding,
                12,
              ),
              child: SizedBox(
                height: 44,
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Menu',
                        style: AppTextStyles.sectionTitle.copyWith(
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.6,
                        ),
                      ),
                    ),
                    const CartIconButton(),
                  ],
                ),
              ),
            ),

            // Cari
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppStyle.screenPadding,
              ),
              child: IosSearchField(
                controller: _searchController,
                hint: 'Cari kopi atau makanan...',
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
            ),

            const SizedBox(height: 14),

            // Kategori (dari backend)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppStyle.screenPadding,
              ),
              child: CategoryChipRow(
                categories: menu.categories,
                selectedCategoryId: selectedCategoryId,
                onTap: (categoryId) {
                  context.read<AppNavigationProvider>().openMenu(
                        categoryId: categoryId,
                      );
                },
              ),
            ),

            const SizedBox(height: 14),

            // Daftar produk
            Expanded(
              child: (menu.isLoading && !menu.hasData)
                  ? Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    )
                  : (menu.isError && !menu.hasData)
                      ? ErrorRetryView(
                          message: menu.errorMessage ??
                              'Terjadi kesalahan. Coba lagi.',
                          onRetry: menu.loadMenu,
                        )
                      : filteredProducts.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 56,
                              color: AppColors.textMuted,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Menu tidak ditemukan',
                              style: AppTextStyles.sectionTitle.copyWith(
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Coba cari dengan kata kunci lain.',
                              textAlign: TextAlign.center,
                              style: AppTextStyles.ratingText,
                            ),
                          ],
                        ),
                      ),
                    )
                  : RefreshIndicator(
                      color: AppColors.primary,
                      onRefresh: menu.loadMenu,
                      child: GridView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      padding: const EdgeInsets.fromLTRB(
                        AppStyle.screenPadding,
                        0,
                        AppStyle.screenPadding,
                        24,
                      ),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: AppStyle.gap,
                        mainAxisSpacing: AppStyle.gap,
                        childAspectRatio: AppStyle.productGridAspect,
                      ),
                      itemCount: filteredProducts.length,
                      itemBuilder: (context, index) {
                        final product = filteredProducts[index];

                        return MenuProductTile(
                          product: product,
                          onTap: () => _openProductDetail(product),
                          onAddTap: () => _openProductDetail(product),
                        );
                      },
                    ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
