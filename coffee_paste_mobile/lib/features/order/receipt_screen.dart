import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/image_export.dart';
import '../../providers/order_provider.dart';
import 'models/order_model.dart';
import 'widgets/receipt_view.dart';

/// Struk pesanan yang sudah lunas: bisa dilihat dan diunduh sebagai gambar.
class ReceiptScreen extends StatefulWidget {
  /// ID pesanan dari server, mis. "#CP00001".
  final String orderId;

  const ReceiptScreen({super.key, required this.orderId});

  @override
  State<ReceiptScreen> createState() => _ReceiptScreenState();
}

class _ReceiptScreenState extends State<ReceiptScreen> {
  final GlobalKey _boundaryKey = GlobalKey();
  bool _saving = false;

  Future<void> _download(OrderModel order) async {
    if (_saving) return;
    setState(() => _saving = true);
    final messenger = ScaffoldMessenger.of(context);

    final ok = await captureAndSave(
      _boundaryKey,
      'struk_${order.orderNumber.replaceAll('#', '')}',
    );
    if (!mounted) return;
    setState(() => _saving = false);

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            ok
                ? 'Struk tersimpan di galeri.'
                : 'Gagal menyimpan struk. Periksa izin galeri.',
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final order = context.watch<OrderProvider>().orderById(widget.orderId);

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
                    onTap: () => Navigator.of(context).maybePop(),
                    child: const Icon(Icons.arrow_back,
                        color: AppColors.primary, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Struk Pesanan',
                    style: AppTextStyles.greetingTitle
                        .copyWith(fontSize: 22, color: AppColors.primary),
                  ),
                ],
              ),
            ),
            Expanded(child: _body(order)),
          ],
        ),
      ),
    );
  }

  Widget _body(OrderModel? order) {
    if (order == null) {
      return const _Notice('Pesanan tidak ditemukan.');
    }
    if (!order.paid) {
      return const _Notice(
        'Struk tersedia setelah pembayaran dikonfirmasi.',
      );
    }

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: ReceiptView(order: order, boundaryKey: _boundaryKey),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              key: const Key('download-receipt'),
              onPressed: _saving ? null : () => _download(order),
              icon: const Icon(Icons.download_rounded, color: Colors.white),
              label: Text(
                _saving ? 'Menyimpan...' : 'Unduh Struk',
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
          ),
        ),
      ],
    );
  }
}

class _Notice extends StatelessWidget {
  final String text;
  const _Notice(this.text);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: AppTextStyles.ratingText.copyWith(fontSize: 14),
        ),
      ),
    );
  }
}
