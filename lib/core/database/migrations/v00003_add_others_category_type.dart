// ignore_for_file: file_names

import 'package:sqflite/sqflite.dart';
import 'package:waldo/core/constants/enums.dart';
import '../../constants/db_constants.dart';

/// Widens the categories `type` CHECK to allow `others` and adds the
/// built-in "Others" category. SQLite can't alter a CHECK, so the table is
/// rebuilt.
///
/// Dropping the old table runs its ON DELETE SET NULL on every transaction
/// that points at a category - so those links are saved first and put back
/// after, and no transaction loses its category.
Future<void> up(Database db) async {
  const categories = CategoriesTable.table;
  const transactions = TransactionsTable.table;
  const links = '_transaction_categories';

  // 1. Remember every transaction -> category link.
  await db.execute('''
    CREATE TEMP TABLE $links AS
    SELECT ${TransactionsTable.id}, ${TransactionsTable.categoryId}
    FROM $transactions
    WHERE ${TransactionsTable.categoryId} IS NOT NULL
  ''');

  // 2. The same table with `others` allowed, filled with every existing row
  //    (ids included, so the links in step 4 still match).
  await db.execute('''
    CREATE TABLE ${categories}_new (
      ${CategoriesTable.id} INTEGER PRIMARY KEY AUTOINCREMENT,
      ${CategoriesTable.name} TEXT NOT NULL,
      ${CategoriesTable.isDefault} INTEGER NOT NULL DEFAULT 0,
      ${CategoriesTable.type} TEXT NOT NULL DEFAULT '${CategoryType.groceries.name}'
        CHECK (${CategoriesTable.type} IN (
          '${CategoryType.groceries.name}',
          '${CategoryType.transportation.name}',
          '${CategoryType.subscriptions.name}',
          '${CategoryType.education.name}',
          '${CategoryType.investments.name}',
          '${CategoryType.others.name}'
        )),
      ${CategoriesTable.createdAt} TEXT NOT NULL
    )
  ''');
  const columns =
      '${CategoriesTable.id}, ${CategoriesTable.name}, '
      '${CategoriesTable.isDefault}, ${CategoriesTable.type}, '
      '${CategoriesTable.createdAt}';
  await db.execute(
    'INSERT INTO ${categories}_new ($columns) SELECT $columns FROM $categories',
  );

  // 3. Swap the tables.
  await db.execute('DROP TABLE $categories');
  await db.execute('ALTER TABLE ${categories}_new RENAME TO $categories');

  // 4. Put every link back, then clean up.
  await db.execute('''
    UPDATE $transactions
    SET ${TransactionsTable.categoryId} = (
      SELECT l.${TransactionsTable.categoryId} FROM $links l
      WHERE l.${TransactionsTable.id} = $transactions.${TransactionsTable.id}
    )
    WHERE ${TransactionsTable.id} IN (SELECT ${TransactionsTable.id} FROM $links)
  ''');
  await db.execute('DROP TABLE $links');

  // 5. The new built-in category.
  await db.insert(categories, {
    CategoriesTable.name: 'Others',
    CategoriesTable.isDefault: 1,
    CategoriesTable.type: CategoryType.others.name,
    CategoriesTable.createdAt: DateTime.now().toIso8601String(),
  });
}
