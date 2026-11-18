import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_style.dart';
import '../../core/theme/app_text_styles.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import 'appearance_screen.dart';
import '../../providers/user_provider.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  Future<void> _onLogoutTap(BuildContext context) async {
    final auth = context.read<AuthProvider>();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppStyle.cardRadius),
        ),
        title: Text('Keluar?'),
        content: Text(
          'Kamu perlu masuk lagi untuk memakai aplikasi.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text('Keluar'),
          ),
        ],
      ),
    );

    // Guard router otomatis memindahkan ke halaman login.
    if (confirmed == true) await auth.logout();
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<UserProvider>();
    final theme = context.watch<ThemeProvider>();

    return Container(
      color: AppColors.authBackground,
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppStyle.screenPadding,
            14,
            AppStyle.screenPadding,
            24,
          ),
          children: [
            // Judul besar ala iOS
            SizedBox(
              height: 44,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Profil',
                  style: AppTextStyles.greetingTitle.copyWith(
                    fontSize: 32,
                    letterSpacing: -0.6,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Kartu profil
            Container(
              padding: const EdgeInsets.all(AppStyle.cardPadding),
              decoration: AppStyle.card(),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      shape: BoxShape.circle,
                      image: profile.avatarFile != null
                          ? DecorationImage(
                              image: FileImage(profile.avatarFile!),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: profile.avatarFile == null
                        ? Icon(
                            Icons.person_rounded,
                            size: 34,
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
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.productName.copyWith(
                            fontSize: 17,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          profile.email,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.ratingText,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Grup pengaturan akun
            _SettingsGroup(
              children: [
                _SettingsRow(
                  icon: Icons.person_rounded,
                  title: 'Informasi Akun',
                  onTap: () => context.push(AppRoutes.accountInfo),
                ),
                _SettingsRow(
                  icon: Icons.notifications_rounded,
                  title: 'Notifikasi',
                  onTap: () => context.push(AppRoutes.notifications),
                ),
                _SettingsRow(
                  icon: Icons.palette_rounded,
                  title: 'Tampilan',
                  value: AppearanceScreen.labelOf(theme.mode),
                  valueDotColor: theme.accent,
                  onTap: () => context.push(AppRoutes.appearance),
                ),
                _SettingsRow(
                  icon: Icons.lock_rounded,
                  title: 'Ganti Password',
                  onTap: () => context.push(AppRoutes.changePassword),
                ),
              ],
            ),

            const SizedBox(height: 20),

            _SettingsGroup(
              children: [
                _SettingsRow(
                  icon: Icons.info_rounded,
                  title: 'Tentang Coffee Paste',
                  onTap: () => context.push(AppRoutes.about),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Keluar
            GestureDetector(
              onTap: () => _onLogoutTap(context),
              behavior: HitTestBehavior.opaque,
              child: Container(
                height: 52,
                alignment: Alignment.center,
                decoration: AppStyle.card(),
                child: Text(
                  'Keluar',
                  style: AppTextStyles.productName.copyWith(
                    fontSize: 15,
                    color: AppColors.favorite,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Satu kartu berisi beberapa baris pengaturan, dipisah garis tipis
/// (gaya "inset grouped" iOS). Semua grup selebar sama.
class _SettingsGroup extends StatelessWidget {
  final List<Widget> children;

  const _SettingsGroup({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: AppStyle.card(),
      child: Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) AppStyle.hairline(indent: 58),
            children[i],
          ],
        ],
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? value;
  final Color? valueDotColor;
  final VoidCallback onTap;

  const _SettingsRow({
    required this.icon,
    required this.title,
    required this.onTap,
    this.value,
    this.valueDotColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        height: 54,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 18, color: Colors.white),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.productName.copyWith(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (valueDotColor != null) ...[
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: valueDotColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
              ],
              if (value != null) ...[
                Text(value!, style: AppTextStyles.ratingText),
                const SizedBox(width: 2),
              ],
              Icon(
                Icons.chevron_right_rounded,
                size: 22,
                color: AppColors.textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
