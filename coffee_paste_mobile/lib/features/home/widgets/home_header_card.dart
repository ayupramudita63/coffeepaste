import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class HomeHeaderCard extends StatelessWidget {
  const HomeHeaderCard({super.key});

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 11) return 'Selamat pagi,';
    if (hour < 15) return 'Selamat siang,';
    if (hour < 18) return 'Selamat sore,';
    return 'Selamat malam,';
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Foto kopi di kanan, memudar ke kiri, atas, dan bawah
          Positioned(
            right: -20,
            bottom: 0,
            child: ShaderMask(
              shaderCallback: (rect) => const LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [Colors.transparent, Colors.black, Colors.black],
                stops: [0.0, 0.4, 1.0],
              ).createShader(rect),
              blendMode: BlendMode.dstIn,
              child: ShaderMask(
                shaderCallback: (rect) => const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black,
                    Colors.black,
                    Colors.transparent,
                  ],
                  stops: [0.0, 0.25, 0.85, 1.0],
                ).createShader(rect),
                blendMode: BlendMode.dstIn,
                child: Image.asset(
                  'assets/images/hero_coffee.jpg',
                  width: 230,
                  height: 170,
                  fit: BoxFit.cover,
                  alignment: Alignment.centerRight,
                  errorBuilder: (context, error, stackTrace) {
                    debugPrint('Gagal memuat hero_coffee.jpg: $error');
                    return const SizedBox(width: 230, height: 170);
                  },
                ),
              ),
            ),
          ),

          // Logo di kiri atas (file putih diwarnai hijau supaya terbaca di latar krem)
          Positioned(
            left: 0,
            top: 0,
            child: ColorFiltered(
              colorFilter: const ColorFilter.mode(
                AppColors.primary,
                BlendMode.srcIn,
              ),
              child: Image.asset(
                'assets/images/logo1.png',
                height: 40,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.local_cafe, color: AppColors.primary, size: 24),
                    SizedBox(width: 8),
                    Text(
                      'Coffee Paste',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Sapaan
          Positioned(
            left: 0,
            bottom: 14,
            right: 120,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _greeting,
                  style: AppTextStyles.greetingSubtitle.copyWith(fontSize: 13),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        'Pecinta Kopi',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.greetingTitle.copyWith(
                          fontSize: 24,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text('☕', style: TextStyle(fontSize: 18)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Nikmati secangkir kebahagiaan\ndi setiap harimu.',
                  style: AppTextStyles.greetingSubtitle.copyWith(
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}