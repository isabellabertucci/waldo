import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart' hide Transaction;

import 'package:waldo/core/constants/db_constants.dart';
import 'package:waldo/core/widgets/dashed_stitch_button.dart';
import 'package:waldo/features/settings/ui/settings_screen.dart';
import 'package:waldo/features/transactions/models/transaction.dart';
import 'package:waldo/features/transactions/ui/widgets/transaction_edit_sheet.dart';
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

      testWidgets('Wallets and the new wallet sheet fit at $label', (
        tester,
      ) async {
        await setUpPhone(tester, size, scale);
        // A wallet with income and spending, so the "Kept 98%" caption shows.
        final db = await createTestDatabase();
        await seedGoldenData(db);
        currentDb = await pumpWidgetWithProviders(
          tester,
          const WalletsScreen(),
          db: db,
        );

        await tester.tap(find.byType(DashedStitchButton));
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('walletNameField')), findsOneWidget);
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

      testWidgets('Settings and its pickers fit at $label', (tester) async {
        await setUpPhone(tester, size, scale);
        currentDb = await pumpWidgetWithProviders(
          tester,
          const SettingsScreen(),
        );

        for (final row in ['Theme', 'Currency', 'Date format']) {
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
          await tester.ensureVisible(find.text('Done'));
          await tester.pumpAndSettle();
          await tester.tap(find.text('Done'));
          await tester.pumpAndSettle();
        }
      });
    }
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
