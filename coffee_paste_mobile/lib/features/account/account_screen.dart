import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../providers/auth_provider.dart';
import '../../providers/language_provider.dart';
import '../../providers/user_provider.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  Future<void> _onLogoutTap(BuildContext context) async {
    final language = context.read<LanguageProvider>();
    final auth = context.read<AuthProvider>();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(language.text(id: 'Keluar?', en: 'Log out?')),
        content: Text(
          language.text(
            id: 'Kamu perlu masuk lagi untuk memakai aplikasi.',
            en: 'You will need to sign in again to use the app.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(language.text(id: 'Batal', en: 'Cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(language.text(id: 'Keluar', en: 'Log out')),
          ),
        ],
      ),
    );

    // Guard router otomatis memindahkan ke halaman login.
    if (confirmed == true) await auth.logout();
  }

  @override
  Widget build(BuildContext context) {
    final language = context.watch<LanguageProvider>();
    final profile = context.watch<UserProvider>();

    return Container(
      color: AppColors.authBackground,
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          children: [
            // Header
            SizedBox(
  height: 32,
  child: Stack(
    alignment: Alignment.center,
    children: [
      // Judul Profil di tengah
      Center(
        child: Text(
          language.text(
            id: 'Profil',
            en: 'Profile',
          ),
          style: AppTextStyles.greetingTitle.copyWith(
            fontSize: 28,
            color: AppColors.primary,
          ),
        ),
      ),
    
    ],
  ),
),

            const SizedBox(height: 24),

            // Kartu profil
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                      image: profile.avatarFile != null
                          ? DecorationImage(
                              image: FileImage(profile.avatarFile!),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: profile.avatarFile == null
                        ? const Icon(
                            Icons.person,
                            size: 32,
                            color: AppColors.primary,
                          )
                        : null,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          profile.name,
                          style: AppTextStyles.productName.copyWith(
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          profile.email,
                          style: AppTextStyles.ratingText,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Informasi Akun
            _AccountMenuTile(
              icon: Icons.person_outline,
              title: language.text(
                id: 'Informasi Akun',
                en: 'Account Information',
              ),
              subtitle: language.text(
                id: 'Kelola data diri dan akunmu',
                en: 'Manage your personal and account information',
              ),
              onTap: () {
                context.push(AppRoutes.accountInfo);
              },
            ),

            const SizedBox(height: 12),

            // Bahasa
            _AccountMenuTile(
              icon: Icons.language,
              title: language.text(
                id: 'Bahasa',
                en: 'Language',
              ),
              subtitle: language.text(
                id: 'Pilih bahasa aplikasi',
                en: 'Choose app language',
              ),
              onTap: () {
                context.push(AppRoutes.language);
              },
            ),

            const SizedBox(height: 12),

            // Notifikasi
            _AccountMenuTile(
              icon: Icons.notifications_none,
              title: language.text(
                id: 'Notifikasi',
                en: 'Notifications',
              ),
              subtitle: language.text(
                id: 'Pengaturan notifikasi',
                en: 'Notification settings',
              ),
              onTap: () {
                context.push(AppRoutes.notifications);
              },
            ),

            const SizedBox(height: 12),

            // Ganti Password
            _AccountMenuTile(
              icon: Icons.lock_outline,
              title: language.text(
                id: 'Ganti Password',
                en: 'Change Password',
              ),
              subtitle: language.text(
                id: 'Ubah kata sandi akun',
                en: 'Change your account password',
              ),
              onTap: () {
                context.push(AppRoutes.changePassword);
              },
            ),

            const SizedBox(height: 12),

            // Tentang Coffee Paste
            _AccountMenuTile(
              icon: Icons.info_outline,
              title: language.text(
                id: 'Tentang Coffee Paste',
                en: 'About Coffee Paste',
              ),
              subtitle: language.text(
                id: 'Kenali lebih dekat Coffee Paste',
                en: 'Learn more about Coffee Paste',
              ),
              onTap: () {
                context.push(AppRoutes.about);
              },
            ),

            const SizedBox(height: 24),

            // Keluar
            OutlinedButton.icon(
              onPressed: () => _onLogoutTap(context),
              icon: const Icon(Icons.logout, color: AppColors.favorite),
              label: Text(
                language.text(id: 'Keluar', en: 'Log out'),
                style: AppTextStyles.productName.copyWith(
                  color: AppColors.favorite,
                ),
              ),
              style: OutlinedButton.styleFrom(
                backgroundColor: AppColors.surface,
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: const BorderSide(color: AppColors.border),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AccountMenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _AccountMenuTile({
    required this.icon,
    required this.title,
    required this.subtitle,
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
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 22,
                color: AppColors.primary,
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

            const Icon(
              Icons.chevron_right,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}