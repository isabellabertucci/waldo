import 'package:sqflite_common_ffi/sqflite_ffi.dart' hide Transaction;

import 'package:waldo/core/constants/enums.dart';
import 'package:waldo/features/categories/repositories/category_repository.dart';
import 'package:waldo/features/transactions/models/transaction.dart';
import 'package:waldo/features/transactions/repositories/transaction_repository.dart';
import 'package:waldo/features/wallets/models/wallet.dart';
import 'package:waldo/features/wallets/repositories/wallet_repository.dart';

/// One wallet with one income and one expense, shared by the golden tests.
class GoldenSeed {
  const GoldenSeed({required this.walletId});

  final int walletId;
}

Future<GoldenSeed> seedGoldenData(Database db) async {
  final walletRepo = WalletRepositoryImpl(db);
  final categoryRepo = CategoryRepositoryImpl(db);
  final transactionRepo = TransactionRepositoryImpl(db);

  final walletId = await walletRepo.insert(
    const Wallet(
      name: 'Everyday',
      startingBalance: 100000,
      currentBalance: 100000,
      createdAt: '2026-10-01T12:00:00.000',
    ),
  );

  final groceries = (await categoryRepo.getAll()).firstWhere(
    (c) => c.type == CategoryType.groceries,
  );

  final today = DateTime(2026, 10, 8).toIso8601String();

  await transactionRepo.insert(
    Transaction(
      walletId: walletId,
      categoryId: groceries.id,
      amount: 250000,
      type: TransactionType.income,
      date: today,
      description: 'Paycheck',
      createdAt: today,
    ),
  );

  await transactionRepo.insert(
    Transaction(
      walletId: walletId,
      categoryId: groceries.id,
      amount: 4200,
      type: TransactionType.expense,
      date: today,
      description: 'Weekly groceries',
      createdAt: today,
    ),
  );

  return GoldenSeed(walletId: walletId);
}
