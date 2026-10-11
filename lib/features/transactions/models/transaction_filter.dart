import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:waldo/core/constants/enums.dart';

import 'transaction.dart';

part 'transaction_filter.freezed.dart';

/// Which transactions the wallet's list shows: one calendar month (day and
/// time ignored) and optionally one type (null = income and expense).
@freezed
abstract class TransactionFilter with _$TransactionFilter {
  const TransactionFilter._();

  const factory TransactionFilter({
    required DateTime month,
    TransactionType? type,
  }) = _TransactionFilter;

  bool matches(Transaction transaction) {
    final date = DateTime.parse(transaction.date);
    if (date.year != month.year || date.month != month.month) return false;
    return type == null || transaction.type == type;
  }
}
