import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:waldo/core/constants/enums.dart';
import 'package:waldo/core/router/app_router.dart';
import 'package:waldo/core/theme/app_theme.dart';
import 'package:waldo/core/theme/spacing.dart';
import 'package:waldo/core/widgets/empty_state.dart';
import 'package:waldo/features/transactions/models/transaction.dart';
import 'package:waldo/features/transactions/ui/widgets/transaction_list_tile.dart';
import 'package:waldo/l10n/app_localizations.dart';

class RecentTransactionsList extends StatelessWidget {
  const RecentTransactionsList({
    super.key,
    required this.transactions,
    required this.currency,
    required this.dateFormat,
  });

  final List<Transaction> transactions;
  final Currency currency;
  final DateFormat dateFormat;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  l10n.recentTransactions,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: Spacing.sm),
              GestureDetector(
                // No wallet-agnostic transactions route exists yet (each
                // TransactionsRoute needs a walletId), so this is a
                // temporary landing spot until the nav restructuring
                // flagged in the epic promotes Transactions to a tab.
                onTap: () => const WalletsRoute().push(context),
                child: Text(
                  l10n.seeAll,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: context.appColors.primaryStrong,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: Spacing.sm),
        if (transactions.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: Spacing.lg),
            child: EmptyState(
              icon: Icons.receipt_long_outlined,
              title: l10n.noRecentTransactions,
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
            itemCount: transactions.length,
            separatorBuilder: (context, index) =>
                const SizedBox(height: Spacing.md),
            itemBuilder: (context, index) {
              final transaction = transactions[index];
              return TransactionListTile(
                transaction: transaction,
                currency: currency,
                dateFormat: dateFormat,
                onTap: () {
                  TransactionDetailRoute(
                    transaction.walletId,
                    transaction.id!,
                  ).push(context);
                },
              );
            },
          ),
      ],
    );
  }
}
