import 'package:nested/nested.dart';
import 'package:provider/provider.dart';

import 'core/config/app_repositories.dart';
import 'core/network/api_client.dart';
import 'core/notifications/push_service.dart';
import 'core/storage/token_storage.dart';
import 'features/auth/data/google_sign_in_service.dart';
import 'providers/app_navigation_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/menu_provider.dart';
import 'providers/order_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/user_provider.dart';

/// Daftar provider aplikasi. Dipisah dari main() supaya bisa dipakai test
/// dengan repository palsu dan storage di memori.
List<SingleChildWidget> buildAppProviders({
  required ApiClient apiClient,
  required AppRepositories repositories,
  required TokenStorage tokenStorage,
  GoogleSignInService? googleSignIn,
  PushService? push,
  ThemeProvider? themeProvider,
}) {
  return [
    Provider<ApiClient>.value(value: apiClient),
    ChangeNotifierProvider<AuthProvider>(
      create: (_) => AuthProvider(
        repositories.auth,
        apiClient,
        tokenStorage,
        googleSignIn: googleSignIn,
        push: push,
      ),
    ),
    ChangeNotifierProvider<MenuProvider>(
      create: (_) => MenuProvider(repositories.menu),
    ),
    ChangeNotifierProvider<OrderProvider>(
      create: (_) => OrderProvider(repositories.order),
    ),
    ChangeNotifierProvider<CartProvider>(create: (_) => CartProvider()),
    ChangeNotifierProvider<UserProvider>(create: (_) => UserProvider(repositories.profile)),
    ChangeNotifierProvider<AppNavigationProvider>(
      create: (_) => AppNavigationProvider(),
    ),
    if (themeProvider != null)
      ChangeNotifierProvider<ThemeProvider>.value(value: themeProvider)
    else
      ChangeNotifierProvider<ThemeProvider>(create: (_) => ThemeProvider()),
  ];
}
