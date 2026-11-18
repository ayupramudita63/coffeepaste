import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// Tab bar bawah bergaya iOS: selebar layar, latar buram transparan,
/// garis tipis di atas, empat tab sama lebar.
class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const BottomNavBar({super.key, required this.currentIndex, required this.onTap});

  static const _items = [
    _NavItemData(icon: Icons.home_outlined, activeIcon: Icons.home_rounded, label: 'Home'),
    _NavItemData(icon: Icons.menu_book_outlined, activeIcon: Icons.menu_book_rounded, label: 'Menu'),
    _NavItemData(icon: Icons.receipt_long_outlined, activeIcon: Icons.receipt_long_rounded, label: 'Pesanan'),
    _NavItemData(icon: Icons.person_outline_rounded, activeIcon: Icons.person_rounded, label: 'Akun'),
  ];

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
        child: Container(
          padding: EdgeInsets.only(bottom: bottomInset),
          decoration: BoxDecoration(
            color: AppColors.surface.withOpacity(AppColors.isDark ? 0.82 : 0.88),
            border: Border(
              top: BorderSide(color: AppColors.border, width: 0.5),
            ),
          ),
          child: SizedBox(
            height: 58,
            child: Row(
              children: List.generate(_items.length, (index) {
                final item = _items[index];
                final isActive = index == currentIndex;
                final color = isActive ? AppColors.primary : AppColors.textMuted;

                return Expanded(
                  child: GestureDetector(
                    onTap: () => onTap(index),
                    behavior: HitTestBehavior.opaque,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedScale(
                          scale: isActive ? 1.08 : 1.0,
                          duration: const Duration(milliseconds: 180),
                          child: Icon(
                            isActive ? item.activeIcon : item.icon,
                            size: 25,
                            color: color,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          item.label,
                          maxLines: 1,
                          style: TextStyle(
                            fontSize: 10.5,
                            height: 1.2,
                            color: color,
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
