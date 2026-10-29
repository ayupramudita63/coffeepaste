import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// Memuat gambar dari URL backend (http/https) atau dari asset lokal.
Widget appImage(
  String source, {
  double? width,
  double? height,
  BoxFit? fit,
  ImageErrorWidgetBuilder? errorBuilder,
}) {
  final isNetwork =
      source.startsWith('http://') || source.startsWith('https://');

  if (!isNetwork) {
    return Image.asset(
      source,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: errorBuilder,
    );
  }

  return Image.network(
    source,
    width: width,
    height: height,
    fit: fit,
    errorBuilder: errorBuilder,
    loadingBuilder: (context, child, progress) {
      if (progress == null) return child;
      return SizedBox(
        width: width,
        height: height,
        child: const ColoredBox(
          color: AppColors.surfaceMuted,
          child: Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.primary,
              ),
            ),
          ),
        ),
      );
    },
  );
}
