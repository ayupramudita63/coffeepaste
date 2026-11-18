import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_style.dart';
import '../../core/theme/app_text_styles.dart';
import '../../providers/app_navigation_provider.dart';
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
class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen>
    with WidgetsBindingObserver {
  static const _ongoingTab = 0;

  int _selectedTab = _ongoingTab;

  late final AppNavigationProvider _nav;
  late final OrderProvider _orders;
  AppLifecycleState _lifecycle = AppLifecycleState.resumed;

  bool get _isOngoingTab => _selectedTab == _ongoingTab;

  /// Layar ini berada di IndexedStack, jadi tetap hidup walau tab lain aktif.
  /// Polling dihidupkan hanya saat tab Pesanan terlihat DAN aplikasi di depan.
  bool get _isVisible => _nav.tabIndex == AppNavigationProvider.ordersTab;

  @override
  void initState() {
    super.initState();
    _nav = context.read<AppNavigationProvider>();
    _orders = context.read<OrderProvider>();
    _nav.addListener(_syncPolling);
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncPolling());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _nav.removeListener(_syncPolling);
    _orders.stopPolling();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _lifecycle = state;
    _syncPolling();
    // Kembali dari background: perbarui langsung, jangan tunggu putaran berikutnya.
    if (state == AppLifecycleState.resumed && _isVisible) {
      _orders.refreshSilently();
    }
  }

  void _syncPolling() {
    final shouldPoll =
        _isVisible && _lifecycle == AppLifecycleState.resumed;
    if (shouldPoll) {
      _orders.startPolling();
    } else {
      _orders.stopPolling();
    }
  }

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
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppStyle.screenPadding,
              ),
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
                  ? Center(
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
                      padding: const EdgeInsets.fromLTRB(
                        AppStyle.screenPadding,
                        0,
                        AppStyle.screenPadding,
                        24,
                      ),
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
      padding: const EdgeInsets.fromLTRB(
        AppStyle.screenPadding,
        14,
        AppStyle.screenPadding,
        0,
      ),
      child: SizedBox(
        height: 44,
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Pesanan',
            style: AppTextStyles.sectionTitle.copyWith(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.6,
            ),
          ),
        ),
      ),
    );
  }
}
