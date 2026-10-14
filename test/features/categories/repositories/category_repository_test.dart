import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart' hide Transaction;
import 'package:waldo/core/constants/db_constants.dart';
import 'package:waldo/core/constants/enums.dart';
import 'package:waldo/features/categories/models/category.dart';
import 'package:waldo/features/categories/repositories/category_repository.dart';

import '../../../helpers/test_app.dart';

void main() {
  late Database db;
  late CategoryRepositoryImpl repo;

  setUp(() async {
    db = await createTestDatabase();
    repo = CategoryRepositoryImpl(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('CategoryRepositoryImpl', () {
    test('insert then getAll returns the inserted category', () async {
      final before = await repo.getAll();

      await repo.insert(
        const Category(
          name: 'Groceries Test',
          createdAt: '2026-08-10T12:00:00.000',
        ),
      );

      final categories = await repo.getAll();

      expect(categories, hasLength(before.length + 1));
      expect(categories.map((c) => c.name), contains('Groceries Test'));
    });

    test('getById returns null for a non-existent id', () async {
      expect(await repo.getById(999), isNull);
    });

    test(
      'insert rejects a second custom category with the same name',
      () async {
        await repo.insert(_custom('Escola'));

        expect(
          () => repo.insert(_custom('Escola')),
          throwsA(isA<DuplicateCategoryNameException>()),
        );
      },
    );

    test(
      'insert treats names that differ only in case as duplicates',
      () async {
        await repo.insert(_custom('Escola'));

        expect(
          () => repo.insert(_custom('escola')),
          throwsA(isA<DuplicateCategoryNameException>()),
        );
      },
    );

    test('insert allows a custom category named like a built-in', () async {
      // Built-ins are shown translated, so their stored name doesn't count.
      final id = await repo.insert(_custom('Groceries'));

      expect(id, greaterThan(0));
    });

    test('delete removes a category with no transactions', () async {
      final id = await repo.insert(
        const Category(
          name: 'Groceries Test',
          createdAt: '2026-08-10T12:00:00.000',
        ),
      );

      await repo.delete(id);

      expect(await repo.getById(id), isNull);
    });

    test('getOthers returns the built-in Others category', () async {
      final others = await repo.getOthers();

      expect(others.isDefault, isTrue);
      expect(others.type, CategoryType.others);
    });

    test('countTransactions counts only that category', () async {
      final walletId = await _insertWallet(db);
      final id = await repo.insert(_custom('Café'));
      await _insertTransaction(db, walletId: walletId, categoryId: id);
      await _insertTransaction(db, walletId: walletId, categoryId: id);
      await _insertTransaction(
        db,
        walletId: walletId,
        categoryId: (await repo.getOthers()).id,
      );

      expect(await repo.countTransactions(id), 2);
    });

    test('delete moves the category\'s transactions to Others', () async {
      final walletId = await _insertWallet(db);
      final id = await repo.insert(_custom('Café'));
      await _insertTransaction(db, walletId: walletId, categoryId: id);
      final others = await repo.getOthers();

      await repo.delete(id);

      expect(await repo.getById(id), isNull);
      expect(await repo.countTransactions(others.id!), 1);
    });

    test('delete allows a built-in category other than Others', () async {
      final groceries = (await repo.getAll()).firstWhere(
        (c) => c.type == CategoryType.groceries,
      );

      await repo.delete(groceries.id!);

      expect(await repo.getById(groceries.id!), isNull);
    });

    test('delete refuses the Others category', () async {
      final others = await repo.getOthers();

      expect(
        () => repo.delete(others.id!),
        throwsA(isA<CannotDeleteOthersCategoryException>()),
      );
      expect(await repo.getById(others.id!), isNotNull);
    });
  });
}

Future<int> _insertWallet(Database db) => db.insert(WalletsTable.table, {
  WalletsTable.name: 'Cash',
  WalletsTable.createdAt: '2026-08-10T12:00:00.000',
});

Future<int> _insertTransaction(
  Database db, {
  required int walletId,
  required int? categoryId,
}) => db.insert(TransactionsTable.table, {
  TransactionsTable.walletId: walletId,
  TransactionsTable.categoryId: categoryId,
  TransactionsTable.amount: 100,
  TransactionsTable.type: TransactionType.expense.name,
  TransactionsTable.date: '2026-08-10T00:00:00.000',
  TransactionsTable.createdAt: '2026-08-10T12:00:00.000',
});

Category _custom(String name) =>
    Category(name: name, createdAt: '2026-08-10T12:00:00.000');
