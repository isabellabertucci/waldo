import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:waldo/features/dashboard/ui/dashboard_screen.dart';
import 'package:waldo/features/transactions/views/transactions_screen.dart';
import 'package:waldo/features/wallets/views/wallets_screen.dart';
import 'package:waldo/features/wallets/models/wallet.dart';
import 'package:waldo/features/wallets/repositories/wallet_repository.dart';
import 'package:waldo/features/settings/ui/settings_screen.dart';
import '../../helpers/test_app.dart';

void main() {
  late GoRouter router;
  Database? currentDb;

  setUp(() {
    router = createTestRouter();
  });

  tearDown(() async {
    await currentDb?.close();
    currentDb = null;
  });

  Finder findNavigationBar() => find.byType(NavigationBar);
  Finder findNavDestination(int index) =>
      find.byType(NavigationDestination).at(index);

  group('AppShell', () {
    testWidgets('Renders with the initial branch selected', (
      WidgetTester tester,
    ) async {
      currentDb = await pumpTestApp(tester, router: router);
      final navBar = tester.widget<NavigationBar>(findNavigationBar());
      expect(navBar.selectedIndex, 0);
      expect(find.byType(DashboardScreen), findsOneWidget);
      expect(find.byType(WalletsScreen), findsNothing);
      expect(find.byType(SettingsScreen), findsNothing);
    });

    testWidgets(
      'Tapping each bottom nav item navigates to the correct branch',
      (WidgetTester tester) async {
        currentDb = await pumpTestApp(tester, router: router);
        // Start at Dashboard (index 0)
        expect(
          tester.widget<NavigationBar>(findNavigationBar()).selectedIndex,
          0,
        );
        expect(find.byType(DashboardScreen), findsOneWidget);
        // Act & Assert: Wallets (index 1)
        await tester.tap(findNavDestination(1));
        await tester.pumpAndSettle();
        expect(
          tester.widget<NavigationBar>(findNavigationBar()).selectedIndex,
          1,
        );
        expect(find.byType(WalletsScreen), findsOneWidget);
        expect(find.byType(DashboardScreen), findsNothing);
        // Act & Assert: Settings (index 2)
        await tester.tap(findNavDestination(2));
        await tester.pumpAndSettle();
        expect(
          tester.widget<NavigationBar>(findNavigationBar()).selectedIndex,
          2,
        );
        expect(find.byType(SettingsScreen), findsOneWidget);
        expect(find.byType(WalletsScreen), findsNothing);
        // Act & Assert: Dashboard again (index 0)
        await tester.tap(findNavDestination(0));
        await tester.pumpAndSettle();
        expect(
          tester.widget<NavigationBar>(findNavigationBar()).selectedIndex,
          0,
        );
        expect(find.byType(DashboardScreen), findsOneWidget);
        expect(find.byType(SettingsScreen), findsNothing);
      },
    );

    testWidgets(
      'Navigating into a wallet transactions preserves tab state on return',
      (WidgetTester tester) async {
        currentDb = await pumpTestApp(tester, router: router);
        final walletRepo = WalletRepositoryImpl(currentDb!);
        final walletId = await walletRepo.insert(
          const Wallet(
            name: 'Test Wallet',
            createdAt: '2026-08-10T12:00:00.000',
          ),
        );
        expect(find.byType(DashboardScreen), findsOneWidget);
        // Navigate to Wallets branch (index 1)
        await tester.tap(findNavDestination(1));
        await tester.pumpAndSettle();
        expect(find.byType(WalletsScreen), findsOneWidget);
        // Navigate into nested transactions route for the wallet
        router.go('/wallets/$walletId/transactions');
        await tester.pumpAndSettle();
        expect(find.byType(TransactionsScreen), findsOneWidget);

        // Switch to Settings branch (index 2)
        await tester.tap(findNavDestination(2));
        await tester.pumpAndSettle();
        expect(find.byType(SettingsScreen), findsOneWidget);
        expect(find.byType(TransactionsScreen), findsNothing);

        // Switch back to Wallets branch (index 1) — nested state preserved
        await tester.tap(findNavDestination(1));
        await tester.pumpAndSettle();
        expect(find.byType(TransactionsScreen), findsOneWidget);
        expect(
          tester.widget<NavigationBar>(findNavigationBar()).selectedIndex,
          1,
        );
      },
    );
  });
}
