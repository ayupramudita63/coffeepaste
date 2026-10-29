import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../providers/cart_provider.dart';
import '../../providers/menu_provider.dart';
import '../../providers/order_provider.dart';
import '../../shared/widgets/error_retry_view.dart';
import 'models/order_model.dart';
import 'order_actions.dart';
import 'reorder_plan.dart';
import 'widgets/history_order_card.dart';
import 'widgets/ongoing_order_card.dart';
import 'widgets/order_empty_state.dart';
import 'widgets/order_tab_bar.dart';
import 'widgets/review_order_sheet.dart';

/// Halaman Pesanan: tab "Sedang Berlangsung" dan "Riwayat".
///
/// Polling status pesanan tidak diatur di sini: layar ini selalu hidup di
/// dalam IndexedStack, jadi pollingnya dipegang `MainNavigationScreen` supaya
/// notifikasi tetap berjalan walau tab lain yang aktif.
class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  static const _ongoingTab = 0;

  int _selectedTab = _ongoingTab;

  bool get _isOngoingTab => _selectedTab == _ongoingTab;

  /// "Pesan Lagi": salin item pesanan ke keranjang (harga & ketersediaan dari
  /// menu terbaru), lalu buka keranjang.
  Future<void> _reorder(OrderModel order) async {
    final menu = context.read<MenuProvider>();
    final cart = context.read<CartProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);

    void notify(String message) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(message)));
    }

    if (!menu.hasData) {
      await menu.loadMenu();
      if (!mounted) return;
    }
    if (!menu.hasData) {
      notify(menu.errorMessage ?? 'Menu belum bisa dimuat. Coba lagi.');
      return;
    }

    final plan = ReorderPlan.from(order, menu.products);
    if (plan.lines.isEmpty) {
      notify('Menu pada pesanan ini sedang tidak tersedia.');
      return;
    }

    for (final line in plan.lines) {
      cart.addItem(
        product: line.product,
        quantity: line.quantity,
        ice: line.ice,
        sugar: line.sugar,
        size: line.size,
      );
    }

    router.push(AppRoutes.cart);
    if (plan.unavailableNames.isNotEmpty) {
      notify('${plan.unavailableNames.join(', ')} tidak tersedia '
          'dan tidak ditambahkan.');
    }
  }

  Future<void> _review(OrderModel order) async {
    final messenger = ScaffoldMessenger.of(context);
    final menu = context.read<MenuProvider>();

    final sent = await ReviewOrderSheet.show(context, order);
    if (sent != true) return;

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(content: Text('Terima kasih atas ulasanmu!')),
      );
    // Rating produk berubah di server; muat ulang tanpa loading.
    menu.refreshQuietly();
  }

  @override
  Widget build(BuildContext context) {
    final orderProvider = context.watch<OrderProvider>();

    final orders = _isOngoingTab
        ? orderProvider.ongoingOrders
        : orderProvider.historyOrders;

    return Container(
      color: AppColors.background,
      child: SafeArea(
        child: Column(
          children: [
            const _OrdersHeader(),
            const SizedBox(height: 18),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: OrderTabBar(
                selectedIndex: _selectedTab,
                onChanged: (index) {
                  setState(() {
                    _selectedTab = index;
                  });
                },
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: (orderProvider.isLoading && orderProvider.orders.isEmpty)
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    )
                  : (orderProvider.isError && orderProvider.orders.isEmpty)
                      ? ErrorRetryView(
                          message: orderProvider.errorMessage ??
                              'Terjadi kesalahan. Coba lagi.',
                          onRetry: orderProvider.loadOrders,
                        )
                      : orders.isEmpty
                  ? OrderEmptyState(
                      icon: _isOngoingTab
                          ? Icons.receipt_long_outlined
                          : Icons.history,
                      title: _isOngoingTab
                          ? 'Belum ada pesanan'
                          : 'Belum ada riwayat',
                      subtitle: _isOngoingTab
                          ? 'Pesanan yang sedang berlangsung akan muncul di sini.'
                          : 'Pesanan yang sudah selesai akan muncul di sini.',
                    )
                  : RefreshIndicator(
                      color: AppColors.primary,
                      onRefresh: orderProvider.loadOrders,
                      child: ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 110),
                      itemCount: orders.length,
                      itemBuilder: (context, index) {
                        final order = orders[index];

                        if (_isOngoingTab) {
                          return OngoingOrderCard(
                            order: order,
                            onPay: () => context.push(
                              AppRoutes.orderPayment,
                              extra: order.id,
                            ),
                            onCancel: () =>
                                cancelOrderWithConfirm(context, order),
                            onReceipt: () => context.push(
                              AppRoutes.orderReceipt,
                              extra: order.id,
                            ),
                          );
                        }

                        return HistoryOrderCard(
                          order: order,
                          onReorder: () => _reorder(order),
                          onReview: () => _review(order),
                          onReceipt: () => context.push(
                            AppRoutes.orderReceipt,
                            extra: order.id,
                          ),
                        );
                      },
                    ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrdersHeader extends StatelessWidget {
  const _OrdersHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      child: SizedBox(
        height: 36,
        child: Center(
          child: Text(
            'Pesanan',
            style: AppTextStyles.sectionTitle.copyWith(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
        ),
      ),
    );
  }
}
