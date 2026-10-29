import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/order_provider.dart';
import 'models/order_model.dart';

/// Konfirmasi lalu batalkan pesanan. Mengembalikan true bila berhasil dibatalkan.
/// Aturan final ada di backend (hanya selama belum diproses kasir dan belum dibayar).
Future<bool> cancelOrderWithConfirm(
  BuildContext context,
  OrderModel order,
) async {
  final provider = context.read<OrderProvider>();
  final messenger = ScaffoldMessenger.of(context);

  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Batalkan pesanan?'),
      content: Text('Pesanan ${order.orderLabel} akan dibatalkan.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: const Text('Tidak'),
        ),
        TextButton(
          key: const Key('confirm-cancel'),
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: const Text('Ya, batalkan'),
        ),
      ],
    ),
  );
  if (confirmed != true) return false;

  final ok = await provider.cancelOrder(order.id);
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(
          ok
              ? 'Pesanan ${order.orderLabel} dibatalkan.'
              : (provider.submitError ?? 'Gagal membatalkan pesanan.'),
        ),
      ),
    );
  if (!ok) {
    // Status di server mungkin sudah berubah (mis. kasir baru memproses): sinkronkan.
    provider.refreshSilently();
  }
  return ok;
}
