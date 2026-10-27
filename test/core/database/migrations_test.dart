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
    await migrations.onCreate(db, migrations.migrations.length);
  });

  tearDown(() => db.close());

  test(
    'a fresh install gets all 6 built-in categories, "Others" included',
    () async {
      final defaults = await db.query(
        CategoriesTable.table,
        where: '${CategoriesTable.isDefault} = 1',
      );

      expect(defaults, hasLength(6));
      expect(
        defaults.map((c) => c[CategoriesTable.type]),
        contains(CategoryType.others.name),
      );
    },
  );

  test('a custom category can use the "others" type', () async {
    await db.insert(CategoriesTable.table, {
      CategoriesTable.name: 'Gifts',
      CategoriesTable.nameKey: 'gifts',
      CategoriesTable.type: CategoryType.others.name,
      CategoriesTable.createdAt: '2026-10-12T12:00:00.000',
    });
  });

  test('transactions have a note column', () async {
    final walletId = await db.insert(WalletsTable.table, {
      WalletsTable.name: 'Cash',
      WalletsTable.nameKey: 'cash',
      WalletsTable.createdAt: '2026-08-01T12:00:00.000',
    });
    await db.insert(TransactionsTable.table, {
      TransactionsTable.walletId: walletId,
      TransactionsTable.amount: 500,
      TransactionsTable.type: TransactionType.expense.name,
      TransactionsTable.date: '2026-08-10',
      TransactionsTable.note: 'Split with Ana',
      TransactionsTable.createdAt: '2026-08-10T12:00:00.000',
    });

    final row = (await db.query(TransactionsTable.table)).single;
    expect(row[TransactionsTable.note], 'Split with Ana');
  });
}
