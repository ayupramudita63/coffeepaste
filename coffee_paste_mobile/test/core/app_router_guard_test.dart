import 'package:coffee_paste/core/router/app_router.dart';
import 'package:flutter_test/flutter_test.dart';

String? guard(
  String location, {
  required bool initialized,
  required bool authenticated,
}) {
  return AppRouter.guard(
    initialized: initialized,
    authenticated: authenticated,
    location: location,
  );
}

void main() {
  group('sesi belum dipulihkan', () {
    test('semua halaman ditahan di splash', () {
      for (final path in [
        AppRoutes.login,
        AppRoutes.home,
        AppRoutes.cart,
        AppRoutes.accountInfo,
      ]) {
        expect(
          guard(path, initialized: false, authenticated: false),
          AppRoutes.splash,
          reason: path,
        );
      }
    });

    test('splash sendiri tidak dialihkan', () {
      expect(
        guard(AppRoutes.splash, initialized: false, authenticated: false),
        isNull,
      );
    });
  });

  group('belum login', () {
    test('halaman publik boleh dibuka', () {
      for (final path in [
        AppRoutes.splash,
        AppRoutes.login,
        AppRoutes.register,
        AppRoutes.forgotPassword,
      ]) {
        expect(
          guard(path, initialized: true, authenticated: false),
          isNull,
          reason: path,
        );
      }
    });

    test('halaman terlindungi dialihkan ke login', () {
      for (final path in [
        AppRoutes.home,
        AppRoutes.cart,
        AppRoutes.productDetail,
        AppRoutes.productList,
        AppRoutes.accountInfo,
        AppRoutes.language,
        AppRoutes.notifications,
        AppRoutes.changePassword,
        AppRoutes.about,
      ]) {
        expect(
          guard(path, initialized: true, authenticated: false),
          AppRoutes.login,
          reason: path,
        );
      }
    });
  });

  group('sudah login', () {
    test('halaman login/daftar/lupa password dialihkan ke home', () {
      for (final path in [
        AppRoutes.login,
        AppRoutes.register,
        AppRoutes.forgotPassword,
      ]) {
        expect(
          guard(path, initialized: true, authenticated: true),
          AppRoutes.home,
          reason: path,
        );
      }
    });

    test('halaman terlindungi boleh dibuka', () {
      for (final path in [
        AppRoutes.home,
        AppRoutes.cart,
        AppRoutes.productDetail,
        AppRoutes.accountInfo,
        AppRoutes.about,
      ]) {
        expect(
          guard(path, initialized: true, authenticated: true),
          isNull,
          reason: path,
        );
      }
    });

    test('splash tidak dialihkan (splash memilih tujuan sendiri)', () {
      expect(
        guard(AppRoutes.splash, initialized: true, authenticated: true),
        isNull,
      );
    });
  });
}
