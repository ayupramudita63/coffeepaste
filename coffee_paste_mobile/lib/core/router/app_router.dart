import 'package:go_router/go_router.dart';

import '../../features/account/about_screen.dart';
import '../../features/account/account_info_screen.dart';
import '../../features/account/change_password_screen.dart';
import '../../features/account/language_screen.dart';
import '../../features/account/notification_settings_screen.dart';
import '../../features/auth/forgot_password_screen.dart';
import '../../features/auth/login_screen.dart';
import '../../features/auth/register_screen.dart';
import '../../features/cart/cart_screen.dart';
import '../../features/account/change_email_screen.dart';
import '../../features/home/screens/product_list_screen.dart';
import '../../features/main_navigation/main_navigation_screen.dart';
import '../../features/order/order_payment_screen.dart';
import '../../features/order/receipt_screen.dart';
import '../../features/product_detail/product_detail_screen.dart';
import '../../features/splash/splash_screen.dart';
import '../../providers/auth_provider.dart';
import '../../shared/models/product_model.dart';

/// Semua path halaman ada di sini.
class AppRoutes {
  AppRoutes._();

  static const String splash = '/splash';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';

  static const String home = '/home';
  static const String cart = '/cart';
  static const String productDetail = '/product';
  static const String productList = '/products';

  /// Pembayaran pesanan (extra: ID pesanan String) dan struknya.
  static const String orderPayment = '/order/payment';
  static const String orderReceipt = '/order/receipt';

  static const String accountInfo = '/account/info';
  static const String language = '/account/language';
  static const String notifications = '/account/notifications';
  static const String changePassword = '/account/change-password';
  static const String changeEmail = '/account/change-email';
  static const String about = '/account/about';

  /// Halaman yang boleh dibuka tanpa login.
  static const Set<String> publicRoutes = {
    splash,
    login,
    register,
    forgotPassword,
  };
}

/// Argumen untuk [AppRoutes.productList] (dikirim lewat `extra`).
class ProductListArgs {
  final String title;
  final List<ProductModel> products;

  const ProductListArgs({required this.title, required this.products});
}

class AppRouter {
  AppRouter._();

  static GoRouter create(
    AuthProvider auth, {
    String initialLocation = AppRoutes.splash,
  }) {
    return GoRouter(
      initialLocation: initialLocation,
      refreshListenable: auth,
      redirect: (context, state) => guard(
        initialized: auth.isInitialized,
        authenticated: auth.isAuthenticated,
        location: state.uri.path,
      ),
      routes: [
        GoRoute(
          path: AppRoutes.splash,
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: AppRoutes.login,
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: AppRoutes.register,
          builder: (context, state) => const RegisterScreen(),
        ),
        GoRoute(
          path: AppRoutes.forgotPassword,
          builder: (context, state) => const ForgotPasswordScreen(),
        ),
        GoRoute(
          path: AppRoutes.home,
          builder: (context, state) => const MainNavigationScreen(),
        ),
        GoRoute(
          path: AppRoutes.cart,
          builder: (context, state) => const CartScreen(),
        ),
        GoRoute(
          path: AppRoutes.productDetail,
          redirect: (context, state) =>
              state.extra is ProductModel ? null : AppRoutes.home,
          builder: (context, state) =>
              ProductDetailScreen(product: state.extra! as ProductModel),
        ),
        GoRoute(
          path: AppRoutes.orderPayment,
          redirect: (context, state) =>
              state.extra is String ? null : AppRoutes.home,
          builder: (context, state) =>
              OrderPaymentScreen(orderId: state.extra! as String),
        ),
        GoRoute(
          path: AppRoutes.orderReceipt,
          redirect: (context, state) =>
              state.extra is String ? null : AppRoutes.home,
          builder: (context, state) =>
              ReceiptScreen(orderId: state.extra! as String),
        ),
        GoRoute(
          path: AppRoutes.changeEmail,
          builder: (context, state) => const ChangeEmailScreen(),
        ),
        GoRoute(
          path: AppRoutes.productList,
          redirect: (context, state) =>
              state.extra is ProductListArgs ? null : AppRoutes.home,
          builder: (context, state) {
            final args = state.extra! as ProductListArgs;
            return ProductListScreen(
              title: args.title,
              products: args.products,
            );
          },
        ),
        GoRoute(
          path: AppRoutes.accountInfo,
          builder: (context, state) => const AccountInfoScreen(),
        ),
        GoRoute(
          path: AppRoutes.language,
          builder: (context, state) => const LanguageScreen(),
        ),
        GoRoute(
          path: AppRoutes.notifications,
          builder: (context, state) => const NotificationSettingsScreen(),
        ),
        GoRoute(
          path: AppRoutes.changePassword,
          builder: (context, state) => const ChangePasswordScreen(),
        ),
        GoRoute(
          path: AppRoutes.about,
          builder: (context, state) => const AboutScreen(),
        ),
      ],
    );
  }

  /// Aturan guard login. Mengembalikan path tujuan, atau null jika boleh lanjut.
  ///
  /// - Sesi belum selesai dipulihkan -> tahan di splash.
  /// - Belum login -> halaman selain [AppRoutes.publicRoutes] dialihkan ke login.
  /// - Sudah login -> halaman login/daftar/lupa password dialihkan ke home.
  static String? guard({
    required bool initialized,
    required bool authenticated,
    required String location,
  }) {
    if (!initialized) {
      return location == AppRoutes.splash ? null : AppRoutes.splash;
    }

    // Splash memutuskan sendiri tujuan berikutnya setelah animasinya selesai.
    if (location == AppRoutes.splash) return null;

    final isPublic = AppRoutes.publicRoutes.contains(location);

    if (!authenticated) return isPublic ? null : AppRoutes.login;
    if (isPublic) return AppRoutes.home;
    return null;
  }
}
