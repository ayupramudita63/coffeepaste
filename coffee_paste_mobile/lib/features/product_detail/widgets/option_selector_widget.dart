import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class OptionItem {
  final String label;
  final List<List<dynamic>> icon;

  const OptionItem({required this.label, required this.icon});
}

/// Widget pilihan tunggal (single-select) yang dipakai untuk
/// Ice Cube, Gula, dan Ukuran di halaman Detail Produk.
class OptionSelectorWidget extends StatelessWidget {
  final List<List<dynamic>> groupIcon;
  final String title;
  final String subtitle;
  final List<OptionItem> options;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  const OptionSelectorWidget({
    super.key,
    required this.groupIcon,
    required this.title,
    required this.subtitle,
    required this.options,
    required this.selectedIndex,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.surfaceMuted),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: HugeIcon(icon: groupIcon, size: 18, color: AppColors.primary),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTextStyles.productName),
                    Text(subtitle, style: AppTextStyles.ratingText),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: List.generate(options.length, (index) {
              final isSelected = index == selectedIndex;
              final option = options[index];
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: index != options.length - 1 ? 8 : 0),
                  child: GestureDetector(
                    onTap: () => onSelected(index),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary : AppColors.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected ? AppColors.primary : AppColors.border,
                        ),
                      ),
                      child: Column(
                        children: [
                          HugeIcon(
                            icon: option.icon,
                            size: 18,
                            color: isSelected ? Colors.white : AppColors.primary,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            option.label,
                            textAlign: TextAlign.center,
                            style: AppTextStyles.categoryLabel.copyWith(
                              color: isSelected ? Colors.white : AppColors.textPrimary,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}