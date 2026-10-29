import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../providers/auth_provider.dart';
import 'widgets/auth_text_field.dart';
import 'widgets/corner_leaf_decoration.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  /// Aturan sama dengan backend: minimal 8 karakter (maks 72),
  /// ada huruf besar, huruf kecil, dan angka.
  bool _isStrongPassword(String value) {
    return value.length >= 8 &&
        value.length <= 72 &&
        RegExp(r'[A-Z]').hasMatch(value) &&
        RegExp(r'[a-z]').hasMatch(value) &&
        RegExp(r'[0-9]').hasMatch(value);
  }

  Future<void> _onRegisterTap() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final password = _passwordController.text;
    final confirm = _confirmPasswordController.text;

    if (name.isEmpty || email.isEmpty || phone.isEmpty || password.isEmpty) {
      _showMessage('Semua kolom wajib diisi.');
      return;
    }
    if (!email.contains('@') || !email.contains('.')) {
      _showMessage('Format email tidak valid.');
      return;
    }
    if (!_isStrongPassword(password)) {
      _showMessage(
        'Password minimal 8 karakter dan harus mengandung huruf besar, huruf kecil, dan angka.',
      );
      return;
    }
    if (password != confirm) {
      _showMessage('Konfirmasi password tidak sama.');
      return;
    }

    final auth = context.read<AuthProvider>();
    final success = await auth.register(
      name: name,
      email: email,
      phone: phone,
      password: password,
    );
    if (!mounted) return;

    if (!success) {
      _showMessage(auth.errorMessage ?? 'Pendaftaran gagal. Coba lagi.');
      return;
    }

    _showMessage('Pendaftaran berhasil. Silakan masuk.');
    _backToLogin();
  }

  void _onMasukTap() => _backToLogin();

  void _backToLogin() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthProvider>().isLoading;

    return Scaffold(
      backgroundColor: AppColors.authBackground,
      body: Stack(
        children: [
          Positioned(
            left: -10,
            top: 80,
            child: CornerLeafDecoration(
              imagePath: 'assets/images/leaf_top_left.png',
              width: 90,
            ),
          ),
          Positioned(
            right: -10,
            top: 40,
            child: CornerLeafDecoration(
              imagePath: 'assets/images/leaf_top_right.png',
              width: 150,
            ),
          ),
          Positioned(
            left: -10,
            bottom: 40,
            child: CornerLeafDecoration(
              imagePath: 'assets/images/leaf_bottom_left.png',
              width: 150,
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
                  
                  const SizedBox(height: 40),

                  Text(
                    'Register',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.greetingTitle.copyWith(
                      fontSize: 32,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 10),

                  Row(
                    children: [
                      const Expanded(child: Divider(color: AppColors.border)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          'Yuk, daftar sekarang',
                          style: AppTextStyles.sectionAction.copyWith(fontSize: 14),
                        ),
                      ),
                      const Expanded(child: Divider(color: AppColors.border)),
                    ],
                  ),
                  const SizedBox(height: 28),

                  AuthTextField(
                    hintText: 'Nama Lengkap',
                    prefixIcon: HugeIcons.strokeRoundedUser,
                    controller: _nameController,
                  ),
                  const SizedBox(height: 16),

                  AuthTextField(
                    hintText: 'Email',
                    prefixIcon: HugeIcons.strokeRoundedMail01,
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),

                  AuthTextField(
                    hintText: 'Nomor Telepon',
                    prefixIcon: HugeIcons.strokeRoundedCall,
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
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
                  const SizedBox(height: 16),

                  AuthTextField(
                    hintText: 'Konfirmasi Password',
                    prefixIcon: HugeIcons.strokeRoundedLockKeyhole,
                    controller: _confirmPasswordController,
                    obscureText: _obscureConfirmPassword,
                    suffixIcon: IconButton(
                      icon: HugeIcon(
                        icon: _obscureConfirmPassword
                            ? HugeIcons.strokeRoundedView
                            : HugeIcons.strokeRoundedEyeOff,
                        color: AppColors.textSecondary,
                        size: 20,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 28),

                  ElevatedButton(
                    onPressed: isLoading ? null : _onRegisterTap,
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
                            'Register',
                            style: AppTextStyles.productName.copyWith(
                              color: AppColors.textOnPrimary,
                              fontSize: 16,
                            ),
                          ),
                  ),
                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Sudah punya akun? ', style: AppTextStyles.greetingSubtitle),
                      GestureDetector(
                        onTap: _onMasukTap,
                        child: Text(
                          'Masuk di sini',
                          style: AppTextStyles.sectionAction.copyWith(fontSize: 13),
                        ),
                      ),
                    ],
                  ),
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