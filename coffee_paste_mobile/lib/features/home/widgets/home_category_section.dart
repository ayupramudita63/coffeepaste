import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/menu_provider.dart';
import 'category_chip_row.dart';
import 'home_section_header.dart';

/// Bagian "Jelajahi Menu": judul + deretan chip kategori.
class HomeCategorySection extends StatelessWidget {
  final String selectedCategoryId;
  final VoidCallback onSeeAll;
  final ValueChanged<String> onCategoryTap;

  const HomeCategorySection({
    super.key,
    required this.selectedCategoryId,
    required this.onSeeAll,
    required this.onCategoryTap,
  });

  @override
  Widget build(BuildContext context) {
    final categories = context.watch<MenuProvider>().categories;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        HomeSectionHeader(
          title: 'Jelajahi Menu',
          subtitle: 'Temukan minuman yang cocok untukmu',
          onSeeAll: onSeeAll,
        ),
        const SizedBox(height: 12),
        CategoryChipRow(
          categories: categories,
          selectedCategoryId: selectedCategoryId,
          onTap: onCategoryTap,
        ),
      ],
    );
  }
}
