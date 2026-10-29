import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/cart_provider.dart';
import '../../providers/order_provider.dart';
import '../order/models/order_model.dart';
import '../auth/widgets/corner_leaf_decoration.dart';
import 'widgets/cart_bottom_bar.dart';
import 'widgets/cart_content.dart';
import 'widgets/cart_empty_state.dart';
import 'widgets/checkout_header.dart';

/// Halaman Keranjang + Checkout dalam satu layar.
class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  bool _isPickUp = true;
  PaymentMethod _paymentMethod = PaymentMethod.qris;

  String get _orderTypeLabel => _isPickUp ? 'Pick Up' : 'Dine In';

  Future<void> _onPesanTap() async {
    final cart = context.read<CartProvider>();
    final orderProvider = context.read<OrderProvider>();

    if (cart.isEmpty || orderProvider.isSubmitting) return;

    // Kirim pesanan ke backend.
    final success = await orderProvider.createOrder(
      items: cart.items,
      orderType: _orderTypeLabel,
      paymentMethod: _paymentMethod,
    );

    if (!mounted) return;

    if (!success) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              orderProvider.submitError ?? 'Gagal membuat pesanan. Coba lagi.',
            ),
          ),
        );
      return;
    }

    // Pesanan berhasil dibuat, keranjang dikosongkan.
    cart.clear();

    final order = orderProvider.lastCreatedOrder;
    if (order == null) {
      context.go(AppRoutes.home);
      return;
    }

    // Halaman pembayaran: QR QRIS atau instruksi bayar tunai ke kasir.
    // Menggantikan keranjang, jadi tombol kembali mengarah ke halaman sebelumnya.
    context.pushReplacement(AppRoutes.orderPayment, extra: order.id);
  }

  @override
  Widget build(BuildContext context) {
    final isEmpty = context.watch<CartProvider>().isEmpty;

    return Scaffold(
      backgroundColor: AppColors.authBackground,
      body: Stack(
        children: [
          const Positioned(
            left: -10,
            top: 30,
            child: CornerLeafDecoration(
              imagePath: 'assets/images/leaf_top_left.png',
              width: 100,
            ),
          ),
          const Positioned(
            right: -10,
            top: 30,
            child: CornerLeafDecoration(
              imagePath: 'assets/images/leaf_top_right.png',
              width: 100,
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                const CheckoutHeader(),
                Expanded(
                  child: isEmpty
                      ? const CartEmptyState()
                      : CartContent(
                          isPickUp: _isPickUp,
                          onOrderTypeChanged: (value) {
                            setState(() {
                              _isPickUp = value;
                            });
                          },
                          paymentMethod: _paymentMethod,
                          onPaymentMethodChanged: (value) {
                            setState(() {
                              _paymentMethod = value;
                            });
                          },
                        ),
                ),
                if (!isEmpty) CartBottomBar(onOrderTap: _onPesanTap),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
