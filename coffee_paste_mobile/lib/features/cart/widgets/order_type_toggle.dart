import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// Pilihan "Pick Up" / "Dine In".
class OrderTypeToggle extends StatelessWidget {
  final bool isPickUp;
  final ValueChanged<bool> onChanged;

  const OrderTypeToggle({
    super.key,
    required this.isPickUp,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.authBackground,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Row(
        children: [
          _Segment(
            label: 'Pick Up',
            selected: isPickUp,
            onTap: () => onChanged(true),
          ),
          _Segment(
            label: 'Dine In',
            selected: !isPickUp,
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
            vertical: 14,
          ),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(26),
          ),
          child: Center(
            child: Text(
              label,
              style: AppTextStyles.productName.copyWith(
                fontSize: 15,
                color: selected
                    ? AppColors.textOnPrimary
                    : AppColors.primary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
