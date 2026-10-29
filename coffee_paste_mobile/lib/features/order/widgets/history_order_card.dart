import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../models/order_model.dart';
import 'order_date_row.dart';
import 'order_pill.dart';
import 'order_product_tile.dart';
import 'order_total_row.dart';

/// Kartu pesanan pada tab "Riwayat" (selesai atau dibatalkan).
class HistoryOrderCard extends StatelessWidget {
  final OrderModel order;

  /// Dipanggil saat tombol "Pesan Lagi" ditekan.
  final VoidCallback? onReorder;

  /// Dipanggil saat tombol "Beri Ulasan" ditekan. Tombol hanya tampil untuk pesanan
  /// selesai yang masih punya produk belum diulas.
  final VoidCallback? onReview;

  /// Dipanggil saat tombol "Lihat Struk" ditekan. Tombol hanya tampil untuk pesanan lunas.
  final VoidCallback? onReceipt;

  const HistoryOrderCard({
    super.key,
    required this.order,
    this.onReorder,
    this.onReview,
    this.onReceipt,
  });

  @override
  Widget build(BuildContext context) {
    final canReview = order.reviewableItems.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              OrderPill(
                compact: true,
                opacity: 0.07,
                child: Text(
                  'Pesanan ${order.orderLabel}',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              _StatusPill(status: order.status),
            ],
          ),
          const SizedBox(height: 12),
          OrderDateRow(date: order.date, compact: true),
          const SizedBox(height: 14),
          for (int i = 0; i < order.items.length; i++)
            Padding(
              padding: EdgeInsets.only(
                bottom: i == order.items.length - 1 ? 0 : 12,
              ),
              child: OrderProductTile(item: order.items[i], compact: true),
            ),
          const SizedBox(height: 14),
          Divider(
            color: AppColors.border.withOpacity(0.5),
          ),
          const SizedBox(height: 12),
          OrderTotalRow(total: order.total, compact: true),
          const SizedBox(height: 12),
          // Semua aksi sejajar dalam satu baris. Tiap tombol berbagi lebar sama
          // dan teksnya mengecil otomatis bila layar sempit, jadi tidak turun baris.
          Row(
            children: [
              if (order.isFullyReviewed) ...[
                Flexible(
                  child: Row(
                    key: const Key('reviewed-label'),
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle_outline,
                          size: 14, color: AppColors.textSecondary),
                      const SizedBox(width: 3),
                      Flexible(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            'Sudah diulas',
                            maxLines: 1,
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
              ],
              if (order.paid) ...[
                Expanded(
                  child: OutlinedButton.icon(
                    key: const Key('receipt-button'),
                    onPressed: onReceipt,
                    icon: const Icon(Icons.receipt_long_outlined, size: 14),
                    label: _buttonLabel('Lihat Struk'),
                    style: _outlinedStyle(),
                  ),
                ),
                const SizedBox(width: 6),
              ],
              if (canReview) ...[
                Expanded(
                  child: FilledButton.icon(
                    key: const Key('review-button'),
                    onPressed: onReview,
                    icon: const Icon(Icons.star_rounded, size: 14),
                    label: _buttonLabel('Beri Ulasan'),
                    style: _filledStyle(),
                  ),
                ),
                const SizedBox(width: 6),
              ],
              Expanded(
                child: OutlinedButton.icon(
                  key: const Key('reorder-button'),
                  onPressed: onReorder,
                  icon: const Icon(Icons.refresh, size: 14),
                  label: _buttonLabel('Pesan Lagi'),
                  style: _outlinedStyle(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static Widget _buttonLabel(String text) => FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          text,
          maxLines: 1,
          softWrap: false,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
      );

  static const _compactPadding = EdgeInsets.symmetric(horizontal: 8, vertical: 6);
  static const _compactSize = Size(0, 34);

  static ButtonStyle _outlinedStyle() => OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: BorderSide(color: AppColors.primary),
        padding: _compactPadding,
        minimumSize: _compactSize,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      );

  static ButtonStyle _filledStyle() => FilledButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        padding: _compactPadding,
        minimumSize: _compactSize,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      );
}

/// Label status di kartu Riwayat: "Selesai" atau "Dibatalkan".
class _StatusPill extends StatelessWidget {
  final OrderStatus status;

  const _StatusPill({required this.status});

  @override
  Widget build(BuildContext context) {
    final isCancelled = status == OrderStatus.cancelled;
    final color = isCancelled ? Colors.red.shade600 : AppColors.primary;

    return OrderPill(
      compact: true,
      color: color,
      child: Row(
        children: [
          Icon(
            isCancelled ? Icons.cancel_outlined : Icons.check_circle,
            color: color,
            size: 16,
          ),
          const SizedBox(width: 5),
          Text(
            isCancelled ? 'Dibatalkan' : 'Selesai',
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}