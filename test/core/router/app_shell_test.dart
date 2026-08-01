import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:waldo/features/accounts/ui/accounts_screen.dart';

import 'package:waldo/features/dashboard/ui/dashboard_screen.dart';
import 'package:waldo/features/transactions/ui/transactions_screen.dart';
import 'package:waldo/features/transactions/ui/transaction_new_screen.dart';
import 'package:waldo/features/reports/ui/reports_screen.dart';
import 'package:waldo/features/settings/ui/settings_screen.dart';

import '../../helpers/test_app.dart';

void main() {
  late GoRouter router;

  setUp(() {
    router = createTestRouter();
  });

  Finder findNavigationBar() => find.byType(NavigationBar);
  // Helper to find specific tabs
  Finder findNavDestination(int index) =>
      find.byType(NavigationDestination).at(index);

  group('AppShell', () {
    testWidgets('Renders with the initial branch selected', (
      WidgetTester tester,
    ) async {
      // Arrange
      await pumpTestApp(tester, router: router);

      // Act: (none, just initial build)

      // Assert: Dashboard branch is selected (index 0)
      final navBar = tester.widget<NavigationBar>(findNavigationBar());
      expect(navBar.selectedIndex, 0);

      // Assert: DashboardScreen is visible, others are not
      expect(find.byType(DashboardScreen), findsOneWidget);
      expect(find.byType(TransactionsScreen), findsNothing);
      expect(find.byType(ReportsScreen), findsNothing);
      expect(find.byType(SettingsScreen), findsNothing);
    });

    testWidgets(
      'Tapping each bottom nav item navigates to the correct branch',
      (WidgetTester tester) async {
        // Arrange
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

        // Act & Assert: Reports (index 2)
        await tester.tap(findNavDestination(2));
        await tester.pumpAndSettle();
        expect(
          tester.widget<NavigationBar>(findNavigationBar()).selectedIndex,
          2,
        );
        expect(find.byType(ReportsScreen), findsOneWidget);
        expect(find.byType(TransactionsScreen), findsNothing);

        // Act & Assert: Settings (index 3)
        await tester.tap(findNavDestination(3));
        await tester.pumpAndSettle();
        expect(
          tester.widget<NavigationBar>(findNavigationBar()).selectedIndex,
          3,
        );
        expect(find.byType(SettingsScreen), findsOneWidget);
        expect(find.byType(ReportsScreen), findsNothing);

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
      // Arrange
      await pumpTestApp(tester, router: router);

      // Start at Dashboard
      expect(find.byType(DashboardScreen), findsOneWidget);

      // Act: Navigate to Transactions branch
      await tester.tap(findNavDestination(1)); // index 1
      await tester.pumpAndSettle();
      expect(find.byType(TransactionsScreen), findsOneWidget);

      // Act: Navigate into nested route (TransactionNewRoute)
      router.go('/transactions/new');
      await tester.pumpAndSettle();
      expect(find.byType(TransactionNewScreen), findsOneWidget);

      // Act: Switch to Reports branch
      await tester.tap(findNavDestination(2)); // index 2
      await tester.pumpAndSettle();
      expect(find.byType(ReportsScreen), findsOneWidget);
      expect(find.byType(TransactionNewScreen), findsNothing);

      // Act: Switch back to Transactions branch
      await tester.tap(findNavDestination(1)); // index 1
      await tester.pumpAndSettle();

      // Assert: Still on nested route, not reset to Transactions root
      expect(find.byType(TransactionNewScreen), findsOneWidget);
      expect(find.byType(TransactionsScreen), findsNothing);

      // assert bottom nav still highlights Transactions
      expect(
        tester.widget<NavigationBar>(findNavigationBar()).selectedIndex,
        1,
      );
    });

    testWidgets(
      'Navigating to a standalone route hides the AppShell (bottom nav)',
      (WidgetTester tester) async {
        // Arrange
        await pumpTestApp(tester, router: router);

        // Assert: We start inside the shell, so the NavigationBar is visible
        expect(find.byType(NavigationBar), findsOneWidget);

        // Act: Navigate to the standalone Accounts route
        router.go('/accounts');
        await tester.pumpAndSettle();

        // Assert: AccountsScreen is visible
        expect(find.byType(AccountsScreen), findsOneWidget);

        // Assert: The NavigationBar is no longer on the screen
        expect(find.byType(NavigationBar), findsNothing);
      },
    );
  });
}
