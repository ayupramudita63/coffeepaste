import 'dart:async';

import 'package:flutter/cupertino.dart' show CupertinoScrollBehavior;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'app_providers.dart';
import 'core/config/app_repositories.dart';
import 'core/network/api_client.dart';
import 'core/notifications/push_service.dart';
import 'core/router/app_router.dart';
import 'core/storage/theme_storage.dart';
import 'core/storage/token_storage.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/data/google_sign_in_service.dart';
import 'providers/app_navigation_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/order_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/user_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final apiClient = ApiClient();
  final repositories = AppRepositories.create(apiClient);
  final push = PushService(apiClient);
  // Firebase/notifikasi disiapkan di latar belakang; tidak menahan tampilan awal.
  unawaited(push.init());

  // Baca pilihan terang/gelap sebelum tampil agar tidak ada kedipan.
  final themeProvider = ThemeProvider(storage: SecureThemeStorage());
  await themeProvider.load();

  runApp(
    MultiProvider(
      providers: buildAppProviders(
        apiClient: apiClient,
        repositories: repositories,
        tokenStorage: SecureTokenStorage(),
        googleSignIn: createGoogleSignInService(),
        push: push,
        themeProvider: themeProvider,
      ),
      child: CoffeePasteApp(push: push),
    ),
  );
}

class CoffeePasteApp extends StatefulWidget {
  /// Opsional: router buatan sendiri (untuk test).
  final GoRouter? router;

  /// Opsional: null di test (push nonaktif).
  final PushService? push;

  const CoffeePasteApp({super.key, this.router, this.push});

  @override
  State<CoffeePasteApp> createState() => _CoffeePasteAppState();
}

class _CoffeePasteAppState extends State<CoffeePasteApp> {
  late final AuthProvider _auth;
  late final ThemeProvider _theme;
  late final GoRouter _router;
  PushService? get _push => widget.push;

  /// Buka tab Pesanan setelah login (notifikasi diketuk saat belum login).
  bool _openOrdersAfterLogin = false;

  /// Penanda sesi yang sedang aktif (null = belum login).
  String? _sessionKey;

  @override
  void initState() {
    super.initState();
    _auth = context.read<AuthProvider>();
    _router = widget.router ?? AppRouter.create(_auth);
    _auth.addListener(_syncSession);
    _theme = context.read<ThemeProvider>();
    _theme.addListener(_onThemeChanged);
    _theme.startObserving();

    final push = _push;
    if (push != null) {
      push.onOpenOrders = _openOrders;
      // Init berjalan di latar belakang; setelah selesai baru diketahui apakah
      // app dibuka dari notifikasi.
      push.init().then((_) {
        if (mounted && push.launchedFromPush) _openOrders();
      });
    }
  }

  /// Warna aplikasi dibaca dari AppColors, bukan dari Theme, jadi widget yang
  /// tidak ikut dibangun ulang (misalnya yang const) harus ditandai manual
  /// agar langsung berganti terang/gelap. State dan posisi halaman tetap.
  void _onThemeChanged() {
    if (!mounted) return;
    void mark(Element element) {
      element.markNeedsBuild();
      element.visitChildren(mark);
    }

    WidgetsBinding.instance.rootElement?.visitChildren(mark);
  }

  void _openOrders() {
    if (!mounted) return;
    if (_auth.isAuthenticated) {
      context
          .read<AppNavigationProvider>()
          .setTab(AppNavigationProvider.ordersTab);
    } else {
      _openOrdersAfterLogin = true;
    }
  }

  /// Menyelaraskan provider lain dengan status login:
  /// login/pulih sesi -> isi profil, kosongkan data akun sebelumnya;
  /// logout/token kedaluwarsa -> kosongkan keranjang dan pesanan.
  /// Keduanya mengembalikan tab ke Home.
  void _syncSession() {
    if (!mounted) return;

    final user = _auth.isAuthenticated ? _auth.user : null;
    final key = user == null ? null : '${user.id}|${user.email}';
    if (key == _sessionKey) return;
    _sessionKey = key;

    context.read<OrderProvider>().clear();
    context.read<CartProvider>().clear();
    context.read<AppNavigationProvider>()
      ..setTab(0)
      ..setMenuCategory('all');
    final profile = context.read<UserProvider>();
    if (user == null) {
      profile.clear();
    } else {
      profile.applyUser(user);
      profile.loadProfile(); // telepon, jenis kelamin, tanggal lahir dari server
      _push?.register();
      if (_openOrdersAfterLogin) {
        _openOrdersAfterLogin = false;
        context
            .read<AppNavigationProvider>()
            .setTab(AppNavigationProvider.ordersTab);
      }
    }
  }

  @override
  void dispose() {
    _auth.removeListener(_syncSession);
    _theme.removeListener(_onThemeChanged);
    if (_push?.onOpenOrders == _openOrders) _push?.onOpenOrders = null;
    if (widget.router == null) _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();

    return MaterialApp.router(
      title: 'Coffee Paste',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: theme.mode,
      // Gulir memantul ala iOS di semua platform.
      scrollBehavior: const CupertinoScrollBehavior(),
      routerConfig: _router,
      builder: (context, child) => AnnotatedRegion<SystemUiOverlayStyle>(
        value: theme.isDark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
        child: child ?? const SizedBox.shrink(),
      ),
    );
  }
}
