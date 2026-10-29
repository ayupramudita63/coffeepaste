import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../providers/user_provider.dart';

class AccountInfoScreen extends StatefulWidget {
  const AccountInfoScreen({super.key});

  @override
  State<AccountInfoScreen> createState() => _AccountInfoScreenState();
}

class _AccountInfoScreenState extends State<AccountInfoScreen> {
  Future<void> _pickAvatar() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Ganti Foto Profil', style: AppTextStyles.sectionTitle),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined, color: AppColors.primary),
              title: const Text('Ambil dari Kamera'),
              onTap: () {
                Navigator.of(context).pop();
                _getImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined, color: AppColors.primary),
              title: const Text('Pilih dari Galeri'),
              onTap: () {
                Navigator.of(context).pop();
                _getImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _getImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: source, imageQuality: 80);
      if (picked != null) {
        if (!mounted) return;
        context.read<UserProvider>().updateAvatar(File(picked.path));
        // Foto profil baru tersimpan di perangkat ini saja (belum ada endpoint upload customer).
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal mengambil foto')),
      );
    }
  }

  void _showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  /// Menyimpan ke server; menampilkan pesan bila gagal.
  Future<void> _save({
    String? name,
    String? phone,
    String? gender,
    String? birthDateIso,
  }) async {
    final error = await context.read<UserProvider>().saveProfile(
          name: name,
          phone: phone,
          gender: gender,
          birthDateIso: birthDateIso,
        );
    if (!mounted) return;
    _showMessage(error ?? 'Perubahan disimpan');
  }

  Future<void> _editTextField({
    required String title,
    required String currentValue,
    required ValueChanged<String> onSaved,
    TextInputType keyboardType = TextInputType.text,
  }) async {
    final controller = TextEditingController(text: currentValue);
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: const InputDecoration(border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(controller.text),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Simpan', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (result != null && result.trim().isNotEmpty) {
      onSaved(result.trim());
    }
  }

  Future<void> _editGender(String currentGender) async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Jenis Kelamin'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('Perempuan'),
              value: 'Perempuan',
              groupValue: currentGender,
              activeColor: AppColors.primary,
              onChanged: (value) => Navigator.of(context).pop(value),
            ),
            RadioListTile<String>(
              title: const Text('Laki-laki'),
              value: 'Laki-laki',
              groupValue: currentGender,
              activeColor: AppColors.primary,
              onChanged: (value) => Navigator.of(context).pop(value),
            ),
          ],
        ),
      ),
    );
    if (result != null && mounted) {
      await _save(gender: result);
    }
  }

  Future<void> _editBirthDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.tryParse(
            context.read<UserProvider>().birthDateIso,
          ) ??
          DateTime(2000, 1, 1),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(primary: AppColors.primary),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      final iso = '${picked.year.toString().padLeft(4, '0')}-'
          '${picked.month.toString().padLeft(2, '0')}-'
          '${picked.day.toString().padLeft(2, '0')}';
      if (!mounted) return;
      await _save(birthDateIso: iso);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>();

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
                  'Informasi Akun',
                  style: AppTextStyles.greetingTitle.copyWith(fontSize: 22, color: AppColors.primary),
                ),
              ],
            ),
            const SizedBox(height: 24),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Stack(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                          image: user.avatarFile != null
                              ? DecorationImage(image: FileImage(user.avatarFile!), fit: BoxFit.cover)
                              : null,
                        ),
                        child: user.avatarFile == null
                            ? const Icon(Icons.person, size: 32, color: AppColors.primary)
                            : null,
                      ),
                      Positioned(
                        bottom: -2,
                        right: -2,
                        child: GestureDetector(
                          onTap: _pickAvatar,
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                              border: Border.fromBorderSide(
                                BorderSide(color: AppColors.surface, width: 2),
                              ),
                            ),
                            child: const Icon(Icons.edit, size: 12, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user.name, style: AppTextStyles.productName.copyWith(fontSize: 16)),
                        const SizedBox(height: 2),
                        Text(user.email, style: AppTextStyles.ratingText),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            Text('Data Pribadi', style: AppTextStyles.sectionTitle),
            const SizedBox(height: 12),

            _InfoFieldTile(
              icon: Icons.person_outline,
              label: 'Nama Lengkap',
              value: user.name,
              onTap: () => _editTextField(
                title: 'Ubah Nama Lengkap',
                currentValue: user.name,
                onSaved: (value) => _save(name: value),
              ),
            ),
            const SizedBox(height: 10),
            _InfoFieldTile(
              icon: Icons.email_outlined,
              label: 'Email',
              value: user.pendingEmail.isEmpty
                  ? user.email
                  : '${user.email} (menunggu verifikasi)',
              onTap: () => context.push(AppRoutes.changeEmail),
            ),
            const SizedBox(height: 10),
            _InfoFieldTile(
              icon: Icons.phone_outlined,
              label: 'Nomor Telepon',
              value: user.phone.isEmpty ? 'Belum diisi' : user.phone,
              onTap: () => _editTextField(
                title: 'Ubah Nomor Telepon',
                currentValue: user.phone,
                keyboardType: TextInputType.phone,
                onSaved: (value) => _save(phone: value),
              ),
            ),
            const SizedBox(height: 10),
            _InfoFieldTile(
              icon: Icons.wc_outlined,
              label: 'Jenis Kelamin',
              value: user.gender.isEmpty ? 'Belum diisi' : user.gender,
              onTap: () => _editGender(user.gender),
            ),
            const SizedBox(height: 10),
            _InfoFieldTile(
              icon: Icons.cake_outlined,
              label: 'Tanggal Lahir',
              value: user.birthDate.isEmpty ? 'Belum diisi' : user.birthDate,
              onTap: _editBirthDate,
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoFieldTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  const _InfoFieldTile({
    required this.icon,
    required this.label,
    required this.value,
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
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 20, color: AppColors.primary),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: AppTextStyles.ratingText),
                  const SizedBox(height: 2),
                  Text(value, style: AppTextStyles.productName),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}