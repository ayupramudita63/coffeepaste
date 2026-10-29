import 'package:flutter/material.dart';

import '../../../core/theme/app_text_styles.dart';

/// Judul bagian di halaman checkout, dengan jarak 12 ke konten di bawahnya.
class CartSectionTitle extends StatelessWidget {
  final String title;

  const CartSectionTitle(this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: AppTextStyles.sectionTitle,
      ),
    );
  }
}
