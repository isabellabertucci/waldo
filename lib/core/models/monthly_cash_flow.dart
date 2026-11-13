import 'package:freezed_annotation/freezed_annotation.dart';

part 'monthly_cash_flow.freezed.dart';

/// A month's income and expense, in cents: one point of the cash flow chart.
@freezed
abstract class MonthlyCashFlow with _$MonthlyCashFlow {
  const factory MonthlyCashFlow({
    required DateTime month,
    required int income,
    required int expense,
  }) = _MonthlyCashFlow;
}
