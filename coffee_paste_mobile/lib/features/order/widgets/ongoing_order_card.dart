import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../models/order_model.dart';
import 'order_date_row.dart';
import 'order_estimate_banner.dart';
import 'order_pill.dart';
import 'order_product_tile.dart';
import 'order_progress_bar.dart';
import 'order_total_row.dart';

/// Kartu pesanan pada tab "Sedang Berlangsung".
class OngoingOrderCard extends StatelessWidget {
  final OrderModel order;

  /// Buka halaman pembayaran (QR QRIS / instruksi tunai).
  final VoidCallback? onPay;

  /// Batalkan pesanan. Tombol hanya tampil selama [OrderModel.canCancel].
  final VoidCallback? onCancel;

  /// Buka struk. Tombol hanya tampil bila pesanan sudah lunas.
  final VoidCallback? onReceipt;

  const OngoingOrderCard({
    super.key,
    required this.order,
    this.onPay,
    this.onCancel,
    this.onReceipt,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              OrderPill(
                child: Text(
                  'Pesanan ${order.orderLabel}',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
              OrderPill(
                child: Row(
                  children: [
                    Icon(
                      Icons.shopping_bag_outlined,
                      size: 18,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      order.orderType,
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          OrderDateRow(date: order.date),
          const SizedBox(height: 22),
          OrderProgressBar(currentStep: order.status.stepIndex),
          const SizedBox(height: 20),
          _ItemsBox(items: order.items),
          const SizedBox(height: 18),
          OrderTotalRow(total: order.total),
          const SizedBox(height: 12),
          _PaymentRow(order: order),
          const SizedBox(height: 12),
          _Actions(
            order: order,
            onPay: onPay,
            onCancel: onCancel,
            onReceipt: onReceipt,
          ),
          if (order.paid) ...[
            const SizedBox(height: 4),
            const OrderEstimateBanner(),
          ],
        ],
      ),
    );
  }
}

/// Baris metode + status pembayaran ("Lunas" / "Menunggu pembayaran").
class _PaymentRow extends StatelessWidget {
  final OrderModel order;

  const _PaymentRow({required this.order});

  @override
  Widget build(BuildContext context) {
    final paid = order.paid;
    final color = paid ? AppColors.primary : Colors.orange.shade800;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Bayar: ${order.paymentMethod.label}',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
        ),
        OrderPill(
          compact: true,
          color: color,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                paid ? Icons.check_circle : Icons.hourglass_top,
                size: 15,
                color: color,
              ),
              const SizedBox(width: 5),
              Text(
                paid ? 'Lunas' : 'Menunggu pembayaran',
                key: const Key('payment-status'),
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Tombol aksi: bayar / lihat QR, struk, dan batalkan.
class _Actions extends StatelessWidget {
  final OrderModel order;
  final VoidCallback? onPay;
  final VoidCallback? onCancel;
  final VoidCallback? onReceipt;

  const _Actions({
    required this.order,
    this.onPay,
    this.onCancel,
    this.onReceipt,
  });

  @override
  Widget build(BuildContext context) {
    final isQris = order.paymentMethod == PaymentMethod.qris;

    return Wrap(
      alignment: WrapAlignment.end,
      spacing: 8,
      runSpacing: 8,
      children: [
        if (order.canCancel)
          OutlinedButton(
            key: const Key('cancel-button'),
            onPressed: onCancel,
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red.shade600,
              side: BorderSide(color: Colors.red.shade300),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
              ),
            ),
            child: const Text('Batalkan'),
          ),
        if (!order.paid)
          FilledButton.icon(
            key: const Key('pay-button'),
            onPressed: onPay,
            icon: Icon(
              isQris ? Icons.qr_code_2 : Icons.payments_outlined,
              size: 18,
            ),
            label: Text(isQris ? 'Bayar / Lihat QR' : 'Cara Bayar'),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
              ),
            ),
          )
        else
          FilledButton.icon(
            key: const Key('receipt-button'),
            onPressed: onReceipt,
            icon: const Icon(Icons.receipt_long_outlined, size: 18),
            label: const Text('Lihat Struk'),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
              ),
            ),
          ),
      ],
    );
  }
}

/// Kotak abu-abu berisi daftar produk, dipisah garis tipis.
class _ItemsBox extends StatelessWidget {
  final List<OrderItem> items;

  const _ItemsBox({required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          for (int i = 0; i < items.length; i++) ...[
            OrderProductTile(item: items[i]),
            if (i != items.length - 1)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Divider(
                  height: 1,
                  color: AppColors.border.withOpacity(0.5),
                ),
              ),
          ],
        ],
      ),
    );
  }
}
