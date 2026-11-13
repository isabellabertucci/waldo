import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:waldo/core/constants/enums.dart';
import 'package:waldo/core/theme/app_theme.dart';
import 'package:waldo/core/theme/spacing.dart';
import 'package:waldo/features/categories/models/category.dart';
import 'package:waldo/l10n/app_localizations.dart';
import 'package:waldo/core/widgets/heading.dart';

import '../../models/transaction.dart';
import 'transaction_row.dart';

/// Transactions grouped by day (Today, Yesterday, Thu 8 Oct), each day's
/// [TransactionRows] under it, and how to edit one at the end, as the
/// wallets list has. Keeps the order it's given (newest first).
class DayGroupedTransactionList extends StatelessWidget {
  const DayGroupedTransactionList({
    super.key,
    required this.transactions,
    required this.categoriesById,
    required this.currency,
    required this.now,
    this.isAmountHidden = false,
    this.padding = const EdgeInsets.all(Spacing.pageMargin),
    this.header,
    this.inPage = false,
  });

  final List<Transaction> transactions;
  final Map<int, Category> categoriesById;
  final Currency currency;

  /// Decides which day reads "Today" and "Yesterday".
  final DateTime now;
  final bool isAmountHidden;
  final EdgeInsetsGeometry padding;

  /// Scrolls with the days, above them and outside [padding].
  final Widget? header;

  /// Part of a page that scrolls (a wallet's sheet), so the list takes its
  /// full height and doesn't scroll on its own.
  final bool inPage;

  Map<DateTime, List<Transaction>> _groupByDay() {
    final groups = <DateTime, List<Transaction>>{};
    for (final t in transactions) {
      final date = DateTime.parse(t.date);
      final day = DateTime(date.year, date.month, date.day);
      groups.putIfAbsent(day, () => []).add(t);
    }
    return groups;
  }

  String _dayLabel(AppLocalizations l10n, String locale, DateTime day) {
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    if (day == today) return l10n.transactionsGroupToday.toUpperCase();
    if (day == yesterday) return l10n.transactionsGroupYesterday.toUpperCase();
    return DateFormat('EEE d MMM', locale).format(day).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.appColors;
    final locale = Localizations.localeOf(context).toString();
    final groups = _groupByDay();
    final days = groups.keys.toList();

    final list = SliverList.builder(
      itemCount: days.length,
      itemBuilder: (context, index) {
        final day = days[index];

        return Padding(
          padding: const EdgeInsets.only(bottom: Spacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // As the wallets list's groups are headed.
              Heading(
                child: Text(
                  _dayLabel(l10n, locale, day),
                  style: context.overline.copyWith(color: colors.inkMuted),
                ),
              ),
              TransactionRows(
                transactions: groups[day]!,
                categoriesById: categoriesById,
                currency: currency,
                isAmountHidden: isAmountHidden,
              ),
            ],
          ),
        );
      },
    );

    // What ListView.builder builds, with room for a header above the padding.
    return CustomScrollView(
      semanticChildCount: days.length,
      shrinkWrap: inPage,
      physics: inPage ? const NeverScrollableScrollPhysics() : null,
      slivers: [
        if (header case final header?) SliverToBoxAdapter(child: header),
        SliverPadding(
          padding: padding,
          sliver: SliverMainAxisGroup(
            slivers: [
              list,
              SliverToBoxAdapter(
                child: Text(
                  l10n.transactionRowHint,
                  textAlign: TextAlign.center,
                  style: context.label.copyWith(color: colors.inkMuted),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
