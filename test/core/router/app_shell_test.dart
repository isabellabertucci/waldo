import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:waldo/features/dashboard/ui/dashboard_screen.dart';
import 'package:waldo/features/transactions/ui/transactions_screen.dart';
import 'package:waldo/features/transactions/ui/transaction_new_screen.dart';
import 'package:waldo/features/wallets/views/wallets_screen.dart';
import 'package:waldo/features/settings/ui/settings_screen.dart';

import '../../helpers/test_app.dart';

void main() {
  late GoRouter router;

  setUp(() {
    router = createTestRouter();
  });

  Finder findNavigationBar() => find.byType(NavigationBar);
  Finder findNavDestination(int index) =>
      find.byType(NavigationDestination).at(index);

  group('AppShell', () {
    testWidgets('Renders with the initial branch selected', (
      WidgetTester tester,
    ) async {
      await pumpTestApp(tester, router: router);

      final navBar = tester.widget<NavigationBar>(findNavigationBar());
      expect(navBar.selectedIndex, 0);

      expect(find.byType(DashboardScreen), findsOneWidget);
      expect(find.byType(TransactionsScreen), findsNothing);
      expect(find.byType(WalletsScreen), findsNothing);
      expect(find.byType(SettingsScreen), findsNothing);
    });

    testWidgets(
      'Tapping each bottom nav item navigates to the correct branch',
      (WidgetTester tester) async {
        await pumpTestApp(tester, router: router);

        // Start at Dashboard (index 0)
        expect(
          tester.widget<NavigationBar>(findNavigationBar()).selectedIndex,
          0,
        );
        expect(find.byType(DashboardScreen), findsOneWidget);

        // Act & Assert: Transactions (index 1)
        await tester.tap(findNavDestination(1));
        await tester.pumpAndSettle();
        expect(
          tester.widget<NavigationBar>(findNavigationBar()).selectedIndex,
          1,
        );
        expect(find.byType(TransactionsScreen), findsOneWidget);
        expect(find.byType(DashboardScreen), findsNothing);

        // Act & Assert: Wallets (index 2)
        await tester.tap(findNavDestination(2));
        await tester.pumpAndSettle();
        expect(
          tester.widget<NavigationBar>(findNavigationBar()).selectedIndex,
          2,
        );
        expect(find.byType(WalletsScreen), findsOneWidget);
        expect(find.byType(TransactionsScreen), findsNothing);

        // Act & Assert: Settings (index 3)
        await tester.tap(findNavDestination(3));
        await tester.pumpAndSettle();
        expect(
          tester.widget<NavigationBar>(findNavigationBar()).selectedIndex,
          3,
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

    testWidgets('Tab state is preserved when switching away and back', (
      WidgetTester tester,
    ) async {
      await pumpTestApp(tester, router: router);

      expect(find.byType(DashboardScreen), findsOneWidget);

      // Navigate to Transactions branch (index 1)
      await tester.tap(findNavDestination(1));
      await tester.pumpAndSettle();
      expect(find.byType(TransactionsScreen), findsOneWidget);

      // Navigate into nested route
      router.go('/transactions/new');
      await tester.pumpAndSettle();
      expect(find.byType(TransactionNewScreen), findsOneWidget);

      // Switch to Wallets branch (index 2)
      await tester.tap(findNavDestination(2));
      await tester.pumpAndSettle();
      expect(find.byType(WalletsScreen), findsOneWidget);
      expect(find.byType(TransactionNewScreen), findsNothing);

      // Switch back to Transactions branch (index 1)
      await tester.tap(findNavDestination(1));
      await tester.pumpAndSettle();

      expect(find.byType(TransactionNewScreen), findsOneWidget);
      expect(find.byType(TransactionsScreen), findsNothing);

      expect(
        tester.widget<NavigationBar>(findNavigationBar()).selectedIndex,
        1,
      );
    });
  });
}
