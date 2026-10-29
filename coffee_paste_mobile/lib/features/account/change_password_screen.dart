import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../providers/auth_provider.dart';
import '../auth/widgets/auth_text_field.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscureOld = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  bool _isSaving = false;

  /// Aturan sama dengan backend: 8-72 karakter, ada huruf besar, huruf kecil, dan angka.
  bool _isStrongPassword(String value) {
    return value.length >= 8 &&
        value.length <= 72 &&
        RegExp(r'[A-Z]').hasMatch(value) &&
        RegExp(r'[a-z]').hasMatch(value) &&
        RegExp(r'[0-9]').hasMatch(value);
  }

  void _showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _onSimpanTap() async {
    if (_isSaving) return;

    final oldPassword = _oldPasswordController.text;
    final newPassword = _newPasswordController.text;
    final confirm = _confirmPasswordController.text;

    if (oldPassword.isEmpty || newPassword.isEmpty || confirm.isEmpty) {
      _showMessage('Semua kolom wajib diisi.');
      return;
    }
    if (!_isStrongPassword(newPassword)) {
      _showMessage(
        'Password baru minimal 8 karakter dan harus mengandung huruf besar, huruf kecil, dan angka.',
      );
      return;
    }
    if (newPassword != confirm) {
      _showMessage('Konfirmasi password tidak sama.');
      return;
    }
    if (newPassword == oldPassword) {
      _showMessage('Password baru harus berbeda dari password lama.');
      return;
    }

    setState(() => _isSaving = true);
    final auth = context.read<AuthProvider>();
    final success = await auth.changePassword(
      currentPassword: oldPassword,
      newPassword: newPassword,
    );
    if (!mounted) return;
    setState(() => _isSaving = false);

    if (!success) {
      _showMessage(auth.errorMessage ?? 'Gagal mengganti password. Coba lagi.');
      return;
    }
    _showMessage('Password berhasil diubah');
    Navigator.of(context).maybePop();
  }

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
                  child: const Icon(Icons.arrow_back, color: AppColors.primary, size: 24),
                ),
                const SizedBox(width: 12),
                Text(
                  'Ganti Password',
                  style: AppTextStyles.greetingTitle.copyWith(fontSize: 22, color: AppColors.primary),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Pastikan password kamu kuat dan mudah diingat.',
              style: AppTextStyles.greetingSubtitle,
            ),
            const SizedBox(height: 24),

            Text('Password Lama', style: AppTextStyles.productName.copyWith(fontSize: 13)),
            const SizedBox(height: 8),
            TextField(
              controller: _oldPasswordController,
              obscureText: _obscureOld,
              decoration: InputDecoration(
                hintText: 'Masukkan password lama',
                hintStyle: AppTextStyles.searchHint,
                filled: true,
                fillColor: AppColors.inputBackground,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureOld ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
                  onPressed: () => setState(() => _obscureOld = !_obscureOld),
                ),
              ),
            ),
            const SizedBox(height: 20),

            Text('Password Baru', style: AppTextStyles.productName.copyWith(fontSize: 13)),
            const SizedBox(height: 8),
            TextField(
              controller: _newPasswordController,
              obscureText: _obscureNew,
              decoration: InputDecoration(
                hintText: 'Masukkan password baru',
                hintStyle: AppTextStyles.searchHint,
                filled: true,
                fillColor: AppColors.inputBackground,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureNew ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
                  onPressed: () => setState(() => _obscureNew = !_obscureNew),
                ),
              ),
            ),
            const SizedBox(height: 20),

            Text('Konfirmasi Password Baru', style: AppTextStyles.productName.copyWith(fontSize: 13)),
            const SizedBox(height: 8),
            TextField(
              controller: _confirmPasswordController,
              obscureText: _obscureConfirm,
              decoration: InputDecoration(
                hintText: 'Konfirmasi password baru',
                hintStyle: AppTextStyles.searchHint,
                filled: true,
                fillColor: AppColors.inputBackground,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirm ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
                  onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                ),
              ),
            ),
            const SizedBox(height: 32),

            ElevatedButton(
              onPressed: _isSaving ? null : _onSimpanTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                elevation: 0,
              ),
              child: Text(
                _isSaving ? 'Menyimpan...' : 'Simpan',
                style: AppTextStyles.productName.copyWith(color: AppColors.textOnPrimary, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}