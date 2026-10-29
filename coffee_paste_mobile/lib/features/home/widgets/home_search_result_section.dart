import 'package:flutter/material.dart';

import '../../../shared/models/product_model.dart';
import 'home_empty_search_result.dart';
import 'home_product_row.dart';
import 'home_section_header.dart';

/// Bagian "Hasil Pencarian" yang tampil saat pengguna mengetik di kolom cari.
class HomeSearchResultSection extends StatelessWidget {
  final List<ProductModel> products;
  final VoidCallback onSeeAll;
  final ValueChanged<ProductModel> onProductTap;

  const HomeSearchResultSection({
    super.key,
    required this.products,
    required this.onSeeAll,
    required this.onProductTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        HomeSectionHeader(
          title: 'Hasil Pencarian',
          subtitle: '${products.length} produk ditemukan',
          onSeeAll: onSeeAll,
        ),
        const SizedBox(height: 12),
        if (products.isEmpty)
          const HomeEmptySearchResult()
        else
          HomeProductRow(
            products: products,
            onTap: onProductTap,
          ),
      ],
    );
  }
}
