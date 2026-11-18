import 'package:flutter/material.dart';

import '../../../core/theme/app_style.dart';
import '../../../shared/models/product_model.dart';
import 'home_product_card.dart';

/// Baris produk yang bisa digeser secara horizontal (3 kartu per layar).
class HomeProductRow extends StatelessWidget {
  final List<ProductModel> products;
  final bool isNew;
  final ValueChanged<ProductModel> onTap;

  const HomeProductRow({
    super.key,
    required this.products,
    required this.onTap,
    this.isNew = false,
  });

  @override
  Widget build(BuildContext context) {
    const gap = AppStyle.gap;

    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = (constraints.maxWidth - gap * 2) / 3;

        return SizedBox(
          height: 184,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            physics: const BouncingScrollPhysics(),
            itemCount: products.length,
            separatorBuilder: (_, __) => const SizedBox(width: gap),
            itemBuilder: (context, index) {
              final product = products[index];

              return SizedBox(
                width: cardWidth,
                child: HomeProductCard(
                  product: product,
                  isNew: isNew,
                  onTap: () => onTap(product),
                  onAddTap: () => onTap(product),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
