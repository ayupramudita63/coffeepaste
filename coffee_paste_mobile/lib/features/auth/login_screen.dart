import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';

import '../../core/config/app_config.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../providers/auth_provider.dart';
import 'widgets/auth_text_field.dart';
import 'widgets/corner_leaf_decoration.dart';
import 'widgets/google_logo.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController(
    text: AppConfig.useMock ? AppConfig.demoEmail : '',
  );
  final _passwordController = TextEditingController(
    text: AppConfig.useMock ? AppConfig.demoPassword : '',
  );
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _onMasukTap() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      _showMessage('Email dan password wajib diisi.');
      return;
    }

    final auth = context.read<AuthProvider>();
    final success = await auth.login(email: email, password: password);

    // Sukses: guard router otomatis memindahkan ke Home.
    if (!mounted || success) return;

    _showMessage(auth.errorMessage ?? 'Gagal masuk. Coba lagi.');
  }

  Future<void> _onGoogleTap() async {
    final auth = context.read<AuthProvider>();
    final success = await auth.loginWithGoogle();

    // Sukses: guard router otomatis memindahkan ke Home.
    // Dibatalkan pengguna: errorMessage null, jadi tidak ada pesan.
    if (!mounted || success) return;

    final message = auth.errorMessage;
    if (message != null) _showMessage(message);
  }

  void _onDaftarTap() {
    context.push(AppRoutes.register);
  }

  void _onLupaPasswordTap() {
    context.push(AppRoutes.forgotPassword);
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthProvider>().isLoading;

    return Scaffold(
      backgroundColor: AppColors.authBackground,
      body: Stack(
        children: [
          const Positioned(
            left: -10,
            top: 80,
            child: CornerLeafDecoration(
              imagePath: 'assets/images/leaf_top_left.png',
              width: 110,
            ),
          ),
          const Positioned(
            right: -10,
            top: 60,
            child: CornerLeafDecoration(
              imagePath: 'assets/images/leaf_top_right.png',
              width: 130,
            ),
          ),
          const Positioned(
            left: -10,
            bottom: 40,
            child: CornerLeafDecoration(
              imagePath: 'assets/images/leaf_bottom_left.png',
              width: 140,
            ),
          ),
          const Positioned(
            right: 0,
            bottom: 20,
            child: CornerLeafDecoration(
              imagePath: 'assets/images/coffee_cup_illustration.png',
              width: 190,
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 40),
                  Text(
                    'Welcome',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.greetingTitle.copyWith(
                      fontSize: 34,
                      color: AppColors.primary,
                    ),
                  ),
                  Text(
                    'Coffee Paste',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.greetingTitle.copyWith(
                      fontSize: 30,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Nikmati kopi favoritmu kapan saja.',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.greetingSubtitle,
                  ),
                  const SizedBox(height: 36),
                  AuthTextField(
                    hintText: 'Email',
                    prefixIcon: HugeIcons.strokeRoundedMail01,
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),
                  AuthTextField(
                    hintText: 'Password',
                    prefixIcon: HugeIcons.strokeRoundedLockKeyhole,
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    suffixIcon: IconButton(
                      icon: HugeIcon(
                        icon: _obscurePassword
                            ? HugeIcons.strokeRoundedView
                            : HugeIcons.strokeRoundedEyeOff,
                        color: AppColors.textSecondary,
                        size: 20,
                      ),
                      onPressed: () {
                        setState(() => _obscurePassword = !_obscurePassword);
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: _onLupaPasswordTap,
                      child: Text(
                        'Lupa Password?',
                        style: AppTextStyles.sectionAction.copyWith(
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: isLoading ? null : _onMasukTap,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.textOnPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 0,
                    ),
                    child: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.textOnPrimary,
                            ),
                          )
                        : Text(
                            'Masuk',
                            style: AppTextStyles.productName.copyWith(
                              color: AppColors.textOnPrimary,
                              fontSize: 16,
                            ),
                          ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      const Expanded(child: Divider(color: AppColors.border)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text('atau', style: AppTextStyles.ratingText),
                      ),
                      const Expanded(child: Divider(color: AppColors.border)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  OutlinedButton(
                    onPressed: isLoading ? null : _onGoogleTap,
                    style: OutlinedButton.styleFrom(
                      backgroundColor: AppColors.surface,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: AppColors.border),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const GoogleLogo(size: 20),
                        const SizedBox(width: 10),
                        Text(
                          'Masuk dengan Google',
                          style: AppTextStyles.productName,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Belum punya akun? ',
                        style: AppTextStyles.greetingSubtitle,
                      ),
                      GestureDetector(
                        onTap: _onDaftarTap,
                        child: Text(
                          'Daftar Sekarang',
                          style: AppTextStyles.sectionAction.copyWith(
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}