import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/app_navigation_provider.dart';
import '../../providers/menu_provider.dart';
import '../../shared/models/product_model.dart';
import '../../shared/widgets/error_retry_view.dart';
import 'widgets/home_category_section.dart';
import 'widgets/home_header_card.dart';
import 'widgets/home_product_section.dart';
import 'widgets/home_search_bar.dart';
import 'widgets/home_search_result_section.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _searchQuery = '';
  Timer? _searchDebounce;

  // Tunggu sebentar setelah berhenti mengetik supaya halaman tidak dibangun
  // ulang di setiap huruf.
  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 250), () {
      if (!mounted) return;
      setState(() {
        _searchQuery = value.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    super.dispose();
  }

  void _openProductList(String title, List<ProductModel> products) {
    context.push(
      AppRoutes.productList,
      extra: ProductListArgs(title: title, products: products),
    );
  }

  void _openProductDetail(ProductModel product) {
    context.push(AppRoutes.productDetail, extra: product);
  }

  // Berpindah ke tab Menu dan memilih kategori.
  void _goToMenu({String categoryId = 'all'}) {
    context.read<AppNavigationProvider>().openMenu(
          categoryId: categoryId,
        );
  }

  @override
  Widget build(BuildContext context) {
    final selectedCategoryId =
        context.watch<AppNavigationProvider>().menuCategoryId;
    final menu = context.watch<MenuProvider>();

    return Container(
      color: AppColors.background,
      // Bagian atas tidak diberi SafeArea: foto header menempel ke atas layar.
      child: SafeArea(
        top: false,
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: menu.loadMenu,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
            children: [
              const HomeHeaderCard(),
              const SizedBox(height: 14),
              HomeSearchBar(
                onChanged: _onSearchChanged,
              ),
              const SizedBox(height: 22),
              if (_searchQuery.isNotEmpty)
                HomeSearchResultSection(
                  products: menu.search(_searchQuery),
                  onSeeAll: _goToMenu,
                  onProductTap: _openProductDetail,
                )
              else ...[
                HomeCategorySection(
                  selectedCategoryId: selectedCategoryId,
                  onSeeAll: _goToMenu,
                  onCategoryTap: (categoryId) =>
                      _goToMenu(categoryId: categoryId),
                ),
                const SizedBox(height: 24),
                if (menu.isLoading && !menu.hasData)
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 48),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    ),
                  )
                else if (menu.isError && !menu.hasData)
                  ErrorRetryView(
                    message:
                        menu.errorMessage ?? 'Terjadi kesalahan. Coba lagi.',
                    onRetry: menu.loadMenu,
                  )
                else ...[
                  HomeProductSection(
                    title: 'Menu Terlaris',
                    products: menu.bestSellerProducts,
                    onSeeAll: () =>
                        _openProductList('Menu Terlaris', menu.popularProducts),
                    onProductTap: _openProductDetail,
                  ),
                  const SizedBox(height: 22),
                  HomeProductSection(
                    title: 'Menu Baru',
                    products: menu.newProducts,
                    isNew: true,
                    onSeeAll: () =>
                        _openProductList('Menu Baru', menu.newProducts),
                    onProductTap: _openProductDetail,
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }
}
