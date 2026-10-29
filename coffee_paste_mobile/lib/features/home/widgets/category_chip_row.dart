import 'package:flutter/material.dart';

import '../../../shared/models/category_model.dart';
import 'home_category_chip.dart';

/// Deretan chip kategori. Kategori 4-5 buah dibagi rata selebar layar,
/// selain itu dibuat bisa digeser ke samping.
class CategoryChipRow extends StatelessWidget {
  final List<CategoryModel> categories;
  final String selectedCategoryId;
  final ValueChanged<String> onTap;

  const CategoryChipRow({
    super.key,
    required this.categories,
    required this.selectedCategoryId,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (categories.length <= 1) return const SizedBox.shrink();

    Widget chip(CategoryModel category) {
      return HomeCategoryChip(
        category: category,
        isSelected: category.id == selectedCategoryId,
        onTap: () => onTap(category.id),
      );
    }

    final fitsScreen = categories.length >= 4 && categories.length <= 5;

    if (fitsScreen) {
      return Row(
        children: [
          for (int i = 0; i < categories.length; i++) ...[
            if (i > 0) const SizedBox(width: 8),
            Expanded(child: chip(categories[i])),
          ],
        ],
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (int i = 0; i < categories.length; i++) ...[
            if (i > 0) const SizedBox(width: 8),
            SizedBox(width: 78, child: chip(categories[i])),
          ],
        ],
      ),
    );
  }
}
