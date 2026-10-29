import 'package:flutter/material.dart';

import '../../../shared/models/product_model.dart';
import 'home_product_row.dart';
import 'home_section_header.dart';

/// Satu bagian produk di Home: judul + baris produk
/// (dipakai untuk "Menu Terlaris" dan "Menu Baru").
class HomeProductSection extends StatelessWidget {
  final String title;
  final List<ProductModel> products;
  final bool isNew;
  final VoidCallback onSeeAll;
  final ValueChanged<ProductModel> onProductTap;

  const HomeProductSection({
    super.key,
    required this.title,
    required this.products,
    required this.onSeeAll,
    required this.onProductTap,
    this.isNew = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        HomeSectionHeader(
          title: title,
          onSeeAll: onSeeAll,
        ),
        const SizedBox(height: 10),
        HomeProductRow(
          products: products,
          isNew: isNew,
          onTap: onProductTap,
        ),
      ],
    );
  }
}
