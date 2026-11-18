import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../features/auth/widgets/auth_text_field.dart';
import '../../providers/auth_provider.dart';
import '../../shared/widgets/top_notice.dart';
import 'data/auth_repository.dart';
import 'widgets/corner_leaf_decoration.dart';

/// Langkah-langkah lupa password.
enum ResetStep { email, otp, newPassword }

/// Lupa password lewat kode OTP, tiga langkah dalam satu layar:
/// 1. isi email -> kode 6 digit dikirim ke email;
/// 2. masukkan kode OTP;
/// 3. buat password baru -> kembali ke login.
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _codeController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  ResetStep _step = ResetStep.email;
  bool _busy = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  /// Email dan kode yang sudah dikirim ke server (dipakai lagi di langkah berikutnya).
  String _email = '';
  String _code = '';

  Timer? _timer;
  int _secondsLeft = 0;

  /// Sama dengan validasi dasar backend: ada "@" dan titik pada domain.
  static final RegExp _emailPattern = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

  @override
  void dispose() {
    _timer?.cancel();
    _emailController.dispose();
    _codeController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  /// Aturan sama dengan backend: 8-72 karakter, ada huruf besar, huruf kecil, dan angka.
  bool _isStrongPassword(String value) {
    return value.length >= 8 &&
        value.length <= 72 &&
        RegExp(r'[A-Z]').hasMatch(value) &&
        RegExp(r'[a-z]').hasMatch(value) &&
        RegExp(r'[0-9]').hasMatch(value);
  }

  /// Pesan tampil sebagai kotak mengambang di atas layar (default: pesan gagal).
  void _showMessage(
    String message, {
    TopNoticeType type = TopNoticeType.error,
  }) {
    TopNotice.show(context, message, type: type);
  }

  void _startCooldown() {
    _timer?.cancel();
    setState(() => _secondsLeft = PasswordOtpRules.resendCooldown.inSeconds);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() => _secondsLeft--);
      if (_secondsLeft <= 0) timer.cancel();
    });
  }

  void _goToLogin() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.login);
    }
  }

  void _onBackTap() {
    switch (_step) {
      case ResetStep.email:
        _goToLogin();
      case ResetStep.otp:
        _codeController.clear();
        setState(() => _step = ResetStep.email);
      case ResetStep.newPassword:
        setState(() => _step = ResetStep.otp);
    }
  }

  // ---- Langkah 1: minta kode ----

  Future<void> _requestOtp({bool isResend = false}) async {
    if (_busy) return;
    final email = isResend ? _email : _emailController.text.trim();

    if (email.isEmpty) {
      _showMessage('Email wajib diisi.');
      return;
    }
    if (!_emailPattern.hasMatch(email)) {
      _showMessage('Format email tidak valid.');
      return;
    }

    setState(() => _busy = true);
    final auth = context.read<AuthProvider>();
    final success = await auth.requestPasswordOtp(email: email);
    if (!mounted) return;
    setState(() => _busy = false);

    if (!success) {
      _showMessage(auth.errorMessage ?? 'Gagal mengirim kode. Coba lagi.');
      return;
    }

    _email = email;
    _codeController.clear();
    _startCooldown();
    setState(() => _step = ResetStep.otp);
    _showMessage(
      isResend
          ? 'Kode baru dikirim ke $email.'
          : 'Jika email terdaftar, kode OTP dikirim ke $email.',
      type: TopNoticeType.success,
    );
  }

  // ---- Langkah 2: verifikasi kode ----

  Future<void> _verifyOtp() async {
    if (_busy) return;
    final code = _codeController.text.trim();
    if (code.length != PasswordOtpRules.length) {
      _showMessage('Kode OTP terdiri dari ${PasswordOtpRules.length} digit.');
      return;
    }

    setState(() => _busy = true);
    final auth = context.read<AuthProvider>();
    final success = await auth.verifyPasswordOtp(email: _email, code: code);
    if (!mounted) return;
    setState(() => _busy = false);

    if (!success) {
      _codeController.clear();
      _showMessage(auth.errorMessage ?? 'Kode OTP salah. Coba lagi.');
      return;
    }

    _code = code;
    setState(() => _step = ResetStep.newPassword);
  }

  // ---- Langkah 3: password baru ----

  Future<void> _resetPassword() async {
    if (_busy) return;
    final password = _passwordController.text;
    final confirm = _confirmController.text;

    if (password.isEmpty || confirm.isEmpty) {
      _showMessage('Semua kolom wajib diisi.');
      return;
    }
    if (!_isStrongPassword(password)) {
      _showMessage(
        'Password baru minimal 8 karakter dan harus mengandung huruf besar, huruf kecil, dan angka.',
      );
      return;
    }
    if (password != confirm) {
      _showMessage('Konfirmasi password tidak sama.');
      return;
    }

    setState(() => _busy = true);
    final auth = context.read<AuthProvider>();
    final success = await auth.resetPasswordWithOtp(
      email: _email,
      code: _code,
      newPassword: password,
    );
    if (!mounted) return;
    setState(() => _busy = false);

    if (!success) {
      final message = auth.errorMessage ?? 'Gagal mengganti password. Coba lagi.';
      _showMessage(message);
      // Kode sudah tidak berlaku (kedaluwarsa / terlalu banyak salah) -> kembali ke langkah kode.
      if (message.contains('OTP')) {
        _codeController.clear();
        setState(() => _step = ResetStep.otp);
      }
      return;
    }

    // Pesan dipasang di overlay root, jadi tetap tampil setelah pindah ke login.
    _showMessage(
      'Password berhasil diubah. Silakan masuk dengan password baru.',
      type: TopNoticeType.success,
    );
    // Langsung ke halaman login (bukan sekadar kembali ke halaman sebelumnya).
    context.go(AppRoutes.login);
  }

  // ---- Tampilan ----

  String get _title {
    switch (_step) {
      case ResetStep.email:
        return 'Lupa Password?';
      case ResetStep.otp:
        return 'Masukkan Kode OTP';
      case ResetStep.newPassword:
        return 'Password Baru';
    }
  }

  String get _subtitle {
    switch (_step) {
      case ResetStep.email:
        return 'Masukkan email yang terdaftar,\nkami akan kirimkan kode OTP untuk reset password.';
      case ResetStep.otp:
        return 'Kami mengirim kode ${PasswordOtpRules.length} digit ke\n$_email\n'
            '(berlaku ${PasswordOtpRules.validityMinutes} menit).';
      case ResetStep.newPassword:
        return 'Buat password baru untuk akunmu.';
    }
  }

  List<List<dynamic>> get _headerIcon {
    switch (_step) {
      case ResetStep.email:
        return HugeIcons.strokeRoundedSquareLock01;
      case ResetStep.otp:
        return HugeIcons.strokeRoundedMail01;
      case ResetStep.newPassword:
        return HugeIcons.strokeRoundedSquareLock01;
    }
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
                      key: const Key('forgot-back'),
                      onTap: _busy ? null : _onBackTap,
                      child: HugeIcon(
                        icon: HugeIcons.strokeRoundedArrowLeft01,
                        color: AppColors.primary,
                        size: 24,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
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
                          icon: _headerIcon,
                          size: 40,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    _title,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.greetingTitle.copyWith(
                      fontSize: 26,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _subtitle,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.greetingSubtitle,
                  ),
                  const SizedBox(height: 32),
                  ..._buildStep(),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildStep() {
    switch (_step) {
      case ResetStep.email:
        return [
          AuthTextField(
            key: const Key('forgot-email'),
            hintText: 'Email',
            prefixIcon: HugeIcons.strokeRoundedMail01,
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 24),
          _primaryButton(
            key: const Key('forgot-send-otp'),
            label: _busy ? 'Mengirim...' : 'Kirim Kode OTP',
            onPressed: _requestOtp,
          ),
        ];

      case ResetStep.otp:
        final canResend = _secondsLeft <= 0 && !_busy;
        return [
          AuthTextField(
            key: const Key('forgot-otp'),
            hintText: 'Kode OTP',
            prefixIcon: HugeIcons.strokeRoundedSquareLock01,
            controller: _codeController,
            keyboardType: TextInputType.number,
            maxLength: PasswordOtpRules.length,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
          const SizedBox(height: 24),
          _primaryButton(
            key: const Key('forgot-verify-otp'),
            label: _busy ? 'Memeriksa...' : 'Verifikasi',
            onPressed: _verifyOtp,
          ),
          const SizedBox(height: 8),
          Center(
            child: TextButton(
              key: const Key('forgot-resend'),
              onPressed: canResend ? () => _requestOtp(isResend: true) : null,
              child: Text(
                _secondsLeft > 0
                    ? 'Kirim ulang kode ($_secondsLeft dtk)'
                    : 'Kirim ulang kode',
                style: AppTextStyles.sectionAction,
              ),
            ),
          ),
          Center(
            child: TextButton(
              onPressed: _busy ? null : _onBackTap,
              child: Text('Pakai email lain', style: AppTextStyles.sectionAction),
            ),
          ),
        ];

      case ResetStep.newPassword:
        return [
          AuthTextField(
            key: const Key('forgot-new-password'),
            hintText: 'Password baru',
            prefixIcon: HugeIcons.strokeRoundedSquareLock01,
            controller: _passwordController,
            obscureText: _obscurePassword,
            suffixIcon: _visibilityToggle(
              obscured: _obscurePassword,
              onTap: () => setState(() => _obscurePassword = !_obscurePassword),
            ),
          ),
          const SizedBox(height: 16),
          AuthTextField(
            key: const Key('forgot-confirm-password'),
            hintText: 'Konfirmasi password baru',
            prefixIcon: HugeIcons.strokeRoundedSquareLock01,
            controller: _confirmController,
            obscureText: _obscureConfirm,
            suffixIcon: _visibilityToggle(
              obscured: _obscureConfirm,
              onTap: () => setState(() => _obscureConfirm = !_obscureConfirm),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Minimal 8 karakter, mengandung huruf besar, huruf kecil, dan angka.',
            textAlign: TextAlign.center,
            style: AppTextStyles.greetingSubtitle.copyWith(fontSize: 12),
          ),
          const SizedBox(height: 24),
          _primaryButton(
            key: const Key('forgot-save-password'),
            label: _busy ? 'Menyimpan...' : 'Simpan Password',
            onPressed: _resetPassword,
          ),
        ];
    }
  }

  Widget _visibilityToggle({
    required bool obscured,
    required VoidCallback onTap,
  }) {
    return IconButton(
      icon: Icon(
        obscured ? Icons.visibility_outlined : Icons.visibility_off_outlined,
        color: AppColors.textSecondary,
        size: 20,
      ),
      onPressed: onTap,
    );
  }

  Widget _primaryButton({
    required Key key,
    required String label,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      key: key,
      onPressed: _busy ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 0,
      ),
      child: Text(
        label,
        style: AppTextStyles.productName.copyWith(
          color: AppColors.textOnPrimary,
          fontSize: 16,
        ),
      ),
    );
  }
}