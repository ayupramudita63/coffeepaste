import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/app_navigation_provider.dart';
import '../../providers/menu_provider.dart';
import '../../providers/notification_provider.dart';
import '../../providers/order_provider.dart';
import 'widgets/bottom_nav_bar.dart';
import '../home/home_screen.dart';
import '../menu/menu_screen.dart';
import '../order/orders_screen.dart';
import '../account/account_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen>
    with WidgetsBindingObserver {
  static const int _ordersTabIndex = 2;

  static const List<Widget> _pages = [
    HomeScreen(),
    MenuScreen(),
    OrdersScreen(),
    AccountScreen(),
  ];

  late final OrderProvider _orders;
  AppLifecycleState _lifecycle = AppLifecycleState.resumed;

  @override
  void initState() {
    super.initState();
    _orders = context.read<OrderProvider>();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<MenuProvider>().loadMenu();
      _orders.loadOrders();
      _syncPolling();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    // Penanggung jawab polling pindah ke layar ini, jadi berhenti di sini
    // (layar Pesanan tidak lagi mengatur timer).
    _orders.stopPolling();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _lifecycle = state;
    _syncPolling();
    // Kembali dari background: tarik perubahan terbaru supaya tidak tertunda
    // sampai tab Pesanan dibuka. Bila push server aktif, perubahan selama di
    // background pasti sudah tampil sebagai notifikasi push, jadi tarikan ini
    // cukup memperbarui data tanpa mengirim notifikasi kedua.
    if (state == AppLifecycleState.resumed) {
      final pushActive =
          context.read<NotificationProvider>().pushEnabled;
      _orders.refreshSilently(onlyIfOngoing: true, notify: !pushActive);
    }
  }

  /// Polling berjalan selama aplikasi terlihat, di tab mana pun.
  /// Pengecekan server sendiri hanya terjadi bila ada pesanan berlangsung
  /// (`refreshSilently(onlyIfOngoing: true)`), jadi timer ini murah.
  void _syncPolling() {
    if (_lifecycle == AppLifecycleState.resumed) {
      _orders.startPolling();
    } else {
      _orders.stopPolling();
    }
  }

  void _onTabTap(int index) {
    context.read<AppNavigationProvider>().setTab(index);

    // Status pesanan bisa berubah di kasir, jadi muat ulang saat tab dibuka.
    if (index == _ordersTabIndex) {
      _orders.loadOrders();
    }
  }

  @override
  Widget build(BuildContext context) {
    final nav = context.watch<AppNavigationProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      extendBody: true,
      bottomNavigationBar: BottomNavBar(
        currentIndex: nav.tabIndex,
        onTap: _onTabTap,
      ),
      body: IndexedStack(
        index: nav.tabIndex,
        children: _pages,
      ),
    );
  }
}
