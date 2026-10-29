import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/models/category_model.dart';

class HomeCategoryChip extends StatelessWidget {
  final CategoryModel category;
  final bool isSelected;
  final VoidCallback onTap;

  const HomeCategoryChip({
    super.key,
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 66,
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary
              : AppColors.primary.withOpacity(0.07),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              category.icon,
              size: 22,
              color: isSelected ? Colors.white : AppColors.primary,
            ),
            const SizedBox(height: 5),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  category.label,
                  maxLines: 1,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.productName.copyWith(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : AppColors.primary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}