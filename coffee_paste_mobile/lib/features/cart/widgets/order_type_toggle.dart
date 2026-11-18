import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_style.dart';

/// Pilihan "Take Away" / "Dine In".
class OrderTypeToggle extends StatelessWidget {
  final bool isTakeAway;
  final ValueChanged<bool> onChanged;

  const OrderTypeToggle({
    super.key,
    required this.isTakeAway,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.inputBackground,
        borderRadius: BorderRadius.circular(AppStyle.innerRadius),
      ),
      child: Row(
        children: [
          _Segment(
            label: 'Take Away',
            selected: isTakeAway,
            onTap: () => onChanged(true),
          ),
          _Segment(
            label: 'Dine In',
            selected: !isTakeAway,
            onTap: () => onChanged(false),
          ),
        ],
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _Segment({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(
            vertical: 13,
          ),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(AppStyle.innerRadius - 3),
          ),
          child: Center(
            child: Text(
              label,
              style: AppTextStyles.productName.copyWith(
                fontSize: 15,
                color: selected
                    ? AppColors.textOnPrimary
                    : AppColors.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
