import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:waldo/core/constants/enums.dart';
import 'package:waldo/core/theme/app_icons.dart';
import 'package:waldo/core/theme/app_theme.dart';
import 'package:waldo/core/theme/icon_size.dart';
import 'package:waldo/core/theme/spacing.dart';
import 'package:waldo/core/utils/utils.dart';
import 'package:waldo/core/widgets/surface_card.dart';
import 'package:waldo/features/categories/categories_x.dart';
import 'package:waldo/features/categories/models/category.dart';
import 'package:waldo/features/transactions/models/transaction.dart';
import 'package:waldo/l10n/app_localizations.dart';

/// One transaction row: icon, description/date and a signed amount.
/// Shows the category icon when [category] is given, else an income/expense arrow.
class TransactionRow extends StatelessWidget {
  const TransactionRow({
    super.key,
    required this.transaction,
    required this.currency,
    required this.dateFormat,
    required this.onTap,
    this.category,
    this.isAmountHidden = false,
  });

  final Transaction transaction;
  final Currency currency;
  final DateFormat dateFormat;
  final VoidCallback onTap;
  final Category? category;

  /// Shows [hiddenAmount] instead of the figure (the eye toggle).
  final bool isAmountHidden;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.appColors;
    final isIncome = transaction.type == TransactionType.income;
    final color = isIncome ? colors.primaryStrong : colors.error;
    final sign = isIncome ? '+' : '-';
    final description = transaction.description?.trim();
    final category = this.category;

    return InkWell(
      onTap: onTap,
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
                color: category != null
                    ? colors.onSurface.withValues(alpha: 0.06)
                    : color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                category != null
                    ? category.icon
                    : (isIncome ? AppIcons.income : AppIcons.expense),
                size: IconSize.md,
                color: category != null ? colors.onSurface : color,
              ),
            ),
            const SizedBox(width: Spacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    description == null || description.isEmpty
                        ? l10n.transactionDefaultDescription
                        : description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.bodyMdStrong,
                  ),
                  Text(
                    dateFormat.format(DateTime.parse(transaction.date)),
                    style: context.textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              isAmountHidden
                  ? hiddenAmount
                  : '$sign${formatCents(transaction.amount, locale: moneyLocale(context), currencyCode: currency.code)}',
              style: context.labelLgStrong.copyWith(color: color),
            ),
          ],
        ),
      ),
    );
  }
}

/// A [SurfaceCard] of [TransactionRow]s with hairline dividers.
class TransactionGroupCard extends StatelessWidget {
  const TransactionGroupCard({
    super.key,
    required this.transactions,
    required this.currency,
    required this.dateFormat,
    required this.onTapTransaction,
    this.categoriesById,
    this.isAmountHidden = false,
  });

  final List<Transaction> transactions;
  final Currency currency;
  final DateFormat dateFormat;
  final ValueChanged<Transaction> onTapTransaction;
  final Map<int, Category>? categoriesById;
  final bool isAmountHidden;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return SurfaceCard(
      child: Column(
        children: [
          for (var i = 0; i < transactions.length; i++) ...[
            TransactionRow(
              transaction: transactions[i],
              currency: currency,
              dateFormat: dateFormat,
              category: categoriesById?[transactions[i].categoryId],
              isAmountHidden: isAmountHidden,
              onTap: () => onTapTransaction(transactions[i]),
            ),
            if (i != transactions.length - 1)
              Container(
                height: 1,
                margin: const EdgeInsets.symmetric(horizontal: Spacing.md),
                color: colors.onSurfaceVariant.withValues(alpha: 0.1),
              ),
          ],
        ],
      ),
    );
  }
}
