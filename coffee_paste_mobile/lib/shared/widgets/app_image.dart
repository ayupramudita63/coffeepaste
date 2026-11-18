import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// Memuat gambar dari URL backend (http/https) atau dari asset lokal.
///
/// Gambar didekode sesuai ukuran tampilnya (bukan ukuran aslinya) supaya
/// hemat memori dan scroll tetap lancar, walau file dari server besar.
Widget appImage(
  String source, {
  double? width,
  double? height,
  BoxFit? fit,
  ImageErrorWidgetBuilder? errorBuilder,
}) {
  final isNetwork =
      source.startsWith('http://') || source.startsWith('https://');

  return LayoutBuilder(
    builder: (context, constraints) {
      final dpr = MediaQuery.devicePixelRatioOf(context);

      // Ukuran tampil: pakai width/height bila ada, kalau tidak pakai
      // batas dari induknya. Hanya satu sisi yang diisi agar rasio terjaga.
      final w = width ?? constraints.maxWidth;
      final h = height ?? constraints.maxHeight;
      int? cacheWidth;
      int? cacheHeight;
      if (w.isFinite && w > 0) {
        cacheWidth = (w * dpr).round().clamp(1, 2048);
      } else if (h.isFinite && h > 0) {
        cacheHeight = (h * dpr).round().clamp(1, 2048);
      }

      if (!isNetwork) {
        return Image.asset(
          source,
          width: width,
          height: height,
          fit: fit,
          cacheWidth: cacheWidth,
          cacheHeight: cacheHeight,
          errorBuilder: errorBuilder,
        );
      }

      return Image.network(
        source,
        width: width,
        height: height,
        fit: fit,
        cacheWidth: cacheWidth,
        cacheHeight: cacheHeight,
        gaplessPlayback: true,
        errorBuilder: errorBuilder,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return SizedBox(
            width: width,
            height: height,
            child: ColoredBox(
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
    },
  );
}
