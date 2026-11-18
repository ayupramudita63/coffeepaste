import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_style.dart';
import 'package:flutter/cupertino.dart' show CupertinoSwitch;

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  bool _orderNotif = true;
  bool _paymentNotif = true;

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
                  child: Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.primary, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  'Notifikasi',
                  style: AppTextStyles.greetingTitle.copyWith(fontSize: 22, color: AppColors.primary),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Pilih notifikasi yang ingin kamu terima.',
              style: AppTextStyles.greetingSubtitle,
            ),
            const SizedBox(height: 20),

            _NotificationToggleTile(
              icon: Icons.inventory_2_outlined,
              title: 'Notifikasi Pesanan',
              subtitle: 'Dapatkan informasi terbaru mengenai pesanan kamu.',
              value: _orderNotif,
              onChanged: (value) => setState(() => _orderNotif = value),
            ),
            const SizedBox(height: 12),
            _NotificationToggleTile(
              icon: Icons.credit_card_outlined,
              title: 'Notifikasi Pembayaran',
              subtitle: 'Dapatkan pemberitahuan terkait pembayaran kamu.',
              value: _paymentNotif,
              onChanged: (value) => setState(() => _paymentNotif = value),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationToggleTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _NotificationToggleTile({
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
      decoration: AppStyle.card(),
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
          CupertinoSwitch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}