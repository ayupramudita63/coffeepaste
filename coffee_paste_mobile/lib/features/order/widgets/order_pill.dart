import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// Label berbentuk pil (nomor pesanan, tipe pesanan, status).
class OrderPill extends StatelessWidget {
  final Widget child;

  /// Ukuran lebih kecil, dipakai di kartu Riwayat.
  final bool compact;

  /// Warna dasar; latar memakai warna ini dengan [opacity].
  final Color color;
  final double opacity;

  const OrderPill({
    super.key,
    required this.child,
    this.compact = false,
    this.color = AppColors.primary,
    this.opacity = 0.08,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 12 : 14,
        vertical: compact ? 7 : 8,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(opacity),
        borderRadius: BorderRadius.circular(compact ? 18 : 20),
      ),
      child: child,
    );
  }
}
