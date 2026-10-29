import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const BottomNavBar({super.key, required this.currentIndex, required this.onTap});

  static const _items = [
    _NavItemData(icon: Icons.home_outlined, activeIcon: Icons.home, label: 'Home'),
    _NavItemData(icon: Icons.menu_book_outlined, activeIcon: Icons.menu_book, label: 'Menu'),
    _NavItemData(icon: Icons.shopping_cart_outlined, activeIcon: Icons.shopping_cart, label: 'Pesanan'),
    _NavItemData(icon: Icons.person_outline, activeIcon: Icons.person, label: 'Akun'),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(28),
          boxShadow: const [BoxShadow(color: Color(0x14000000), blurRadius: 16, offset: Offset(0, 6))],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(_items.length, (index) {
            final item = _items[index];
            final isActive = index == currentIndex;
            return GestureDetector(
              onTap: () => onTap(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isActive ? AppColors.primaryLight : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isActive ? item.activeIcon : item.icon,
                      color: isActive ? AppColors.primary : AppColors.textMuted,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.label,
                      style: AppTextStyles.categoryLabel.copyWith(
                        color: isActive ? AppColors.primary : AppColors.textMuted,
                        fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _NavItemData {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const _NavItemData({required this.icon, required this.activeIcon, required this.label});
}