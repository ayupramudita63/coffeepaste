import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../features/home/widgets/category_chip_row.dart';
import '../../providers/app_navigation_provider.dart';
import '../../providers/menu_provider.dart';
import '../../shared/widgets/error_retry_view.dart';
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
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: SizedBox(
                height: 32,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Center(
                      child: Text(
                        'Menu',
                        style: AppTextStyles.sectionTitle.copyWith(
                          fontSize: 28,
                        ),
                      ),
                    ),
                    const Align(
                      alignment: Alignment.centerRight,
                      child: CartIconButton(),
                    ),
                  ],
                ),
              ),
            ),

            // Search
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Cari kopi atau makanan...',
                  prefixIcon: const Icon(
                    Icons.search,
                    color: AppColors.textSecondary,
                  ),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _searchQuery = '';
                            });
                          },
                          icon: const Icon(
                            Icons.close,
                            color: AppColors.textSecondary,
                          ),
                        )
                      : null,
                  filled: true,
                  fillColor: AppColors.surfaceMuted,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: const BorderSide(
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Kategori (dari backend)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
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

            const SizedBox(height: 16),

            // Daftar produk
            Expanded(
              child: (menu.isLoading && !menu.hasData)
                  ? const Center(
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
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.68,
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