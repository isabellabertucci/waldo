import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart' hide Transaction;

import 'package:waldo/core/constants/enums.dart';
import 'package:waldo/core/database/db_providers.dart';
import 'package:waldo/core/theme/app_theme.dart';
import 'package:waldo/core/utils/utils.dart';
import 'package:waldo/features/categories/repositories/category_repository.dart';
import 'package:waldo/features/dashboard/ui/dashboard_screen.dart';
import 'package:waldo/features/dashboard/viewmodels/dashboard_view_model.dart';
import 'package:waldo/features/preferences/viewmodels/balance_hidden_view_model.dart';
import 'package:waldo/features/transactions/models/transaction.dart';
import 'package:waldo/features/transactions/repositories/transaction_repository.dart';
import 'package:waldo/features/wallets/models/wallet.dart';
import 'package:waldo/features/wallets/repositories/wallet_repository.dart';
import 'package:waldo/l10n/app_localizations.dart';

import '../../../helpers/test_app.dart';

void main() {
  Database? currentDb;

  tearDown(() async {
    await currentDb?.close();
    currentDb = null;
  });

  Future<void> pumpDashboardScreen(WidgetTester tester, {Database? db}) async {
    // The dashboard's content is taller than the default 800x600 test
    // surface, so a ListView further down (e.g. RecentTransactionsList)
    // never gets built by the lazy sliver unless the viewport is tall
    // enough to fit everything without scrolling.
    tester.view.physicalSize = const Size(400, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    currentDb = await pumpWidgetWithProviders(
      tester,
      const DashboardScreen(),
      db: db,
    );
  }

  testWidgets(
    'Shows the empty-wallet state on the normal dashboard layout when there are no wallets',
    (tester) async {
      await pumpDashboardScreen(tester);

      // The normal dashboard shell (balance card, receipt) renders even
      // with zero wallets now - no separate first-run screen. The month
      // selector itself stays hidden, though: there's nothing to filter by
      // month yet with no wallets.
      final currentMonth = DateFormat.MMMM('en').format(DateTime.now());
      expect(find.text(currentMonth), findsNothing);
      expect(find.text('Slide in your first wallet'), findsOneWidget);
      expect(find.text('0 wallets'), findsOneWidget);
      expect(
        find.text(
          "Your month's receipt prints here after the first transaction.",
        ),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'Shows per-section empty states when there is a wallet but no transactions',
    (tester) async {
      final db = await createTestDatabase();
      final walletRepo = WalletRepositoryImpl(db);
      await walletRepo.insert(
        const Wallet(
          name: 'Test Wallet',
          startingBalance: 0,
          currentBalance: 0,
          createdAt: '2026-08-10T12:00:00.000',
        ),
      );

      await pumpDashboardScreen(tester, db: db);

      final currentMonth = DateFormat.MMMM('en').format(DateTime.now());
      expect(find.text(currentMonth), findsOneWidget);
      expect(find.text('Add first transaction'), findsOneWidget);
      expect(find.text('No transactions yet'), findsOneWidget);
    },
  );

  testWidgets('Shows balance, category spending, and recent transactions', (
    tester,
  ) async {
    final db = await createTestDatabase();
    final walletRepo = WalletRepositoryImpl(db);
    final categoryRepo = CategoryRepositoryImpl(db);
    final transactionRepo = TransactionRepositoryImpl(db);

    final walletId = await walletRepo.insert(
      const Wallet(
        name: 'Test Wallet',
        startingBalance: 10000,
        currentBalance: 10000,
        createdAt: '2026-08-10T12:00:00.000',
      ),
    );
    final groceriesCategory = (await categoryRepo.getAll()).firstWhere(
      (c) => c.type == CategoryType.groceries,
    );

    final today = DateTime.now().toIso8601String();
    await transactionRepo.insert(
      Transaction(
        walletId: walletId,
        categoryId: groceriesCategory.id,
        amount: 2500,
        type: TransactionType.expense,
        date: today,
        description: 'Weekly shop',
        createdAt: today,
      ),
    );

    await pumpDashboardScreen(tester, db: db);

    expect(find.text('Total Balance'), findsOneWidget);
    expect(find.text('\$75.00'), findsOneWidget); // 10000 - 2500 cents
    expect(find.text('Weekly shop'), findsOneWidget);
    expect(find.text(groceriesCategory.name), findsOneWidget);
  });

  testWidgets('Hiding the balance masks every amount on the dashboard', (
    tester,
  ) async {
    final db = await createTestDatabase();
    final walletId = await WalletRepositoryImpl(db).insert(
      const Wallet(
        name: 'Test Wallet',
        startingBalance: 10000,
        currentBalance: 10000,
        createdAt: '2026-08-10T12:00:00.000',
      ),
    );
    final groceries = (await CategoryRepositoryImpl(
      db,
    ).getAll()).firstWhere((c) => c.type == CategoryType.groceries);
    final today = DateTime.now().toIso8601String();
    await TransactionRepositoryImpl(db).insert(
      Transaction(
        walletId: walletId,
        categoryId: groceries.id,
        amount: 2500,
        type: TransactionType.expense,
        date: today,
        description: 'Weekly shop',
        createdAt: today,
      ),
    );
    await pumpDashboardScreen(tester, db: db);
    expect(find.textContaining(r'$'), findsWidgets);

    ProviderScope.containerOf(
      tester.element(find.byType(DashboardScreen)),
    ).read(balanceHiddenProvider.notifier).toggle();
    await tester.pumpAndSettle();

    expect(find.textContaining(r'$'), findsNothing);
    expect(find.text(hiddenAmount), findsWidgets);
    // Non-money content stays visible.
    expect(find.text('Weekly shop'), findsOneWidget);
  });

  testWidgets(
    'Switching month keeps the dashboard on screen instead of a spinner',
    (tester) async {
      tester.view.physicalSize = const Size(400, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      final db = await createTestDatabase();
      currentDb = db;
      await WalletRepositoryImpl(db).insert(
        const Wallet(name: 'Test Wallet', createdAt: '2026-08-10T12:00:00.000'),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appDatabaseProvider.overrideWith((ref) async => db),
            // On a device, sqflite answers over a platform channel and takes
            // a few frames; the in-memory test DB answers instantly, which
            // would hide the reload state this test is about.
            transactionRepositoryProvider.overrideWith(
              (ref) async => _SlowTransactionRepository(db),
            ),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            locale: const Locale('en'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const DashboardScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final now = DateTime.now();
      final currentMonth = DateFormat.MMMM('en').format(now);
      final container = ProviderScope.containerOf(
        tester.element(find.byType(DashboardScreen)),
      );

      // Same call the month pill's onTap makes.
      container
          .read(selectedDashboardMonthProvider.notifier)
          .select(DateTime(now.year, now.month - 1));
      // One frame only: the dashboard is now reloading for the new month.
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text(currentMonth), findsOneWidget);

      await tester.pumpAndSettle();
    },
  );
}

class _SlowTransactionRepository extends TransactionRepositoryImpl {
  _SlowTransactionRepository(super.db);

  @override
  Future<List<Transaction>> getAll({
    SortOrder sortOrder = SortOrder.desc,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    return super.getAll(sortOrder: sortOrder);
  }
}
