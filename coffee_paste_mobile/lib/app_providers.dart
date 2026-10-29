import 'package:nested/nested.dart';
import 'package:provider/provider.dart';

import 'core/config/app_repositories.dart';
import 'core/network/api_client.dart';
import 'core/notifications/notification_service.dart';
import 'core/storage/token_storage.dart';
import 'features/auth/data/google_sign_in_service.dart';
import 'providers/app_navigation_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/language_provider.dart';
import 'providers/menu_provider.dart';
import 'providers/notification_provider.dart';
import 'providers/order_provider.dart';
import 'providers/user_provider.dart';

/// Daftar provider aplikasi. Dipisah dari main() supaya bisa dipakai test
/// dengan repository palsu dan storage di memori.
List<SingleChildWidget> buildAppProviders({
  required ApiClient apiClient,
  required AppRepositories repositories,
  required TokenStorage tokenStorage,
  GoogleSignInService? googleSignIn,
  NotificationService? notificationService,
  NotificationPreferenceStore? notificationStore,
}) {
  // Dibuat lebih dulu karena dipakai OrderProvider untuk memicu notifikasi
  // saat status pesanan berubah.
  final notifications = NotificationProvider(
    service: notificationService ?? LocalNotificationService(),
    store: notificationStore,
  );

  return [
    Provider<ApiClient>.value(value: apiClient),
    ChangeNotifierProvider<NotificationProvider>.value(value: notifications),
    ChangeNotifierProvider<AuthProvider>(
      create: (_) => AuthProvider(
        repositories.auth,
        apiClient,
        tokenStorage,
        googleSignIn: googleSignIn,
      ),
    ),
    ChangeNotifierProvider<MenuProvider>(
      create: (_) => MenuProvider(repositories.menu),
    ),
    ChangeNotifierProvider<OrderProvider>(
      create: (_) => OrderProvider(
        repositories.order,
        onOrdersChanged: notifications.onOrdersChanged,
      ),
    ),
    ChangeNotifierProvider<CartProvider>(create: (_) => CartProvider()),
    ChangeNotifierProvider<UserProvider>(create: (_) => UserProvider(repositories.profile)),
    ChangeNotifierProvider<LanguageProvider>(
      create: (_) => LanguageProvider(),
    ),
    ChangeNotifierProvider<AppNavigationProvider>(
      create: (_) => AppNavigationProvider(),
    ),
  ];
}
