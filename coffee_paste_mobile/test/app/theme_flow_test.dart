import 'package:coffee_paste/core/theme/app_colors.dart';
import 'package:coffee_paste/features/account/account_screen.dart';
import 'package:coffee_paste/features/account/appearance_screen.dart';
import 'package:coffee_paste/features/main_navigation/main_navigation_screen.dart';
import 'package:coffee_paste/providers/app_navigation_provider.dart';
import 'package:coffee_paste/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import '../support/fakes.dart';
import '../support/test_app.dart';

void main() {
  tearDown(() => AppColors.useDark(false));

  testWidgets('menu Profil -> Tampilan -> pilih Gelap lalu Terang',
      (tester) async {
    final storage = InMemoryTokenStorage(token: 'mock-token-1', user: testUser);
    await pumpCoffeePaste(tester, storage: storage);
    await passSplash(tester);

    // Buka tab Akun (index 3).
    tester
        .element(find.byType(MainNavigationScreen))
        .read<AppNavigationProvider>()
        .setTab(3);
    await tester.pumpAndSettle();
    expect(find.byType(AccountScreen), findsOneWidget);

    await tester.tap(find.text('Tampilan'));
    await tester.pumpAndSettle();
    expect(find.byType(AppearanceScreen), findsOneWidget);

    MaterialApp app() => tester.widget<MaterialApp>(find.byType(MaterialApp));
    ThemeProvider theme() =>
        tester.element(find.byType(AppearanceScreen)).read<ThemeProvider>();

    expect(theme().mode, ThemeMode.system);

    await tester.tap(find.byKey(const Key('theme-dark')));
    await tester.pumpAndSettle();

    expect(theme().mode, ThemeMode.dark);
    expect(app().themeMode, ThemeMode.dark);
    expect(AppColors.isDark, isTrue);

    await tester.tap(find.byKey(const Key('theme-light')));
    await tester.pumpAndSettle();

    expect(theme().mode, ThemeMode.light);
    expect(AppColors.isDark, isFalse);
  });
}
