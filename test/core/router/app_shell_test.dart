import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:waldo/core/router/app_nav_bar.dart';
import 'package:waldo/features/dashboard/ui/dashboard_screen.dart';
import 'package:waldo/features/transactions/ui/transactions_screen.dart';
import 'package:waldo/features/wallets/ui/wallets_screen.dart';
import 'package:waldo/features/wallets/models/wallet.dart';
import 'package:waldo/features/wallets/repositories/wallet_repository.dart';
import 'package:waldo/features/wallets/viewmodels/wallet_list_view_model.dart';
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

  Finder findNavButton(int index) => find.byKey(ValueKey('nav-$index'));
  bool isSelected(WidgetTester tester, int index) =>
      tester.widget<AppNavButton>(findNavButton(index)).selected;

  group('AppShell', () {
    testWidgets('Renders with the initial branch selected', (
      WidgetTester tester,
    ) async {
      currentDb = await pumpTestApp(tester, router: router);
      expect(isSelected(tester, 0), isTrue);
      expect(isSelected(tester, 1), isFalse);
      expect(isSelected(tester, 2), isFalse);
      expect(find.byType(DashboardScreen), findsOneWidget);
      expect(find.byType(WalletsScreen), findsNothing);
      expect(find.byType(SettingsScreen), findsNothing);
    });

    testWidgets(
      'Tapping each bottom nav item navigates to the correct branch',
      (WidgetTester tester) async {
        currentDb = await pumpTestApp(tester, router: router);
        expect(isSelected(tester, 0), isTrue);
        expect(find.byType(DashboardScreen), findsOneWidget);

        await tester.tap(findNavButton(1));
        await tester.pumpAndSettle();
        expect(isSelected(tester, 1), isTrue);
        expect(find.byType(WalletsScreen), findsOneWidget);
        expect(find.byType(DashboardScreen), findsNothing);

        await tester.tap(findNavButton(2));
        await tester.pumpAndSettle();
        expect(isSelected(tester, 2), isTrue);
        expect(find.byType(SettingsScreen), findsOneWidget);
        expect(find.byType(WalletsScreen), findsNothing);

        await tester.tap(findNavButton(0));
        await tester.pumpAndSettle();
        expect(isSelected(tester, 0), isTrue);
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
        await tester.tap(findNavButton(1));
        await tester.pumpAndSettle();
        expect(find.byType(WalletsScreen), findsOneWidget);
        router.go('/wallets/$walletId/transactions');
        await tester.pumpAndSettle();
        expect(find.byType(TransactionsScreen), findsOneWidget);

        await tester.tap(findNavButton(2));
        await tester.pumpAndSettle();
        expect(find.byType(SettingsScreen), findsOneWidget);
        expect(find.byType(TransactionsScreen), findsNothing);

        // Nested route state must survive a branch switch.
        await tester.tap(findNavButton(1));
        await tester.pumpAndSettle();
        expect(find.byType(TransactionsScreen), findsOneWidget);
        expect(isSelected(tester, 1), isTrue);
      },
    );

    testWidgets("Deleting a wallet from its own screen goes back to the list", (
      WidgetTester tester,
    ) async {
      currentDb = await pumpTestApp(tester, router: router);
      final walletId = await WalletRepositoryImpl(currentDb!).insert(
        const Wallet(name: 'Test Wallet', createdAt: '2026-08-10T12:00:00.000'),
      );
      // Home loaded the wallets before this one was added.
      ProviderScope.containerOf(
        tester.element(find.byType(DashboardScreen)),
      ).invalidate(walletListViewModelProvider);
      await tester.tap(findNavButton(1));
      await tester.pumpAndSettle();
      router.go('/wallets/$walletId/transactions');
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Test Wallet options'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();
      // The confirmation dialog's button.
      await tester.tap(find.text('Delete'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(TransactionsScreen), findsNothing);
      expect(find.byType(WalletsScreen), findsOneWidget);
      expect(find.text('Wallet deleted'), findsOneWidget);
      // Above the floating navbar, not behind it.
      expect(
        tester.getRect(find.byType(SnackBar)).bottom,
        lessThanOrEqualTo(tester.getRect(find.byType(AppNavBar)).top),
      );

      // Let the Undo window close.
      await tester.pump(const Duration(seconds: 11));
      await tester.pumpAndSettle();
    });
  });
}
