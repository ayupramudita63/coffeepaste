import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../models/order_model.dart';

/// Tampilan struk. Dibungkus [RepaintBoundary] supaya bisa dipotret jadi gambar
/// (tombol "Unduh Struk"); background putih sengaja tetap putih agar hasil unduhan jelas.
class ReceiptView extends StatelessWidget {
  final OrderModel order;
  final GlobalKey boundaryKey;

  const ReceiptView({
    super.key,
    required this.order,
    required this.boundaryKey,
  });

  static const _ink = Color(0xFF1F2A1F);
  static const _muted = Color(0xFF6B7280);

  @override
  Widget build(BuildContext context) {
    final isCash = order.paymentMethod == PaymentMethod.cash;
    final cashier = order.cashierName;

    return RepaintBoundary(
      key: boundaryKey,
      child: Container(
        width: double.infinity,
        color: Colors.white,
        padding: const EdgeInsets.fromLTRB(22, 24, 22, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'COFFEE PASTE',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 20,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Struk Pembayaran',
              textAlign: TextAlign.center,
              style: TextStyle(color: _muted, fontSize: 13),
            ),
            const SizedBox(height: 12),
            Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'LUNAS',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            _meta('No. Pesanan', order.orderLabel),
            _meta('Tanggal', formatOrderDate(order.date)),
            _meta('Tipe', order.orderType),
            if (cashier != null && cashier.isNotEmpty) _meta('Kasir', cashier),
            const _Dashed(),
            for (final item in order.items) _itemRow(item),
            const _Dashed(),
            _amount('Subtotal', order.subtotal),
            _amount('PPN 11%', order.taxAmount),
            const SizedBox(height: 6),
            _amount('Total', order.total, bold: true),
            const _Dashed(),
            _meta('Metode', order.paymentMethod.label),
            if (isCash && order.cashReceived != null) ...[
              _amount('Tunai', order.cashReceived!),
              _amount('Kembalian', order.change),
            ],
            const SizedBox(height: 18),
            const Text(
              'Terima kasih atas pembelian Anda!',
              textAlign: TextAlign.center,
              style: TextStyle(color: _ink, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _meta(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: _muted, fontSize: 13)),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: _ink,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _itemRow(OrderItem item) {
    final variant = item.variant;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  item.name,
                  style: const TextStyle(
                    color: _ink,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                formatRupiah(item.subtotal),
                style: const TextStyle(color: _ink, fontSize: 14),
              ),
            ],
          ),
          Text(
            '${item.quantity} x ${formatRupiah(item.price)}',
            style: const TextStyle(color: _muted, fontSize: 12),
          ),
          if (variant != null && variant.isNotEmpty)
            Text(variant, style: const TextStyle(color: _muted, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _amount(String label, int value, {bool bold = false}) {
    final style = TextStyle(
      color: bold ? AppColors.primary : _ink,
      fontSize: bold ? 17 : 14,
      fontWeight: bold ? FontWeight.w800 : FontWeight.w500,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: style),
          Text(formatRupiah(value), style: style),
        ],
      ),
    );
  }
}

class _Dashed extends StatelessWidget {
  const _Dashed();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final count = (constraints.maxWidth / 8).floor();
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(
              count,
              (_) => const SizedBox(
                width: 4,
                height: 1,
                child: DecoratedBox(
                  decoration: BoxDecoration(color: Color(0xFF9CA3AF)),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
