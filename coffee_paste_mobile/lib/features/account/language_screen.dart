import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../providers/language_provider.dart';

class LanguageScreen extends StatelessWidget {
  const LanguageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final languageProvider = context.watch<LanguageProvider>();

    return Scaffold(
      backgroundColor: AppColors.authBackground,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          children: [
            // Header
            Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.of(context).maybePop(),
                  child: const Icon(
                    Icons.arrow_back,
                    color: AppColors.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  languageProvider.text(
                    id: 'Bahasa',
                    en: 'Language',
                  ),
                  style: AppTextStyles.greetingTitle.copyWith(
                    fontSize: 22,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            Text(
              languageProvider.text(
                id: 'Pilih bahasa yang ingin kamu gunakan di aplikasi.',
                en: 'Choose the language you want to use in the app.',
              ),
              style: AppTextStyles.greetingSubtitle,
            ),

            const SizedBox(height: 20),

            // Bahasa Indonesia
            _LanguageTile(
              flagEmoji: '🇮🇩',
              title: 'Bahasa Indonesia',
              subtitle: 'Gunakan bahasa Indonesia',
              isSelected: languageProvider.language == 'id',
              onTap: () {
                context.read<LanguageProvider>().changeLanguage('id');
              },
            ),

            const SizedBox(height: 12),

            // English
            _LanguageTile(
              flagEmoji: '🇬🇧',
              title: 'English',
              subtitle: 'Use English language',
              isSelected: languageProvider.language == 'en',
              onTap: () {
                context.read<LanguageProvider>().changeLanguage('en');
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _LanguageTile extends StatelessWidget {
  final String flagEmoji;
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageTile({
    required this.flagEmoji,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : AppColors.border,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: AppColors.surfaceMuted,
                shape: BoxShape.circle,
              ),
              child: Text(
                flagEmoji,
                style: const TextStyle(fontSize: 20),
              ),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.productName,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTextStyles.ratingText,
                  ),
                ],
              ),
            ),

            Icon(
              isSelected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_off,
              color: isSelected
                  ? AppColors.primary
                  : AppColors.textMuted,
            ),
          ],
        ),
      ),
    );
  }
}