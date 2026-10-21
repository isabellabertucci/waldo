import 'package:alchemist/alchemist.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart' hide Transaction;

import 'package:waldo/core/constants/db_constants.dart';
import 'package:waldo/core/widgets/confirmation_dialog.dart';
import 'package:waldo/core/widgets/dashed_stitch_button.dart';
import 'package:waldo/core/widgets/undo_snack_bar.dart';
import 'package:waldo/core/constants/enums.dart';
import 'package:waldo/features/categories/ui/categories_screen.dart';
import 'package:waldo/features/dashboard/models/dashboard_data.dart';
import 'package:waldo/features/dashboard/ui/dashboard_screen.dart';
import 'package:waldo/features/dashboard/ui/widgets/cash_flow_card.dart';
import 'package:waldo/features/settings/ui/settings_screen.dart';
import 'package:waldo/features/transactions/models/transaction.dart';
import 'package:waldo/features/transactions/ui/all_transactions_screen.dart';
import 'package:waldo/features/transactions/ui/widgets/transaction_edit_sheet.dart';
import 'package:waldo/features/transactions/ui/widgets/transaction_form_sheet.dart';
import 'package:waldo/features/wallets/ui/wallets_screen.dart';

import '../helpers/golden_seed.dart';
import '../helpers/test_app.dart';

/// Phone widths (a small 320dp phone and a common 390dp one) and the larger
/// accessibility text sizes. Any overflow fails the test.
const _screens = [Size(320, 640), Size(390, 844)];
const _textScales = [1.3, 1.6, 2.0];

