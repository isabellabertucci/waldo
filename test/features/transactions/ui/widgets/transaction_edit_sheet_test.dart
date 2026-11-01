import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart' hide Transaction;

import 'package:waldo/features/preferences/repositories/preferences_repository.dart';
import 'package:waldo/features/transactions/models/transaction.dart';
import 'package:waldo/features/transactions/repositories/transaction_repository.dart';
import 'package:waldo/features/transactions/ui/widgets/transaction_edit_sheet.dart';
import 'package:waldo/features/wallets/models/wallet.dart';
import 'package:waldo/features/wallets/repositories/wallet_repository.dart';

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
      await tester.ensureVisible(find.byKey(Key(key)));
      await tester.pumpAndSettle();
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

  testWidgets('A transaction moved and renamed here, then deleted, is the '
      'one the Undo bar names and deletes', (tester) async {
    final db = await createTestDatabase();
    addTearDown(db.close);
    await seedGoldenData(db);
    final savingsId = await WalletRepositoryImpl(db).insert(
      const Wallet(name: 'Savings', createdAt: '2026-10-02T12:00:00.000'),
    );
    final transaction = await openSheet(tester, db, startInEditMode: true);

    await tester.enterText(find.byKey(const Key('txNameField')), 'Rent');
    await tester.ensureVisible(find.byKey(const Key('txWalletField')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('txWalletField')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Savings'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Save changes'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save changes'));
    await tester.pumpAndSettle();

    final repo = TransactionRepositoryImpl(db);
    expect((await repo.getById(transaction.id!))!.walletId, savingsId);

    await tester.tap(find.byTooltip('Delete'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Rent'), findsOneWidget, reason: 'the Undo bar');

    // Past the Undo window, the delete goes through.
    for (var i = 0; i < 8; i++) {
      await tester.pump(const Duration(seconds: 1));
    }
    expect(await repo.getById(transaction.id!), isNull);
  });
}
