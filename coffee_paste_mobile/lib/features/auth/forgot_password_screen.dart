import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../providers/auth_provider.dart';
import '../../features/auth/widgets/auth_text_field.dart';
import 'widgets/corner_leaf_decoration.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  bool _isSubmitted = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _onBackTap() {
    Navigator.of(context).maybePop();
  }

  Future<void> _onKirimTap() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      _showMessage('Email wajib diisi.');
      return;
    }

    final auth = context.read<AuthProvider>();
    final success = await auth.forgotPassword(email: email);
    if (!mounted) return;

    if (!success) {
      _showMessage(auth.errorMessage ?? 'Gagal mengirim link. Coba lagi.');
      return;
    }

    setState(() => _isSubmitted = true);
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.authBackground,
      body: Stack(
        children: [
          Positioned(
            left: -10,
            top: 80,
            child: CornerLeafDecoration(
              imagePath: 'assets/images/leaf_top_left.png',
              width: 100,
            ),
          ),
          Positioned(
            right: -10,
            top: 60,
            child: CornerLeafDecoration(
              imagePath: 'assets/images/leaf_top_right.png',
              width: 130,
            ),
          ),
          Positioned(
            left: -10,
            bottom: 40,
            child: CornerLeafDecoration(
              imagePath: 'assets/images/leaf_bottom_left.png',
              width: 140,
            ),
          ),
          Positioned(
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
                  Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: _onBackTap,
                      child: HugeIcon(
                        icon: HugeIcons.strokeRoundedArrowLeft01,
                        color: AppColors.primary,
                        size: 24,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Icon besar di tengah
                  Center(
                    child: Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: HugeIcon(
                          icon: HugeIcons.strokeRoundedSquareLock01,
                          size: 40,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  Text(
                    'Lupa Password?',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.greetingTitle.copyWith(
                      fontSize: 26,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _isSubmitted
                        ? 'Link reset password sudah dikirim.\nCek email kamu ya.'
                        : 'Masukkan email yang terdaftar,\nkami akan kirimkan link untuk reset password.',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.greetingSubtitle,
                  ),
                  const SizedBox(height: 32),

                  if (!_isSubmitted) ...[
                    AuthTextField(
                      hintText: 'Email',
                      prefixIcon: HugeIcons.strokeRoundedMail01,
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: context.watch<AuthProvider>().isLoading
                          ? null
                          : _onKirimTap,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.textOnPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Kirim Link Reset',
                        style: AppTextStyles.productName.copyWith(
                          color: AppColors.textOnPrimary,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ] else ...[
                    OutlinedButton(
                      onPressed: _onBackTap,
                      style: OutlinedButton.styleFrom(
                        backgroundColor: AppColors.surface,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(color: AppColors.border),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Text(
                        'Kembali ke Login',
                        style: AppTextStyles.productName.copyWith(
                          color: AppColors.primary,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}