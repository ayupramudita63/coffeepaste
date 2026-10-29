import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// Tab "Sedang Berlangsung" / "Riwayat" di halaman Pesanan.
class OrderTabBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  const OrderTabBar({
    super.key,
    required this.selectedIndex,
    required this.onChanged,
  });

  static const _titles = ['Sedang Berlangsung', 'Riwayat'];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 58,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          for (int i = 0; i < _titles.length; i++)
            Expanded(
              child: _OrderTab(
                title: _titles[i],
                isSelected: selectedIndex == i,
                onTap: () => onChanged(i),
              ),
            ),
        ],
      ),
    );
  }
}

class _OrderTab extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const _OrderTab({
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(26),
        ),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? AppColors.primary : AppColors.textSecondary,
            fontSize: 15,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
