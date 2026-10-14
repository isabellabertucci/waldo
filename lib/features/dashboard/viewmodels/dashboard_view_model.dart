import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:waldo/core/constants/enums.dart';
import 'package:waldo/core/utils/clock.dart';
import 'package:waldo/features/categories/models/category.dart';
import 'package:waldo/features/categories/repositories/category_repository.dart';
import 'package:waldo/features/transactions/models/transaction.dart';
import 'package:waldo/features/transactions/repositories/transaction_repository.dart';
import 'package:waldo/features/transactions/viewmodels/pending_transaction_deletes.dart';
import 'package:waldo/features/wallets/repositories/wallet_repository.dart';

import '../models/dashboard_data.dart';

part 'dashboard_view_model.g.dart';

const _trailingMonths = 12;
const _recentTransactionsLimit = 5;

/// The month the dashboard is currently showing stats for. Defaults to the
/// current month; changeable via the month picker in the dashboard's app bar.
@riverpod
class SelectedDashboardMonth extends _$SelectedDashboardMonth {
  @override
  DateTime build() {
    final now = ref.watch(clockProvider)();
    return DateTime(now.year, now.month);
  }

  void select(DateTime month) => state = DateTime(month.year, month.month);
}

@riverpod
class DashboardViewModel extends _$DashboardViewModel {
  @override
  Future<DashboardData> build() async {
    final walletRepo = await ref.watch(walletRepositoryProvider.future);
    final transactionRepo = await ref.watch(
      transactionRepositoryProvider.future,
    );
    final categoryRepo = await ref.watch(categoryRepositoryProvider.future);
    final anchor = ref.watch(selectedDashboardMonthProvider);

    final totalBalance = await walletRepo.getTotalBalance();
    final walletCount = await walletRepo.getCount();
    final pending = ref.watch(pendingTransactionDeletesProvider);
    // Deletes still inside their Undo window are already gone from the month.
    final transactions = (await transactionRepo.getAll())
        .where((t) => !pending.contains(t.id))
        .toList();
    final categories = await categoryRepo.getAll();

    final currentMonthTransactions = _transactionsInMonth(
      transactions,
      anchor.year,
      anchor.month,
    );

    final monthlyIncome = _sumByType(
      currentMonthTransactions,
      TransactionType.income,
    );
    final monthlyExpense = _sumByType(
      currentMonthTransactions,
      TransactionType.expense,
    );

    final spendingByCategory = _buildSpendingByCategory(
      currentMonthTransactions,
      categories,
    );
    final categorizedTotal = spendingByCategory.fold<int>(
      0,
      (sum, s) => sum + s.amount,
    );

    return DashboardData(
      totalBalance: totalBalance,
      walletCount: walletCount,
      monthlyIncome: monthlyIncome,
      monthlyExpense: monthlyExpense,
      spendingByCategory: spendingByCategory,
      uncategorizedSpending: monthlyExpense - categorizedTotal,
      monthlyCashFlow: _buildMonthlyCashFlow(transactions, anchor),
      // Already sorted newest first, so these are the month's most recent.
      recentTransactions: currentMonthTransactions
          .take(_recentTransactionsLimit)
          .toList(),
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
    List<Category> categories,
  ) {
    final currentTotals = _expenseTotalsByCategory(currentMonthTransactions);
    final categoriesById = {for (final c in categories) c.id: c};

    final spending = <CategorySpending>[];
    for (final entry in currentTotals.entries) {
      final category = categoriesById[entry.key];
      if (category == null) continue;

      spending.add(CategorySpending(category: category, amount: entry.value));
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
