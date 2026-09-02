// ignore_for_file: file_names

import 'package:sqflite/sqflite.dart';
import 'package:waldo/core/constants/enums.dart';
import '../../constants/db_constants.dart';

Future<void> up(Database db) async {
  await db.execute('''
    CREATE TABLE ${WalletsTable.table} (
      ${WalletsTable.id} INTEGER PRIMARY KEY AUTOINCREMENT,
      ${WalletsTable.name} TEXT NOT NULL,
      ${WalletsTable.type} TEXT NOT NULL DEFAULT '${WalletType.cash.name}'
        CHECK (${WalletsTable.type} IN (
          '${WalletType.checking.name}',
          '${WalletType.savings.name}',
          '${WalletType.cash.name}',
          '${WalletType.credit.name}',
          '${WalletType.investment.name}'
        )),
      ${WalletsTable.startingBalance} INTEGER NOT NULL DEFAULT 0,
      ${WalletsTable.currentBalance} INTEGER NOT NULL DEFAULT 0,
      ${WalletsTable.createdAt} TEXT NOT NULL
    )
  ''');

  await db.execute('''
    CREATE TABLE ${CategoriesTable.table} (
      ${CategoriesTable.id} INTEGER PRIMARY KEY AUTOINCREMENT,
      ${CategoriesTable.name} TEXT NOT NULL,
      ${CategoriesTable.isDefault} INTEGER NOT NULL DEFAULT 0,
      ${CategoriesTable.createdAt} TEXT NOT NULL
    )
  ''');

  final now = DateTime.now().toIso8601String();
  const defaultCategoryNames = [
    'Groceries',
    'Transportation',
    'Subscriptions',
    'Education',
    'Investments',
  ];

  final batch = db.batch();
  for (final name in defaultCategoryNames) {
    batch.insert(CategoriesTable.table, {
      CategoriesTable.name: name,
      CategoriesTable.isDefault: 1,
      CategoriesTable.createdAt: now,
    });
  }
  await batch.commit(noResult: true);

  await db.execute('''
    CREATE TABLE ${TransactionsTable.table} (
      ${TransactionsTable.id} INTEGER PRIMARY KEY AUTOINCREMENT,
      ${TransactionsTable.walletId} INTEGER NOT NULL,
      ${TransactionsTable.categoryId} INTEGER,
      ${TransactionsTable.amount} INTEGER NOT NULL
        CHECK (${TransactionsTable.amount} > 0),
      ${TransactionsTable.type} TEXT NOT NULL
        CHECK (${TransactionsTable.type} IN (
          '${TransactionType.income.name}',
          '${TransactionType.expense.name}'
        )),
      ${TransactionsTable.date} TEXT NOT NULL,
      ${TransactionsTable.description} TEXT,
      ${TransactionsTable.createdAt} TEXT NOT NULL,
      FOREIGN KEY (${TransactionsTable.walletId}) REFERENCES ${WalletsTable.table} (${WalletsTable.id}) ON DELETE CASCADE,      FOREIGN KEY (${TransactionsTable.categoryId}) REFERENCES ${CategoriesTable.table} (${CategoriesTable.id}) ON DELETE SET NULL
    )
  ''');

  await db.execute('''
    CREATE TABLE ${PreferencesTable.table} (
      ${PreferencesTable.id} INTEGER PRIMARY KEY AUTOINCREMENT,
      ${PreferencesTable.preferredCurrency} TEXT NOT NULL DEFAULT 'USD',
      ${PreferencesTable.themeDark} INTEGER NOT NULL DEFAULT 0,
      ${PreferencesTable.dateFormat} TEXT NOT NULL DEFAULT 'yyyy-MM-dd',
      ${PreferencesTable.updatedAt} TEXT NOT NULL
    )
  ''');
}
