import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:waldo/core/models/monthly_cash_flow.dart';
import 'package:waldo/features/categories/models/category.dart';
import 'package:waldo/features/transactions/models/transaction.dart';

// Part of [DashboardData], so whoever reads it gets the type too.
export 'package:waldo/core/models/monthly_cash_flow.dart';

part 'dashboard_data.freezed.dart';

@freezed
abstract class CategorySpending with _$CategorySpending {
  const factory CategorySpending({
    required Category category,
    required int amount,
  }) = _CategorySpending;
}

@freezed
abstract class DashboardData with _$DashboardData {
  const factory DashboardData({
    /// The month these figures are for: while the next month loads, the
    /// screen still shows this one.
    required DateTime month,
    required int totalBalance,
    required int walletCount,
    required int monthlyIncome,
    required int monthlyExpense,
    required List<MonthlyCashFlow> monthlyCashFlow,
    required List<Transaction> recentTransactions,
  }) = _DashboardData;
}
