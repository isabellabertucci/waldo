import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:waldo/core/constants/enums.dart';
import 'package:waldo/features/categories/models/category.dart';
import 'package:waldo/features/categories/repositories/category_repository.dart';
import 'package:waldo/features/transactions/models/transaction.dart';
import 'package:waldo/features/transactions/repositories/transaction_repository.dart';
import 'package:waldo/features/wallets/repositories/wallet_repository.dart';

import '../models/dashboard_data.dart';

part 'dashboard_view_model.g.dart';

const _trailingMonths = 12;
const _recentTransactionsLimit = 5;

@riverpod
class DashboardViewModel extends _$DashboardViewModel {
  @override
  Future<DashboardData> build() async {
    final walletRepo = await ref.watch(walletRepositoryProvider.future);
    final transactionRepo = await ref.watch(
      transactionRepositoryProvider.future,
    );
    final categoryRepo = await ref.watch(categoryRepositoryProvider.future);

    final wallets = await walletRepo.getAll();
    final transactions = await transactionRepo.getAll();
    final categories = await categoryRepo.getAll();

    final totalBalance = wallets.fold<int>(
      0,
      (sum, wallet) => sum + wallet.currentBalance,
    );

    final now = DateTime.now();
    final currentMonthTransactions = _transactionsInMonth(
      transactions,
      now.year,
      now.month,
    );
    final lastMonth = DateTime(now.year, now.month - 1);
    final lastMonthTransactions = _transactionsInMonth(
      transactions,
      lastMonth.year,
      lastMonth.month,
    );

    final monthlyIncome = _sumByType(
      currentMonthTransactions,
      TransactionType.income,
    );
    final monthlyExpense = _sumByType(
      currentMonthTransactions,
      TransactionType.expense,
    );

    return DashboardData(
      totalBalance: totalBalance,
      monthlyIncome: monthlyIncome,
      monthlyExpense: monthlyExpense,
      spendingByCategory: _buildSpendingByCategory(
        currentMonthTransactions,
        lastMonthTransactions,
        categories,
      ),
      monthlyCashFlow: _buildMonthlyCashFlow(transactions, now),
      // getAll() already sorts desc by date, so the first N are the most
      // recent transactions across every wallet.
      recentTransactions: transactions.take(_recentTransactionsLimit).toList(),
    );
  }

  List<Transaction> _transactionsInMonth(
    List<Transaction> transactions,
    int year,
    int month,
  ) {
    return transactions.where((t) {
      final date = DateTime.parse(t.date);
      return date.year == year && date.month == month;
    }).toList();
  }

  int _sumByType(List<Transaction> transactions, TransactionType type) {
    return transactions
        .where((t) => t.type == type)
        .fold<int>(0, (sum, t) => sum + t.amount);
  }

  Map<int, int> _expenseTotalsByCategory(List<Transaction> transactions) {
    final totals = <int, int>{};
    for (final t in transactions) {
      final categoryId = t.categoryId;
      if (t.type != TransactionType.expense || categoryId == null) continue;
      totals[categoryId] = (totals[categoryId] ?? 0) + t.amount;
    }
    return totals;
  }

  List<CategorySpending> _buildSpendingByCategory(
    List<Transaction> currentMonthTransactions,
    List<Transaction> lastMonthTransactions,
    List<Category> categories,
  ) {
    final currentTotals = _expenseTotalsByCategory(currentMonthTransactions);
    final lastTotals = _expenseTotalsByCategory(lastMonthTransactions);
    final categoriesById = {for (final c in categories) c.id: c};

    final spending = <CategorySpending>[];
    for (final entry in currentTotals.entries) {
      final category = categoriesById[entry.key];
      if (category == null) continue;

      final lastMonthAmount = lastTotals[entry.key] ?? 0;
      final percentChange = lastMonthAmount == 0
          ? null
          : ((entry.value - lastMonthAmount) / lastMonthAmount) * 100;

      spending.add(
        CategorySpending(
          category: category,
          amount: entry.value,
          percentChangeFromLastMonth: percentChange,
        ),
      );
    }

    spending.sort((a, b) => b.amount.compareTo(a.amount));
    return spending;
  }

  List<MonthlyCashFlow> _buildMonthlyCashFlow(
    List<Transaction> transactions,
    DateTime now,
  ) {
    final months = List.generate(
      _trailingMonths,
      (i) => DateTime(now.year, now.month - (_trailingMonths - 1) + i),
    );

    final incomeByMonth = {for (final m in months) m: 0};
    final expenseByMonth = {for (final m in months) m: 0};

    for (final t in transactions) {
      final date = DateTime.parse(t.date);
      final bucket = DateTime(date.year, date.month);
      if (!incomeByMonth.containsKey(bucket)) continue;

      if (t.type == TransactionType.income) {
        incomeByMonth[bucket] = incomeByMonth[bucket]! + t.amount;
      } else {
        expenseByMonth[bucket] = expenseByMonth[bucket]! + t.amount;
      }
    }

    return months
        .map(
          (m) => MonthlyCashFlow(
            month: m,
            income: incomeByMonth[m]!,
            expense: expenseByMonth[m]!,
          ),
        )
        .toList();
  }
}
