import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart' hide Transaction;
import 'package:waldo/core/constants/db_constants.dart';
import 'package:waldo/features/transactions/models/transaction.dart';
import 'package:waldo/features/transactions/ui/widgets/transaction_edit_sheet.dart';

import '../../../../helpers/golden_seed.dart';
import '../../../../helpers/test_app.dart';

void main() {
  Database? currentDb;

  tearDown(() async {
    await currentDb?.close();
    currentDb = null;
  });

  testWidgets('A delete whose list cannot load says so instead of nothing', (
    tester,
  ) async {
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
            onPressed: () => deleteTransactionWithUndo(context, transaction),
            child: const Text('delete'),
          ),
        ),
      ),
      db: db,
    );
    // The wallet's list hasn't loaded yet, and now it can't.
    await db.execute('DROP TABLE ${TransactionsTable.table}');

    await tester.tap(find.text('delete'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    // Riverpod retries a failed load (about 38 s in all) before giving up.
    final message = find.text(
      "Couldn't delete the transaction. Nothing was changed.",
    );
    for (var i = 0; i < 45 && message.evaluate().isEmpty; i++) {
      await tester.pump(const Duration(seconds: 1));
    }

    expect(message, findsOneWidget);
  });
}
