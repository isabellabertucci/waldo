import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart' hide Transaction;

import 'package:waldo/features/preferences/repositories/preferences_repository.dart';
import 'package:waldo/features/transactions/models/transaction.dart';
import 'package:waldo/features/transactions/repositories/transaction_repository.dart';
import 'package:waldo/features/transactions/ui/widgets/transaction_edit_sheet.dart';

import '../../../../helpers/golden_seed.dart';
import '../../../../helpers/test_app.dart';

void main() {
  /// Opens the sheet on the newest seeded transaction and returns it.
  Future<Transaction> openSheet(
    WidgetTester tester,
    Database db, {
    bool startInEditMode = false,
  }) async {
    final transaction = (await TransactionRepositoryImpl(db).getAll()).first;
    await pumpWidgetWithProviders(
      tester,
      Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () => showTransactionEditSheet(
              context,
              transaction: transaction,
              startInEditMode: startInEditMode,
            ),
            child: const Text('open'),
          ),
        ),
      ),
      db: db,
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    return transaction;
  }

  testWidgets('The title and note fields have no fill or focus ring of their '
      'own, since the card shows focus', (tester) async {
    final db = await createTestDatabase();
    addTearDown(db.close);
    await seedGoldenData(db);
    await openSheet(tester, db, startInEditMode: true);

    for (final key in const ['txNameField', 'txNoteField']) {
      await tester.tap(find.byKey(Key(key)));
      await tester.pumpAndSettle();

      // The decoration as drawn, after the theme's defaults are applied.
      final decoration = tester
          .widget<InputDecorator>(
            find.descendant(
              of: find.byKey(Key(key)),
              matching: find.byType(InputDecorator),
            ),
          )
          .decoration;
      expect(decoration.filled, isFalse, reason: key);
      expect(decoration.focusedBorder, InputBorder.none, reason: key);
    }
  });

  testWidgets('The date uses the format picked in Settings', (tester) async {
    final db = await createTestDatabase();
    addTearDown(db.close);
    await seedGoldenData(db);
    final preferences = PreferencesRepositoryImpl(db);
    await preferences.getPreferences(); // Creates the row the update changes.
    await preferences.setDateFormat('dd/MM/yyyy');

    final transaction = await openSheet(tester, db);

    final date = DateFormat(
      'dd/MM/yyyy',
    ).format(DateTime.parse(transaction.date));
    expect(find.text(date), findsOneWidget);
  });
}
