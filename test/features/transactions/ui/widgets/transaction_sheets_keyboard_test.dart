import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart' hide Transaction;

import 'package:waldo/features/transactions/repositories/transaction_repository.dart';
import 'package:waldo/features/transactions/ui/widgets/transaction_edit_sheet.dart';
import 'package:waldo/features/transactions/ui/widgets/transaction_form_sheet.dart';

import '../../../../helpers/golden_seed.dart';
import '../../../../helpers/sheet_keyboard.dart';
import '../../../../helpers/test_app.dart';

void main() {
  Database? currentDb;

  tearDown(() async {
    await currentDb?.close();
    currentDb = null;
  });

  Future<void> openFormSheet(WidgetTester tester) async {
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
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  group('New transaction sheet, keyboard open', () {
    testWidgets('amount field', (tester) async {
      useSmallAndroidPhone(tester);
      await openFormSheet(tester);
      await expectSheetScrollsWithKeyboard(
        tester,
        field: find.byKey(const Key('transactionAmountField')),
        sheet: find.byType(TransactionFormSheet),
        lastButton: find.text('Add expense'),
      );
    });

    testWidgets('description field', (tester) async {
      useSmallAndroidPhone(tester);
      await openFormSheet(tester);
      await expectSheetScrollsWithKeyboard(
        tester,
        field: find.byKey(const Key('transactionDescriptionField')),
        sheet: find.byType(TransactionFormSheet),
        lastButton: find.text('Add expense'),
      );
    });
  });

  group('Edit transaction sheet, keyboard open', () {
    Future<void> openEditSheet(WidgetTester tester) async {
      final db = await createTestDatabase();
      currentDb = db;
      await seedGoldenData(db);
      final transaction = (await TransactionRepositoryImpl(db).getAll()).first;
      await pumpWidgetWithProviders(
        tester,
        Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => showTransactionEditSheet(
                context,
                transaction: transaction,
                startInEditMode: true,
              ),
              child: const Text('open'),
            ),
          ),
        ),
        db: db,
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
    }

    testWidgets('name field', (tester) async {
      useSmallAndroidPhone(tester);
      await openEditSheet(tester);
      await expectSheetScrollsWithKeyboard(
        tester,
        field: find.byKey(const Key('txNameField')),
        sheet: find.byType(TransactionEditSheet),
        lastButton: find.text('Save changes'),
      );
    });

    testWidgets('note field', (tester) async {
      useSmallAndroidPhone(tester);
      await openEditSheet(tester);
      await expectSheetScrollsWithKeyboard(
        tester,
        field: find.byType(TextField).last,
        sheet: find.byType(TransactionEditSheet),
        lastButton: find.text('Save changes'),
      );
    });

    testWidgets('without the keyboard, Save sits above the nav bar', (
      tester,
    ) async {
      useSmallAndroidPhone(tester);
      await openEditSheet(tester);
      final sheet = tester.getRect(find.byType(TransactionEditSheet));
      await tester.dragFrom(
        Offset(sheet.center.dx, sheet.top + 60),
        const Offset(0, -600),
      );
      await tester.pumpAndSettle();
      final save = find.text('Save changes');
      expect(tester.getBottomLeft(save).dy, lessThanOrEqualTo(640 - 48));
    });

    testWidgets('both back buttons are at least 48dp to tap', (tester) async {
      useSmallAndroidPhone(tester);
      await openEditSheet(tester);

      // The edit screen's back...
      expect(tester.getSize(find.byTooltip('Back')).shortestSide, 48);

      // ...and a field editor's back.
      await tester.tap(find.byKey(const Key('txAmountField')));
      await tester.pumpAndSettle();
      expect(tester.getSize(find.byTooltip('Back')).shortestSide, 48);
    });
  });
}
