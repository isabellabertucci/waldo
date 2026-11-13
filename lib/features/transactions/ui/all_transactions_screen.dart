import 'package:flutter/material.dart';
import 'package:waldo/core/widgets/ghost.dart';
import 'package:waldo/core/theme/spacing.dart';
import 'package:waldo/core/widgets/hide_amounts_button.dart';
import 'package:waldo/core/widgets/load_error.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:waldo/core/theme/app_icons.dart';
import 'package:waldo/core/constants/enums.dart';
import 'package:waldo/core/theme/app_theme.dart';
import 'package:waldo/core/theme/icon_size.dart';
import 'package:waldo/core/widgets/circle_icon_button.dart';
import 'package:waldo/core/widgets/heading.dart';
import 'package:waldo/core/widgets/sheet_page.dart';
import 'package:waldo/core/widgets/empty_state.dart';
import 'package:waldo/features/preferences/viewmodels/balance_hidden_view_model.dart';
import 'package:waldo/features/preferences/viewmodels/preferences_viewmodel.dart';
import 'package:waldo/core/utils/clock.dart';
import 'package:waldo/features/categories/viewmodels/category_list_view_model.dart';
import 'package:waldo/l10n/app_localizations.dart';

import '../models/transaction.dart';
import '../viewmodels/transaction_list_view_model.dart';
import 'widgets/day_grouped_transaction_list.dart';

class AllTransactionsScreen extends ConsumerWidget {
  const AllTransactionsScreen({super.key, this.month});

  /// Only this month's transactions, when set.
  final DateTime? month;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final month = this.month;
    final transactionsAsync = ref.watch(transactionListViewModelProvider());
    final isBalanceHidden = ref.watch(balanceHiddenProvider);

    final title = month == null
        ? l10n.transactions
        : l10n.transactionsInMonth(DateFormat.yMMMM(locale).format(month));
    final colors = context.appColors;
    final back = CircleIconButton(
      flat: true,
      tint: colors.chip,
      tooltip: l10n.back,
      onPressed: () => Navigator.of(context).pop(),
      child: const Icon(AppIcons.back, size: IconSize.lg),
    );
    final eye = HideAmountsButton(
      hidden: isBalanceHidden,
      onPressed: () => ref.read(balanceHiddenProvider.notifier).toggle(),
    );

    // As Categories: back over the title on the beige top, the list on the
    // white sheet; once the title scrolls away, the slim bar keeps back and
    // the eye in reach (DESIGN.md "All transactions").
    return Scaffold(
      body: SheetPage(
        bar: SheetPageBar(title: title, leading: back, trailing: eye),
        top: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            back,
            const SizedBox(height: Spacing.md),
            Row(
              children: [
                Expanded(
                  child: Heading(child: Text(title, style: context.titlePage)),
                ),
                const SizedBox(width: Spacing.sm),
                eye,
              ],
            ),
          ],
        ),
        sheet: Padding(
          padding: const EdgeInsets.symmetric(horizontal: Spacing.pageMargin),
          child: switch (transactionsAsync) {
            AsyncValue(:final value?) => _AllTransactionsBody(
              transactions: month == null
                  ? value
                  : [
                      for (final t in value)
                        if (_isIn(DateTime.parse(t.date), month)) t,
                    ],
              isFiltered: month != null,
            ),
            AsyncValue(hasError: true) => LoadError(
              message: l10n.transactionsError,
              onRetry: () => ref.invalidate(transactionListViewModelProvider),
            ),
            _ => const Padding(
              padding: EdgeInsets.all(Spacing.lg),
              child: Center(child: CircularProgressIndicator()),
            ),
          },
        ),
      ),
    );
  }
}

bool _isIn(DateTime date, DateTime month) =>
    date.year == month.year && date.month == month.month;

class _AllTransactionsBody extends ConsumerWidget {
  const _AllTransactionsBody({
    required this.transactions,
    required this.isFiltered,
  });

  final List<Transaction> transactions;

  /// Shown for one month, so an empty list means none that month.
  final bool isFiltered;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final preferencesAsync = ref.watch(preferencesViewModelProvider);
    final currency = switch (preferencesAsync) {
      AsyncValue(:final value?) => value.currency,
      _ => Currency.usd,
    };
    final categoriesById = ref.watch(categoriesByIdProvider);
    final isBalanceHidden = ref.watch(balanceHiddenProvider);

    if (transactions.isEmpty && isFiltered) {
      return EmptyState(
        icon: AppIcons.receipt,
        title: l10n.noTransactionsForFilter,
      );
    }
    if (transactions.isEmpty) {
      return GhostEmptyState(
        ghost: GhostRows(leading: GhostRows.disc(context)),
        title: l10n.noTransactionsYet,
        body: l10n.addFirstTransaction,
      );
    }

    return DayGroupedTransactionList(
      // Part of the page's one scroll, as in a wallet.
      inPage: true,
      padding: EdgeInsets.zero,
      transactions: transactions,
      categoriesById: categoriesById,
      currency: currency,
      now: ref.watch(clockProvider)(),
      isAmountHidden: isBalanceHidden,
    );
  }
}
