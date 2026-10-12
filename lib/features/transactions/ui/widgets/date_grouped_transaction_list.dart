import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:waldo/core/constants/enums.dart';
import 'package:waldo/core/theme/app_theme.dart';
import 'package:waldo/core/theme/spacing.dart';
import 'package:waldo/core/widgets/transaction_row.dart';

import '../../models/transaction.dart';

/// Transactions grouped by month, each month in its own card.
class DateGroupedTransactionList extends StatelessWidget {
  const DateGroupedTransactionList({
    super.key,
    required this.transactions,
    required this.currency,
    required this.dateFormat,
    required this.onTapTransaction,
    this.isAmountHidden = false,
    this.padding = const EdgeInsets.symmetric(
      horizontal: Spacing.pageMargin,
      vertical: Spacing.md,
    ),
  });

  final List<Transaction> transactions;
  final Currency currency;
  final DateFormat dateFormat;
  final ValueChanged<Transaction> onTapTransaction;
  final bool isAmountHidden;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).toString();
    final monthFormat = DateFormat.yMMMM(locale);
    final groups = _groupByMonth(transactions);

    return ListView(
      padding: padding,
      children: [
        for (var i = 0; i < groups.length; i++) ...[
          Text(
            monthFormat.format(groups[i].month).toUpperCase(),
            style: context.labelXs.copyWith(
              color: context.appColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: Spacing.xs),
          TransactionGroupCard(
            transactions: groups[i].transactions,
            currency: currency,
            dateFormat: dateFormat,
            onTapTransaction: onTapTransaction,
            isAmountHidden: isAmountHidden,
          ),
          if (i != groups.length - 1) const SizedBox(height: Spacing.md),
        ],
      ],
    );
  }
}

class _MonthGroup {
  _MonthGroup(this.month, this.transactions);

  final DateTime month;
  final List<Transaction> transactions;
}

/// Buckets transactions by calendar month, preserving their existing order
/// (callers already sort desc by date) rather than re-sorting.
List<_MonthGroup> _groupByMonth(List<Transaction> transactions) {
  final groups = <_MonthGroup>[];
  for (final transaction in transactions) {
    final date = DateTime.parse(transaction.date);
    final month = DateTime(date.year, date.month);
    if (groups.isNotEmpty && groups.last.month == month) {
      groups.last.transactions.add(transaction);
    } else {
      groups.add(_MonthGroup(month, [transaction]));
    }
  }
  return groups;
}
