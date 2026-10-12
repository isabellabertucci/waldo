import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:waldo/core/constants/enums.dart';
import 'package:waldo/core/router/app_router.dart';
import 'package:waldo/core/theme/app_theme.dart';
import 'package:waldo/core/theme/spacing.dart';
import 'package:waldo/core/widgets/secondary_button.dart';
import 'package:waldo/core/widgets/transaction_row.dart';
import 'package:waldo/features/categories/models/category.dart';
import 'package:waldo/features/categories/viewmodels/category_list_view_model.dart';
import 'package:waldo/features/transactions/models/transaction.dart';
import 'package:waldo/features/transactions/ui/widgets/transaction_edit_sheet.dart';
import 'package:waldo/l10n/app_localizations.dart';

class RecentTransactionsList extends ConsumerWidget {
  const RecentTransactionsList({
    super.key,
    required this.transactions,
    required this.currency,
    required this.dateFormat,
    required this.isBalanceHidden,
  });

  final List<Transaction> transactions;
  final Currency currency;
  final DateFormat dateFormat;
  final bool isBalanceHidden;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final categoriesAsync = ref.watch(categoryListViewModelProvider);
    final categoriesById = switch (categoriesAsync) {
      AsyncValue(:final value?) => {
        for (final c in value)
          if (c.id != null) c.id!: c,
      },
      _ => const <int, Category>{},
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Spacing.pageMargin),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  l10n.recentTransactions,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.headlineMdStrong,
                ),
              ),
              const SizedBox(width: Spacing.sm),
              SecondaryButton(
                label: l10n.seeAll,
                onPressed: () => const AllTransactionsRoute().push(context),
              ),
            ],
          ),
        ),
        const SizedBox(height: Spacing.sm),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Spacing.pageMargin),
          child: TransactionGroupCard(
            transactions: transactions,
            currency: currency,
            dateFormat: dateFormat,
            categoriesById: categoriesById,
            isAmountHidden: isBalanceHidden,
            onTapTransaction: (transaction) =>
                showTransactionEditSheet(context, transaction: transaction),
          ),
        ),
      ],
    );
  }
}
