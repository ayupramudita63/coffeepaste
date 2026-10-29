import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.authBackground,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.of(context).maybePop(),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(color: AppColors.surface, shape: BoxShape.circle),
                    child: const Icon(Icons.arrow_back, color: AppColors.primary, size: 20),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Tentang Coffee Paste',
                  style: AppTextStyles.greetingTitle.copyWith(fontSize: 20, color: AppColors.primary),
                ),
              ],
            ),
            const SizedBox(height: 20),

            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.asset(
                  'assets/images/latte.jpg',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: AppColors.surfaceMuted,
                    child: const Icon(Icons.local_cafe, size: 48, color: AppColors.primary),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            Text(
              'Tentang Coffee Paste',
              style: AppTextStyles.greetingTitle.copyWith(fontSize: 20, color: AppColors.primary),
            ),
            const SizedBox(height: 10),
            Text(
              'Coffee Paste adalah aplikasi kopi yang hadir untuk menemani '
              'hari-harimu dengan rasa terbaik dan pengalaman memesan yang lebih mudah.',
              style: AppTextStyles.greetingSubtitle.copyWith(height: 1.5),
            ),
            const SizedBox(height: 24),

            _AboutFeatureTile(
              icon: Icons.coffee_outlined,
              title: 'Kopi Pilihan',
              description: 'Kami menyajikan kopi berkualitas dengan cita rasa terbaik.',
            ),
            const SizedBox(height: 16),
            _AboutFeatureTile(
              icon: Icons.touch_app_outlined,
              title: 'Mudah Digunakan',
              description: 'Pesan kopi favoritmu kapan saja dan di mana saja.',
            ),
            const SizedBox(height: 16),
            _AboutFeatureTile(
              icon: Icons.favorite_border,
              title: 'Untuk Hari yang Lebih Baik',
              description: 'Karena secangkir kopi bisa menjadi awal dari banyak hal baik.',
            ),
            const SizedBox(height: 28),

            Center(
              child: Text(
                '"Good Coffee, Better Days"',
                style: AppTextStyles.greetingSubtitle.copyWith(
                  fontStyle: FontStyle.italic,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AboutFeatureTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _AboutFeatureTile({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 20, color: AppColors.primary),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTextStyles.productName),
              const SizedBox(height: 2),
              Text(description, style: AppTextStyles.ratingText),
            ],
          ),
        ),
      ],
    );
  }
}