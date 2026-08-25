import 'package:waldo/core/constants/enums.dart';
import 'package:waldo/features/categories/models/category.dart';
import 'package:waldo/features/transactions/models/transaction.dart';
import 'package:waldo/features/wallets/models/wallet.dart';

/// Default timestamp used by fixtures so tests only specify
const testCreatedAt = '2026-08-10T12:00:00.000';

Wallet testWallet({
  int? id,
  String name = 'Test Wallet',
  WalletType type = WalletType.cash,
  int startingBalance = 0,
  int? currentBalance,
  String createdAt = testCreatedAt,
}) {
  return Wallet(
    id: id,
    name: name,
    type: type,
    startingBalance: startingBalance,
    currentBalance: currentBalance ?? startingBalance,
    createdAt: createdAt,
  );
}

Transaction testTransaction(
  int walletId, {
  int? id,
  int? categoryId,
  int amount = 100,
  TransactionType type = TransactionType.income,
  String date = '2026-08-10',
  String? description,
  String createdAt = testCreatedAt,
}) {
  return Transaction(
    id: id,
    walletId: walletId,
    categoryId: categoryId,
    amount: amount,
    type: type,
    date: date,
    description: description,
    createdAt: createdAt,
  );
}

Category testCategory({
  int? id,
  String name = 'Test Category',
  CategoryType type = CategoryType.groceries,
  String createdAt = testCreatedAt,
}) {
  return Category(id: id, name: name, type: type, createdAt: createdAt);
}
