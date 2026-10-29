import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/image_export.dart';
import '../../providers/app_navigation_provider.dart';
import '../../providers/order_provider.dart';
import 'models/order_model.dart';
import 'order_actions.dart';

/// Halaman setelah memesan:
/// - QRIS  : menampilkan QR yang bisa discan atau diunduh.
/// - Tunai : pemberitahuan untuk membayar ke kasir.
/// Status pembayaran diperbarui otomatis; setelah lunas customer bisa membuka struk.
class OrderPaymentScreen extends StatefulWidget {
  /// ID pesanan dari server, mis. "#CP00001".
  final String orderId;

  const OrderPaymentScreen({super.key, required this.orderId});

  @override
  State<OrderPaymentScreen> createState() => _OrderPaymentScreenState();
}

class _OrderPaymentScreenState extends State<OrderPaymentScreen> {
  static const Duration _pollEvery = Duration(seconds: 4);

  final GlobalKey _qrKey = GlobalKey();
  late final OrderProvider _orders;
  Timer? _timer;
  bool _savingQr = false;
  bool _announcedPaid = false;

  @override
  void initState() {
    super.initState();
    _orders = context.read<OrderProvider>();
    // Timer sendiri (bukan polling milik layar Pesanan) supaya tidak saling mematikan.
    _timer = Timer.periodic(_pollEvery, (_) => _refresh());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _refresh() {
    final order = _orders.orderById(widget.orderId);
    // Berhenti bertanya ke server bila sudah lunas atau dibatalkan.
    if (order != null && (order.paid || order.status == OrderStatus.cancelled)) {
      return;
    }
    _orders.refreshSilently();
  }

  Future<void> _saveQr() async {
    if (_savingQr) return;
    setState(() => _savingQr = true);
    final messenger = ScaffoldMessenger.of(context);

    final ok = await captureAndSave(
      _qrKey,
      'qris_${widget.orderId.replaceAll('#', '')}',
    );
    if (!mounted) return;
    setState(() => _savingQr = false);

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            ok
                ? 'QR tersimpan di galeri. Buka aplikasi pembayaran lalu pilih dari galeri.'
                : 'Gagal menyimpan QR. Periksa izin galeri.',
          ),
        ),
      );
  }

  void _openOrdersTab() {
    context.read<AppNavigationProvider>().setTab(AppNavigationProvider.ordersTab);
    context.go(AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    final order = context.watch<OrderProvider>().orderById(widget.orderId);

    if (order != null && order.paid && !_announcedPaid) {
      _announcedPaid = true;
      HapticFeedback.mediumImpact();
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: _openOrdersTab,
                    child: const Icon(Icons.arrow_back,
                        color: AppColors.primary, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Pembayaran',
                    style: AppTextStyles.greetingTitle
                        .copyWith(fontSize: 22, color: AppColors.primary),
                  ),
                ],
              ),
            ),
            Expanded(
              child: order == null
                  ? Center(
                      child: Text(
                        'Pesanan tidak ditemukan.',
                        style: AppTextStyles.ratingText.copyWith(fontSize: 14),
                      ),
                    )
                  : _content(order),
            ),
          ],
        ),
      ),
    );
  }

  Widget _content(OrderModel order) {
    final children = <Widget>[];

    if (order.status == OrderStatus.cancelled) {
      children.add(_StatusCard(
        icon: Icons.cancel_outlined,
        color: Colors.red.shade600,
        title: 'Pesanan dibatalkan',
        message: 'Pesanan ${order.orderLabel} sudah dibatalkan.',
      ));
    } else if (order.paid) {
      children.add(_StatusCard(
        icon: Icons.check_circle,
        color: AppColors.primary,
        title: 'Pembayaran diterima',
        message:
            'Pesanan ${order.orderLabel} sudah lunas. Kasir akan menyiapkan pesananmu.',
      ));
      children.add(const SizedBox(height: 16));
      children.add(_PrimaryButton(
        key: const Key('view-receipt'),
        icon: Icons.receipt_long_outlined,
        label: 'Lihat Struk',
        onPressed: () =>
            context.push(AppRoutes.orderReceipt, extra: order.id),
      ));
    } else if (order.paymentMethod == PaymentMethod.qris) {
      children.addAll(_qrisSection(order));
    } else {
      children.add(_cashSection(order));
    }

    if (order.canCancel) {
      children.add(const SizedBox(height: 12));
      children.add(
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            key: const Key('cancel-order'),
            onPressed: () => cancelOrderWithConfirm(context, order),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red.shade600,
              side: BorderSide(color: Colors.red.shade300),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: const Text('Batalkan Pesanan'),
          ),
        ),
      );
      children.add(const SizedBox(height: 6));
      children.add(Text(
        'Pesanan masih bisa dibatalkan selama belum diproses kasir.',
        textAlign: TextAlign.center,
        style: AppTextStyles.ratingText.copyWith(fontSize: 11),
      ));
    }

    children.add(const SizedBox(height: 12));
    children.add(
      TextButton(
        onPressed: _openOrdersTab,
        child: Text('Lihat Pesanan Saya', style: AppTextStyles.sectionAction),
      ),
    );

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
      children: children,
    );
  }

  List<Widget> _qrisSection(OrderModel order) {
    final payload = order.qrisPayload;

    if (payload == null) {
      return [
        _StatusCard(
          icon: Icons.hourglass_top,
          color: AppColors.primary,
          title: 'Menunggu pembayaran',
          message: 'Kode QR belum tersedia. Tunjukkan nomor pesanan '
              '${order.orderLabel} ke kasir untuk membayar ${formatRupiah(order.total)}.',
        ),
      ];
    }

    return [
      RepaintBoundary(
        key: _qrKey,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
          ),
          child: Column(
            children: [
              Text('Scan untuk membayar', style: AppTextStyles.sectionTitle),
              const SizedBox(height: 4),
              Text(order.orderLabel, style: AppTextStyles.ratingText),
              const SizedBox(height: 14),
              QrImageView(
                data: payload,
                version: QrVersions.auto,
                size: 240,
                backgroundColor: Colors.white,
                errorCorrectionLevel: QrErrorCorrectLevel.M,
              ),
              const SizedBox(height: 12),
              Text(
                formatRupiah(order.total),
                style: AppTextStyles.greetingTitle
                    .copyWith(fontSize: 26, color: AppColors.primary),
              ),
              const SizedBox(height: 2),
              Text('Total sudah termasuk PPN',
                  style: AppTextStyles.ratingText.copyWith(fontSize: 11)),
            ],
          ),
        ),
      ),
      const SizedBox(height: 14),
      _PrimaryButton(
        key: const Key('download-qr'),
        icon: Icons.download_rounded,
        label: _savingQr ? 'Menyimpan...' : 'Unduh QR',
        onPressed: _savingQr ? null : _saveQr,
      ),
      const SizedBox(height: 14),
      Text(
        'Scan langsung dari layar ini dengan e-wallet atau mobile banking, '
        'atau unduh QR lalu pilih dari galeri. Status berubah otomatis '
        'setelah pembayaran terkonfirmasi.',
        textAlign: TextAlign.center,
        style: AppTextStyles.ratingText.copyWith(fontSize: 12),
      ),
    ];
  }

  Widget _cashSection(OrderModel order) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.payments_outlined,
                size: 32, color: AppColors.primary),
          ),
          const SizedBox(height: 14),
          Text('Bayar tunai ke kasir', style: AppTextStyles.sectionTitle),
          const SizedBox(height: 6),
          Text(
            'Serahkan uang ke kasir dan sebutkan nomor pesananmu.',
            textAlign: TextAlign.center,
            style: AppTextStyles.ratingText.copyWith(fontSize: 13),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.07),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Text('Nomor pesanan', style: AppTextStyles.ratingText),
                const SizedBox(height: 2),
                Text(
                  order.orderLabel,
                  style: AppTextStyles.greetingTitle
                      .copyWith(fontSize: 26, color: AppColors.primary),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Text('Total yang harus dibayar', style: AppTextStyles.ratingText),
          const SizedBox(height: 2),
          Text(
            formatRupiah(order.total),
            style: AppTextStyles.greetingTitle.copyWith(fontSize: 24),
          ),
          const SizedBox(height: 12),
          Text(
            'Halaman ini akan berubah otomatis setelah kasir menerima pembayaran.',
            textAlign: TextAlign.center,
            style: AppTextStyles.ratingText.copyWith(fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String message;

  const _StatusCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        children: [
          Icon(icon, size: 56, color: color),
          const SizedBox(height: 12),
          Text(title, style: AppTextStyles.sectionTitle),
          const SizedBox(height: 6),
          Text(
            message,
            textAlign: TextAlign.center,
            style: AppTextStyles.ratingText.copyWith(fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  const _PrimaryButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, color: Colors.white),
        label: Text(
          label,
          style: AppTextStyles.productName
              .copyWith(color: Colors.white, fontSize: 15),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          elevation: 0,
        ),
      ),
    );
  }
}
