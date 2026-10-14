import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:waldo/core/constants/enums.dart';
import 'package:waldo/core/router/app_router.dart';
import 'package:waldo/core/theme/app_theme.dart';
import 'package:waldo/core/theme/rounded.dart';
import 'package:waldo/core/theme/spacing.dart';
import 'package:waldo/core/widgets/surface_card.dart';
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
              Semantics(
                button: true,
                child: InkWell(
                  borderRadius: BorderRadius.circular(Rounded.pill),
                  onTap: () => const AllTransactionsRoute().push(context),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Spacing.xxs,
                      vertical: Spacing.xs,
                    ),
                    child: Text(
                      l10n.seeAll,
                      style: context.bodyMdStrong.copyWith(
                        color: context.appColors.primaryStrong,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: Spacing.sm),
        if (transactions.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Spacing.pageMargin),
            child: _EmptyTransactionsCard(caption: l10n.noRecentTransactions),
          )
        else
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

/// Mirrors the "show the shape" ghost-card treatment used for the category
/// spending empty state - no CTA here, since "Add first transaction" already
/// lives higher up on the page.
class _EmptyTransactionsCard extends StatelessWidget {
  const _EmptyTransactionsCard({required this.caption});

  final String caption;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SurfaceCard(
          child: Column(
            children: [
              const _GhostTransactionRow(opacity: 1),
              Container(
                height: 1,
                margin: const EdgeInsets.symmetric(horizontal: Spacing.md),
                color: colors.onSurfaceVariant.withValues(alpha: 0.1),
              ),
              const _GhostTransactionRow(opacity: 0.6),
            ],
          ),
        ),
        const SizedBox(height: Spacing.sm),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Spacing.xs),
          child: Text(
            caption,
            style: context.textTheme.bodySmall?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}

class _GhostTransactionRow extends StatelessWidget {
  const _GhostTransactionRow({required this.opacity});

  final double opacity;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Opacity(
      opacity: opacity,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.md,
          vertical: Spacing.sm,
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: colors.onSurfaceVariant.withValues(alpha: 0.4),
                  width: 1.5,
                ),
              ),
            ),
            const SizedBox(width: Spacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: Spacing.xs,
                children: [
                  _GhostBar(widthFactor: 0.55, color: colors.onSurfaceVariant),
                  _GhostBar(widthFactor: 0.35, color: colors.onSurfaceVariant),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GhostBar extends StatelessWidget {
  const _GhostBar({required this.widthFactor, required this.color});

  final double widthFactor;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: widthFactor,
      alignment: Alignment.centerLeft,
      child: Container(
        height: 10,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          // A skeleton-placeholder pill, not a real component radius - sits
          // below `Rounded.sm` (12) on purpose, so it reads as a thin text
          // bar rather than a small card.
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }
}
