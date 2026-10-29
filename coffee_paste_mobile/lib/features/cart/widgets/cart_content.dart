import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/cart_provider.dart';
import '../../order/models/order_model.dart';
import 'cancellation_policy_note.dart';
import 'cart_add_more_row.dart';
import 'cart_estimate_bar.dart';
import 'cart_item_tile.dart';
import 'cart_section_title.dart';
import 'order_type_toggle.dart';
import 'payment_option_tile.dart';
import 'payment_summary_card.dart';

/// Isi halaman checkout saat keranjang tidak kosong.
class CartContent extends StatelessWidget {
  final bool isPickUp;
  final ValueChanged<bool> onOrderTypeChanged;
  final PaymentMethod paymentMethod;
  final ValueChanged<PaymentMethod> onPaymentMethodChanged;

  const CartContent({
    super.key,
    required this.isPickUp,
    required this.onOrderTypeChanged,
    required this.paymentMethod,
    required this.onPaymentMethodChanged,
  });

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          OrderTypeToggle(
            isPickUp: isPickUp,
            onChanged: onOrderTypeChanged,
          ),
          const SizedBox(height: 12),
          const CartEstimateBar(),
          const SizedBox(height: 20),
          const CartSectionTitle('Detail Pesanan'),
          for (final item in cart.items)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: CartItemTile(
                item: item,
                onIncrease: () {
                  context.read<CartProvider>().increaseQuantity(item.key);
                },
                onDecrease: () {
                  context.read<CartProvider>().decreaseQuantity(item.key);
                },
              ),
            ),
          const SizedBox(height: 8),
          CartAddMoreRow(
            onAddTap: () => Navigator.of(context).maybePop(),
          ),
          const SizedBox(height: 20),
          const CartSectionTitle('Metode Pembayaran'),
          PaymentOptionTile(
            icon: Icons.qr_code_2,
            title: 'QRIS',
            subtitle: 'Scan kode QR dengan e-wallet atau mobile banking.',
            selected: paymentMethod == PaymentMethod.qris,
            onTap: () => onPaymentMethodChanged(PaymentMethod.qris),
          ),
          const SizedBox(height: 10),
          PaymentOptionTile(
            icon: Icons.payments_outlined,
            title: 'Tunai',
            subtitle: 'Bayar langsung ke kasir di kedai.',
            selected: paymentMethod == PaymentMethod.cash,
            onTap: () => onPaymentMethodChanged(PaymentMethod.cash),
          ),
          const SizedBox(height: 20),
          const CartSectionTitle('Rincian Pembayaran'),
          PaymentSummaryCard(
            subtotal: cart.totalPrice,
            tax: cart.taxAmount,
            total: cart.grandTotal,
          ),
          const SizedBox(height: 16),
          const CancellationPolicyNote(),
        ],
      ),
    );
  }
}