void main() {
  Database? currentDb;

  // Real fonts: the test font draws every letter as a wide square, which
  // overflows long before real text would.
  setUpAll(loadFonts);

  tearDown(() async {
    await currentDb?.close();
    currentDb = null;
  });

  Future<void> setUpPhone(WidgetTester tester, Size size, double scale) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    tester.platformDispatcher.textScaleFactorTestValue = scale;
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
  }

  for (final size in _screens) {
    for (final scale in _textScales) {
      final label = '${size.width.toInt()}dp, text x$scale';

      for (final locale in const [Locale('en'), Locale('pt')]) {
        testWidgets('Wallets and the new wallet sheet fit in $locale at $label', (
          tester,
        ) async {
          await setUpPhone(tester, size, scale);
          tester.platformDispatcher.localeTestValue = locale;
          addTearDown(tester.platformDispatcher.clearLocaleTestValue);
          // A wallet with income and spending, so the "Kept 98%" caption shows.
          final db = await createTestDatabase();
          await seedGoldenData(db);
          currentDb = await pumpWidgetWithProviders(
            tester,
            const WalletsScreen(),
            db: db,
            locale: locale,
          );

          await tester.tap(find.byType(DashedStitchButton));
          await tester.pumpAndSettle();

          expect(find.byKey(const Key('walletNameField')), findsOneWidget);
        });
      }

      testWidgets('The dashboard receipt fits in Portuguese at $label', (
        tester,
      ) async {
        await setUpPhone(tester, size, scale);
        // Portuguese money ("12,50 €") and labels run longer than English.
        tester.platformDispatcher.localeTestValue = const Locale('pt', 'PT');
        addTearDown(tester.platformDispatcher.clearLocaleTestValue);
        final db = await createTestDatabase();
        await seedGoldenData(db);
        currentDb = await pumpWidgetWithProviders(
          tester,
          const DashboardScreen(),
          db: db,
          locale: const Locale('pt'),
        );

        expect(find.text('BALANÇO'), findsOneWidget);
      });

      for (final locale in const [Locale('en'), Locale('pt')]) {
        testWidgets('The transaction list fits in $locale at $label', (
          tester,
        ) async {
          await setUpPhone(tester, size, scale);
          tester.platformDispatcher.localeTestValue = locale;
          addTearDown(tester.platformDispatcher.clearLocaleTestValue);
          final db = await createTestDatabase();
          await seedGoldenData(db);
          currentDb = await pumpWidgetWithProviders(
            tester,
            const AllTransactionsScreen(),
            db: db,
            locale: locale,
          );

          // Every row makes the same choice: amounts all share their right
          // edge (beside the text) or all their left edge (under it).
          final amounts = find.textContaining(RegExp(r'^[-+]')).evaluate();
          final rights = {
            for (final a in amounts)
              tester.getTopRight(find.byWidget(a.widget)).dx.round(),
          };
          final lefts = {
            for (final a in amounts)
              tester.getTopLeft(find.byWidget(a.widget)).dx.round(),
          };
          expect(amounts, isNotEmpty);
          expect(rights.length == 1 || lefts.length == 1, isTrue);
        });
      }

      for (final locale in const [Locale('en'), Locale('pt')]) {
        testWidgets('The cash flow card stays readable in $locale at $label', (
          tester,
        ) async {
          await setUpPhone(tester, size, scale);
          currentDb = await pumpWidgetWithProviders(
            tester,
            Scaffold(
              body: Padding(
                padding: const EdgeInsets.all(24),
                child: CashFlowCard(
                  monthlyCashFlow: [
                    for (var i = 11; i >= 0; i--)
                      MonthlyCashFlow(
                        month: DateTime(2026, 10 - i),
                        income: 0,
                        expense: 1000 * i,
                      ),
                  ],
                  currency: Currency.eur,
                  isBalanceHidden: false,
                ),
              ),
            ),
            locale: locale,
          );

          // The title keeps whole words, not one letter a line.
          final title = tester.getSize(
            find.text(
              locale.languageCode == 'pt' ? 'Fluxo de caixa' : 'Cash flow',
            ),
          );
          expect(title.width, greaterThan(title.height));

          // Month labels never overlap, and the last month always shows.
          final chart = find.byType(LineChart);
          final labels = [
            for (final e
                in find
                    .descendant(of: chart, matching: find.byType(Text))
                    .evaluate())
              tester.getRect(find.byWidget(e.widget)),
          ]..sort((a, b) => a.left.compareTo(b.left));
          expect(labels.length, greaterThan(1));
          for (var i = 1; i < labels.length; i++) {
            expect(labels[i].left, greaterThanOrEqualTo(labels[i - 1].right));
          }
          expect(
            find.descendant(
              of: chart,
              matching: find.text(locale.languageCode == 'pt' ? 'out.' : 'Oct'),
            ),
            findsOneWidget,
          );
        });
      }

      for (final locale in const [Locale('en'), Locale('pt')]) {
        testWidgets('The new transaction sheet fits in $locale at $label', (
          tester,
        ) async {
          await setUpPhone(tester, size, scale);
          tester.platformDispatcher.localeTestValue = locale;
          addTearDown(tester.platformDispatcher.clearLocaleTestValue);
          currentDb = await pumpWidgetWithProviders(
            tester,
            Scaffold(
              body: Builder(
                builder: (context) => TextButton(
                  onPressed: () => showTransactionFormSheet(context),
                  child: const Text('open'),
                ),
              ),
            ),
            locale: locale,
          );

          await tester.tap(find.text('open'));
          await tester.pumpAndSettle();

          expect(
            find.byKey(const Key('transactionAmountField')),
            findsOneWidget,
          );
        });

        testWidgets('Categories fit in $locale at $label', (tester) async {
          await setUpPhone(tester, size, scale);
          tester.platformDispatcher.localeTestValue = locale;
          addTearDown(tester.platformDispatcher.clearLocaleTestValue);
          currentDb = await pumpWidgetWithProviders(
            tester,
            const CategoriesScreen(),
            locale: locale,
          );

          expect(find.byKey(const Key('categoryNameField')), findsOneWidget);
        });
      }

      testWidgets('The undo bar keeps its text inside at $label', (
        tester,
      ) async {
        await setUpPhone(tester, size, scale);
        currentDb = await pumpWidgetWithProviders(
          tester,
          Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () => showUndoSnackBar(
                  ScaffoldMessenger.of(context),
                  title: 'Transaction deleted',
                  subtitle: 'Coffee with friends',
                  restoredLabel: 'Transaction restored',
                ),
                child: const Text('delete'),
              ),
            ),
          ),
        );

        await tester.tap(find.text('delete'));
        // Not pumpAndSettle: the countdown would run out.
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 400));

        expect(find.text('Coffee with friends'), findsOneWidget);
        await tester.pump(const Duration(seconds: 6));
        await tester.pumpAndSettle();
      });

      testWidgets('The transaction detail sheet fits at $label', (
        tester,
      ) async {
        await setUpPhone(tester, size, scale);
        final db = await createTestDatabase();
        await seedGoldenData(db);
        final transaction = Transaction.fromMap(
          (await db.query(TransactionsTable.table, limit: 1)).first,
        );
        currentDb = await pumpWidgetWithProviders(
          tester,
          Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () =>
                    showTransactionEditSheet(context, transaction: transaction),
                child: const Text('open'),
              ),
            ),
          ),
          db: db,
        );

        await tester.tap(find.text('open'));
        await tester.pumpAndSettle();

        expect(find.text('Amount'), findsOneWidget);
      });

      for (final (locale, rows, done) in const [
        (Locale('en'), ['Theme', 'Currency', 'Date format'], 'Done'),
        (Locale('pt'), ['Tema', 'Moeda', 'Formato de data'], 'Concluído'),
      ]) {
        testWidgets('Settings and its pickers fit in $locale at $label', (
          tester,
        ) async {
          await setUpPhone(tester, size, scale);
          tester.platformDispatcher.localeTestValue = locale;
          addTearDown(tester.platformDispatcher.clearLocaleTestValue);
          currentDb = await pumpWidgetWithProviders(
            tester,
            const SettingsScreen(),
            locale: locale,
          );

          for (final row in rows) {
            await tester.scrollUntilVisible(
              find.text(row),
              100,
              scrollable: find.byType(Scrollable).first,
            );
            // Mid-screen, clear of the pinned header that covers the top.
            await Scrollable.ensureVisible(
              tester.element(find.text(row)),
              alignment: 0.5,
            );
            await tester.pumpAndSettle();
            await tester.tap(find.text(row));
            await tester.pumpAndSettle();
            await tester.ensureVisible(find.text(done));
            await tester.pumpAndSettle();
            await tester.tap(find.text(done));
            await tester.pumpAndSettle();
          }
        });
      }
    }
  }

  for (final scale in _textScales) {
    testWidgets('On a small phone at text x$scale the delete dialog keeps its '
        'buttons reachable', (tester) async {
      // iPhone SE (1st gen): the shortest screen in use.
      await setUpPhone(tester, const Size(320, 568), scale);
      currentDb = await pumpWidgetWithProviders(
        tester,
        Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => ConfirmationDialog.show(
                context,
                title: 'Delete category?',
                // The longest message the dialog shows.
                content:
                    '12 transactions use "Subscriptions". If you delete it, '
                    'they move to Others.',
                confirmLabel: 'Delete',
              ),
              child: const Text('open'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Delete'));
      await tester.pumpAndSettle();

      expect(find.text('Delete').hitTestable(), findsOneWidget);
    });
  }

  testWidgets('With large text a settings value moves under its title', (
    tester,
  ) async {
    await setUpPhone(tester, const Size(390, 844), 2.0);
    currentDb = await pumpWidgetWithProviders(tester, const SettingsScreen());

    final title = tester.getRect(find.text('Currency'));
    final value = tester.getRect(find.text('USD'));
    expect(value.top, greaterThan(title.bottom));
  });
}
