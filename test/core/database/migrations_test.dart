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

  group('v2 -> v3 (the "others" category type)', () {
    Future<int> categoryIdOf(String type) async {
      final rows = await db.query(
        CategoriesTable.table,
        where:
            '${CategoriesTable.type} = ? AND ${CategoriesTable.isDefault} = 1',
        whereArgs: [type],
      );
      return rows.single[CategoriesTable.id] as int;
    }

    test('every transaction keeps its category through the upgrade', () async {
      await migrations.onCreate(db, 2);
      final walletId = await db.insert(WalletsTable.table, {
        WalletsTable.name: 'Cash',
        WalletsTable.createdAt: '2026-08-01T12:00:00.000',
      });
      final groceriesId = await categoryIdOf(CategoryType.groceries.name);
      final customId = await db.insert(CategoriesTable.table, {
        CategoriesTable.name: 'Coffee',
        CategoriesTable.type: CategoryType.groceries.name,
        CategoriesTable.createdAt: '2026-08-01T12:00:00.000',
      });
      Future<int> addTransaction(int? categoryId) {
        return db.insert(TransactionsTable.table, {
          TransactionsTable.walletId: walletId,
          TransactionsTable.categoryId: categoryId,
          TransactionsTable.amount: 500,
          TransactionsTable.type: TransactionType.expense.name,
          TransactionsTable.date: '2026-08-10',
          TransactionsTable.createdAt: '2026-08-10T12:00:00.000',
        });
      }

      final withDefault = await addTransaction(groceriesId);
      final withCustom = await addTransaction(customId);
      final withNone = await addTransaction(null);

      await migrations.onUpgrade(db, 2, 3);

      Future<Object?> categoryOf(int transactionId) async => (await db.query(
        TransactionsTable.table,
        where: '${TransactionsTable.id} = ?',
        whereArgs: [transactionId],
      )).single[TransactionsTable.categoryId];

      expect(await categoryOf(withDefault), groceriesId);
      expect(await categoryOf(withCustom), customId);
      expect(await categoryOf(withNone), isNull);
      expect(await db.rawQuery('PRAGMA foreign_key_check'), isEmpty);
    });

    test('adds the built-in "Others" category and allows the type', () async {
      await migrations.onCreate(db, 2);
      await migrations.onUpgrade(db, 2, 3);

      final defaults = await db.query(
        CategoriesTable.table,
        where: '${CategoriesTable.isDefault} = 1',
      );
      expect(defaults, hasLength(6));
      expect(await categoryIdOf(CategoryType.others.name), isPositive);

      // A custom category of the new type is accepted by the CHECK.
      await db.insert(CategoriesTable.table, {
        CategoriesTable.name: 'Gifts',
        CategoriesTable.type: CategoryType.others.name,
        CategoriesTable.createdAt: '2026-10-12T12:00:00.000',
      });
    });

    test('a fresh install gets all 6 built-in categories', () async {
      await migrations.onCreate(db, migrations.migrations.length);

      final defaults = await db.query(
        CategoriesTable.table,
        where: '${CategoriesTable.isDefault} = 1',
      );
      expect(defaults, hasLength(6));
    });
  });
}
