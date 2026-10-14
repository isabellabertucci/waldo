import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:waldo/features/categories/models/category.dart';
import 'package:waldo/features/transactions/models/transaction.dart';

part 'dashboard_data.freezed.dart';

@freezed
abstract class CategorySpending with _$CategorySpending {
  const factory CategorySpending({
    required Category category,
    required int amount,
  }) = _CategorySpending;
}

@freezed
abstract class MonthlyCashFlow with _$MonthlyCashFlow {
  const factory MonthlyCashFlow({
    required DateTime month,
    required int income,
    required int expense,
  }) = _MonthlyCashFlow;
}

@freezed
abstract class DashboardData with _$DashboardData {
  const factory DashboardData({
    required int totalBalance,
    required int walletCount,
    required int monthlyIncome,
    required int monthlyExpense,
    required List<CategorySpending> spendingByCategory,
    // Expenses this month with no category (never set, or the category was
    // deleted) - so the receipt's category lines always add up to EXPENSE.
    required int uncategorizedSpending,
    required List<MonthlyCashFlow> monthlyCashFlow,
    required List<Transaction> recentTransactions,
  }) = _DashboardData;
}
