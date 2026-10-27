import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:waldo/core/constants/db_constants.dart';
import 'package:waldo/core/constants/enums.dart';
import 'package:waldo/core/database/migrations.dart' as migrations;

void main() {
  late Database db;

  setUp(() async {
    sqfliteFfiInit();
    db = await databaseFactoryFfiNoIsolate.openDatabase(inMemoryDatabasePath);
    await db.execute('PRAGMA foreign_keys = ON');
  });

  tearDown(() => db.close());

  test('upgrading from v1 to v2 adds the note column and keeps existing '
      'transactions', () async {
    // A database as it existed before the note column: schema v1 only.
    await migrations.onCreate(db, 1);
    final walletId = await db.insert(WalletsTable.table, {
      WalletsTable.name: 'Cash',
      WalletsTable.createdAt: '2026-08-01T12:00:00.000',
    });
    await db.insert(TransactionsTable.table, {
      TransactionsTable.walletId: walletId,
      TransactionsTable.amount: 500,
      TransactionsTable.type: TransactionType.expense.name,
      TransactionsTable.date: '2026-08-10',
      TransactionsTable.createdAt: '2026-08-10T12:00:00.000',
    });

    await migrations.onUpgrade(db, 1, 2);

    final rows = await db.query(TransactionsTable.table);
    expect(rows, hasLength(1));
    expect(rows.first[TransactionsTable.amount], 500);
    expect(rows.first.containsKey(TransactionsTable.note), isTrue);
    expect(rows.first[TransactionsTable.note], isNull);
  });
}
