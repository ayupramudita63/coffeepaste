import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/app_navigation_provider.dart';
import '../../providers/menu_provider.dart';
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

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  static const int _ordersTabIndex = 2;

  /// Tab baru dibangun saat pertama dibuka (bukan semuanya sekaligus di awal),
  /// lalu dipertahankan agar posisi scroll dan datanya tidak hilang.
  final Set<int> _visited = {0};

  static const List<Widget> _pages = [
    HomeScreen(),
    MenuScreen(),
    OrdersScreen(),
    AccountScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<MenuProvider>().loadMenu();
      context.read<OrderProvider>().loadOrders();
    });
  }

  void _onTabTap(int index) {
    context.read<AppNavigationProvider>().setTab(index);

    // Status pesanan bisa berubah di kasir, jadi muat ulang saat tab dibuka.
    if (index == _ordersTabIndex) {
      context.read<OrderProvider>().loadOrders();
    }
  }

  @override
  Widget build(BuildContext context) {
    final nav = context.watch<AppNavigationProvider>();
    _visited.add(nav.tabIndex);

    return Scaffold(
      backgroundColor: AppColors.background,
      extendBody: true,
      bottomNavigationBar: BottomNavBar(
        currentIndex: nav.tabIndex,
        onTap: _onTabTap,
      ),
      body: IndexedStack(
        index: nav.tabIndex,
        children: [
          for (var i = 0; i < _pages.length; i++)
            _visited.contains(i) ? _pages[i] : const SizedBox.shrink(),
        ],
      ),
    );
  }
}
