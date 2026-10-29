import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/cart_provider.dart';

/// Ikon keranjang dengan badge jumlah item.
/// Bisa dipasang di header halaman mana pun.
class CartIconButton extends StatelessWidget {
  const CartIconButton({super.key});

  @override
  Widget build(BuildContext context) {
    final count = context.watch<CartProvider>().totalItemCount;

    return GestureDetector(
      onTap: () {
        context.push(AppRoutes.cart);
      },
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: const BoxDecoration(
              color: AppColors.surface,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: HugeIcon(
                icon: HugeIcons.strokeRoundedShoppingCart01,
                size: 18,
                color: AppColors.primary,
              ),
            ),
          ),

          if (count > 0)
            Positioned(
              top: -4,
              right: -4,
              child: Container(
                constraints: const BoxConstraints(
                  minWidth: 18,
                  minHeight: 18,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 5,
                ),
                decoration: const BoxDecoration(
                  color: AppColors.favorite,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    count > 99 ? '99+' : '$count',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}