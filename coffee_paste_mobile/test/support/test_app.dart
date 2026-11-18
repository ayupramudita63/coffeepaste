import 'package:coffee_paste/app_providers.dart';
import 'package:coffee_paste/core/config/app_repositories.dart';
import 'package:coffee_paste/core/network/api_client.dart';
import 'package:coffee_paste/core/storage/token_storage.dart';
import 'package:coffee_paste/features/account/data/profile_mock_repository.dart';
import 'package:coffee_paste/features/auth/data/auth_mock_repository.dart';
import 'package:coffee_paste/features/menu/data/menu_mock_repository.dart';
import 'package:coffee_paste/features/order/data/order_mock_repository.dart';
import 'package:coffee_paste/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

/// Menjalankan aplikasi penuh dengan repository palsu tanpa jeda
/// dan storage di memori.
Future<void> pumpCoffeePaste(
  WidgetTester tester, {
  required TokenStorage storage,
}) async {
  // Hindari unduhan font dari internet saat test.
  GoogleFonts.config.allowRuntimeFetching = false;

  // Ukuran layar ponsel (360 x 800 dp).
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final apiClient = ApiClient();
  final repositories = AppRepositories(
    auth: MockAuthRepository(latency: Duration.zero),
    menu: MockMenuRepository(latency: Duration.zero),
    order: MockOrderRepository(latency: Duration.zero),
    profile: MockProfileRepository(latency: Duration.zero),
  );

  await tester.pumpWidget(
    MultiProvider(
      providers: buildAppProviders(
        apiClient: apiClient,
        repositories: repositories,
        tokenStorage: storage,
      ),
      child: const CoffeePasteApp(),
    ),
  );
}

/// Melewati splash (animasi + jeda 2,4 detik) sampai halaman tujuan tampil.
Future<void> passSplash(WidgetTester tester) async {
  await tester.pump(const Duration(seconds: 3));
  await tester.pumpAndSettle();
}
