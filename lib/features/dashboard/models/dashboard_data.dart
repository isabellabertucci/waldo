import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:waldo/features/categories/models/category.dart';
import 'package:waldo/features/transactions/models/transaction.dart';

part 'dashboard_data.freezed.dart';

@freezed
abstract class CategorySpending with _$CategorySpending {
  const factory CategorySpending({
    required Category category,
    required int amount,
    // null when there was no spending in this category last month, so a
    // percentage change can't be computed (would be a divide-by-zero).
    required double? percentChangeFromLastMonth,
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
    required int monthlyIncome,
    required int monthlyExpense,
    required List<CategorySpending> spendingByCategory,
    required List<MonthlyCashFlow> monthlyCashFlow,
    required List<Transaction> recentTransactions,
  }) = _DashboardData;
}
