import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../providers/user_provider.dart';

/// Ganti email dari profil, dua langkah:
/// 1. isi email baru + password saat ini -> kode 6 digit dikirim ke email baru;
/// 2. masukkan kode -> email berganti dan dipakai untuk login berikutnya.
/// Bila ada permintaan yang masih menunggu (mis. aplikasi ditutup), layar langsung ke langkah 2.
class ChangeEmailScreen extends StatefulWidget {
  const ChangeEmailScreen({super.key});

  @override
  State<ChangeEmailScreen> createState() => _ChangeEmailScreenState();
}

class _ChangeEmailScreenState extends State<ChangeEmailScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _codeController = TextEditingController();

  bool _obscure = true;
  bool _busy = false;

  /// Sama dengan validasi dasar backend: ada "@" dan titik pada domain.
  static final RegExp _emailPattern = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  void _showMessage(String text) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _requestCode() async {
    if (_busy) return;
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (!_emailPattern.hasMatch(email)) {
      _showMessage('Format email tidak valid.');
      return;
    }
    if (password.isEmpty) {
      _showMessage('Masukkan password saat ini.');
      return;
    }

    setState(() => _busy = true);
    final error = await context.read<UserProvider>().requestEmailChange(
          newEmail: email,
          currentPassword: password,
        );
    if (!mounted) return;
    setState(() => _busy = false);

    if (error != null) {
      _showMessage(error);
      return;
    }
    _passwordController.clear();
    _showMessage('Kode verifikasi dikirim ke $email.');
  }

  Future<void> _verify() async {
    if (_busy) return;
    final code = _codeController.text.trim();
    if (code.length != 6) {
      _showMessage('Kode verifikasi terdiri dari 6 digit.');
      return;
    }

    setState(() => _busy = true);
    final user = context.read<UserProvider>();
    final error = await user.verifyEmailChange(code);
    if (!mounted) return;
    setState(() => _busy = false);

    if (error != null) {
      _showMessage(error);
      // Terlalu banyak salah -> server membatalkan permintaan; sinkronkan tampilan.
      if (error.contains('Terlalu banyak')) user.loadProfile();
      return;
    }
    _showMessage('Email berhasil diganti. Gunakan email baru saat login.');
    Navigator.of(context).maybePop();
  }

  Future<void> _useOtherEmail() async {
    if (_busy) return;
    setState(() => _busy = true);
    final error = await context.read<UserProvider>().cancelEmailChange();
    if (!mounted) return;
    setState(() => _busy = false);
    _codeController.clear();
    if (error != null) _showMessage(error);
  }

  InputDecoration _decoration(String hint, {Widget? suffix}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: AppTextStyles.searchHint,
      filled: true,
      fillColor: AppColors.inputBackground,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      suffixIcon: suffix,
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>();
    final pending = user.pendingEmail;
    final awaitingCode = pending.isNotEmpty;

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
                  child: const Icon(Icons.arrow_back,
                      color: AppColors.primary, size: 24),
                ),
                const SizedBox(width: 12),
                Text(
                  'Ganti Email',
                  style: AppTextStyles.greetingTitle
                      .copyWith(fontSize: 22, color: AppColors.primary),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              awaitingCode
                  ? 'Kami mengirim kode 6 digit ke $pending. Masukkan kode '
                      'tersebut (berlaku 15 menit).'
                  : 'Email saat ini: ${user.email}. Kode verifikasi akan '
                      'dikirim ke email baru.',
              style: AppTextStyles.greetingSubtitle,
            ),
            const SizedBox(height: 24),
            if (!awaitingCode) ...[
              Text('Email Baru',
                  style: AppTextStyles.productName.copyWith(fontSize: 13)),
              const SizedBox(height: 8),
              TextField(
                key: const Key('new-email'),
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
                decoration: _decoration('nama@email.com'),
              ),
              const SizedBox(height: 20),
              Text('Password Saat Ini',
                  style: AppTextStyles.productName.copyWith(fontSize: 13)),
              const SizedBox(height: 8),
              TextField(
                key: const Key('current-password'),
                controller: _passwordController,
                obscureText: _obscure,
                decoration: _decoration(
                  'Masukkan password',
                  suffix: IconButton(
                    icon: Icon(
                      _obscure
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: AppColors.textSecondary,
                      size: 20,
                    ),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              _button(_busy ? 'Mengirim...' : 'Kirim Kode', _requestCode),
            ] else ...[
              Text('Kode Verifikasi',
                  style: AppTextStyles.productName.copyWith(fontSize: 13)),
              const SizedBox(height: 8),
              TextField(
                key: const Key('email-code'),
                controller: _codeController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                decoration: _decoration('6 digit kode').copyWith(counterText: ''),
              ),
              const SizedBox(height: 32),
              _button(_busy ? 'Memeriksa...' : 'Verifikasi', _verify),
              const SizedBox(height: 8),
              Center(
                child: TextButton(
                  onPressed: _busy ? null : _useOtherEmail,
                  child: Text(
                    'Pakai email lain',
                    style: AppTextStyles.sectionAction,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _button(String label, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: _busy ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        elevation: 0,
      ),
      child: Text(
        label,
        style: AppTextStyles.productName
            .copyWith(color: AppColors.textOnPrimary, fontSize: 16),
      ),
    );
  }
}
