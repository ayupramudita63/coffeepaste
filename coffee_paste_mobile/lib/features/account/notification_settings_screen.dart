import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../providers/notification_provider.dart';

/// Pengaturan notifikasi:
/// - dua sakelar (Pesanan & Pembayaran) yang disimpan permanen di perangkat,
/// - izin notifikasi sistem diminta saat sakelar dinyalakan dan dicoba ulang
///   saat layar kembali aktif (mis. setelah pengguna mengubah Pengaturan HP),
/// - tombol percobaan untuk memastikan notifikasi benar-benar muncul.
class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Muat pilihan tersimpan; bila belum pernah, mulai sekarang.
    context.read<NotificationProvider>().ensureStarted();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Pengguna bisa saja keluar ke Pengaturan sistem lalu kembali.
    if (state == AppLifecycleState.resumed) {
      context.read<NotificationProvider>().refreshSystemStatus();
    }
  }

  Future<void> _setOrder(bool value) async {
    final provider = context.read<NotificationProvider>();
    await provider.setOrderEnabled(value);
    await _warnIfPermissionMissing(value, provider);
  }

  Future<void> _setPayment(bool value) async {
    final provider = context.read<NotificationProvider>();
    await provider.setPaymentEnabled(value);
    await _warnIfPermissionMissing(value, provider);
  }

  /// Bila sakelar dinyalakan tetapi izin sistem belum diberikan, beri tahu
  /// pengguna supaya tidak heran notifikasi tidak muncul.
  Future<void> _warnIfPermissionMissing(
    bool turnedOn,
    NotificationProvider provider,
  ) async {
    if (!turnedOn || provider.systemEnabled || !mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text(
            'Izin notifikasi dari sistem belum diberikan. '
            'Notifikasi tidak akan tampil sampai diizinkan.',
          ),
        ),
      );
  }

  Future<void> _sendTest() async {
    final provider = context.read<NotificationProvider>();
    await provider.sendTestNotification();
    if (!mounted || provider.systemEnabled) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text('Notifikasi masih diblokir oleh sistem.'),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NotificationProvider>();

    return Scaffold(
      backgroundColor: AppColors.authBackground,
      body: SafeArea(
        child: !provider.isLoaded
            ? const Center(child: CircularProgressIndicator())
            : ListView(
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
                        'Notifikasi',
                        style: AppTextStyles.greetingTitle
                            .copyWith(fontSize: 22, color: AppColors.primary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Pilih notifikasi yang ingin kamu terima.',
                    style: AppTextStyles.greetingSubtitle,
                  ),
                  const SizedBox(height: 20),

                  if (!provider.systemEnabled) ...[
                    _PermissionBanner(
                      onRequest: () => provider.requestPermission(),
                    ),
                    const SizedBox(height: 16),
                  ],

                  _NotificationToggleTile(
                    switchKey: const Key('order-notifications-switch'),
                    icon: Icons.inventory_2_outlined,
                    title: 'Notifikasi Pesanan',
                    subtitle: 'Dapatkan informasi terbaru mengenai pesanan kamu.',
                    value: provider.orderEnabled,
                    onChanged: _setOrder,
                  ),
                  const SizedBox(height: 12),
                  _NotificationToggleTile(
                    switchKey: const Key('payment-notifications-switch'),
                    icon: Icons.credit_card_outlined,
                    title: 'Notifikasi Pembayaran',
                    subtitle: 'Dapatkan pemberitahuan terkait pembayaran kamu.',
                    value: provider.paymentEnabled,
                    onChanged: _setPayment,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Pilihanmu tersimpan otomatis di perangkat ini.',
                    style: AppTextStyles.ratingText
                        .copyWith(fontSize: 11, color: AppColors.textMuted),
                  ),

                  const SizedBox(height: 20),
                  OutlinedButton.icon(
                    key: const Key('test-notification'),
                    onPressed:
                        provider.anyEnabled ? () => _sendTest() : null,
                    icon: const Icon(Icons.notifications_active_outlined,
                        color: AppColors.primary),
                    label: Text(
                      'Kirim notifikasi percobaan',
                      style: AppTextStyles.productName
                          .copyWith(color: AppColors.primary, fontSize: 14),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.primary),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                  if (!provider.anyEnabled)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        'Nyalakan salah satu sakelar untuk menerima notifikasi.',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.ratingText
                            .copyWith(fontSize: 11, color: AppColors.textMuted),
                      ),
                    ),
                ],
              ),
      ),
    );
  }
}

/// Peringatan bila izin notifikasi dari sistem nonaktif.
class _PermissionBanner extends StatelessWidget {
  final VoidCallback onRequest;

  const _PermissionBanner({required this.onRequest});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 12, 8, 6),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4E0),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFD699)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.notifications_off_outlined,
                  size: 22, color: Color(0xFFB26A00)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Izin notifikasi dari sistem nonaktif. Notifikasi tidak akan '
                  'muncul sampai kamu mengizinkannya.',
                  style: AppTextStyles.ratingText.copyWith(
                      fontSize: 12, color: const Color(0xFF7A4A00)),
                ),
              ),
            ],
          ),
          TextButton(
            onPressed: onRequest,
            child: Text(
              'Izinkan notifikasi',
              style: AppTextStyles.sectionAction
                  .copyWith(fontSize: 13, color: const Color(0xFFB26A00)),
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationToggleTile extends StatelessWidget {
  final Key? switchKey;
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _NotificationToggleTile({
    this.switchKey,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
            child: Icon(icon, size: 22, color: AppColors.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.productName),
                const SizedBox(height: 2),
                Text(subtitle, style: AppTextStyles.ratingText),
              ],
            ),
          ),
          Switch(
            key: switchKey,
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}
