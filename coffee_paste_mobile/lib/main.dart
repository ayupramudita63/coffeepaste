import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'app_providers.dart';
import 'core/config/app_repositories.dart';
import 'core/network/api_client.dart';
import 'core/notifications/push_notification_service.dart';
import 'core/router/app_router.dart';
import 'core/storage/token_storage.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/data/google_sign_in_service.dart';
import 'providers/app_navigation_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/notification_provider.dart';
import 'providers/order_provider.dart';
import 'providers/user_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Penangan pesan FCM saat aplikasi di latar belakang harus didaftarkan
  // sebelum runApp. Tanpa Firebase (mis. di test) pendaftaran ini dilewatkan.
  PushNotificationService.registerBackgroundHandler();

  final apiClient = ApiClient();
  final repositories = AppRepositories.create(apiClient);

  runApp(
    MultiProvider(
      providers: buildAppProviders(
        apiClient: apiClient,
        repositories: repositories,
        tokenStorage: SecureTokenStorage(),
        googleSignIn: createGoogleSignInService(),
      ),
      child: const CoffeePasteApp(),
    ),
  );
}

class CoffeePasteApp extends StatefulWidget {
  /// Opsional: router buatan sendiri (untuk test).
  final GoRouter? router;

  const CoffeePasteApp({super.key, this.router});

  @override
  State<CoffeePasteApp> createState() => _CoffeePasteAppState();
}

class _CoffeePasteAppState extends State<CoffeePasteApp> {
  late final AuthProvider _auth;
  late final GoRouter _router;
  late final PushNotificationService _push;

  /// Penanda sesi yang sedang aktif (null = belum login).
  String? _sessionKey;

  @override
  void initState() {
    super.initState();
    _auth = context.read<AuthProvider>();
    _router = widget.router ?? AppRouter.create(_auth);
    _auth.addListener(_syncSession);

    // Siapkan notifikasi lokal: baca pilihan yang tersimpan + izin sistem.
    unawaited(context.read<NotificationProvider>().ensureStarted());
    // Notifikasi yang disentuh pengguna membuka tab Pesanan.
    context.read<NotificationProvider>().setOnOpened(_openOrderFromNotification);

    // Notifikasi push (FCM): pesan saat aplikasi aktif ditampilkan sebagai
    // notifikasi lokal, pesan latar belakang ditampilkan sistem, dan ketukan
    // pengguna membuka tab Pesanan. Gagal pun aplikasi tetap berjalan.
    _push = PushNotificationService(apiClient: context.read<ApiClient>());
    _push.onForegroundMessage = _showPushMessage;
    _push.onOpened = _openOrderFromNotification;
    _push.onRegistration = (enabled) {
      if (mounted) {
        context.read<NotificationProvider>().setPushEnabled(enabled);
      }
    };
    unawaited(_push.init());
  }

  /// Menampilkan pesan push yang datang selama aplikasi terlihat.
  void _showPushMessage(String? title, String? body, String? payload) {
    if (!mounted) return;
    unawaited(
      context.read<NotificationProvider>().showPushMessage(
            title: title,
            body: body,
            payload: payload,
          ),
    );
  }

  /// Membuka tab Pesanan setelah pengguna menyentuh notifikasi status pesanan
  /// atau pembayaran (payload berbentuk `order:<id>` / `payment:<id>`).
  void _openOrderFromNotification(String? payload) {
    if (!mounted || payload == null) return;
    if (!payload.startsWith('order:') && !payload.startsWith('payment:')) {
      return;
    }

    context
        .read<AppNavigationProvider>()
        .setTab(AppNavigationProvider.ordersTab);
    _router.go(AppRoutes.home);
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
      context.read<NotificationProvider>().setPushEnabled(false);
    } else {
      profile.applyUser(user);
      profile.loadProfile(); // telepon, jenis kelamin, tanggal lahir dari server
      // Token JWT sudah terpasang: daftarkan token FCM perangkat ini supaya
      // server bisa mengirim notifikasi push ke pengguna yang baru login.
      unawaited(_push.registerDevice());
    }
  }

  @override
  void dispose() {
    _auth.removeListener(_syncSession);
    _push.dispose();
    if (widget.router == null) _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Coffee Paste',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: _router,
    );
  }
}
