import 'package:flutter/material.dart';
import 'package:waldo/core/constants/enums.dart';
import 'package:waldo/core/theme/app_icons.dart';
import 'package:waldo/core/theme/app_theme.dart';
import 'package:waldo/core/theme/badge_size.dart';
import 'package:waldo/core/theme/icon_size.dart';
import 'package:waldo/core/theme/rounded.dart';
import 'package:waldo/core/theme/spacing.dart';
import 'package:waldo/core/utils/utils.dart';
import 'package:waldo/features/categories/categories_x.dart';
import 'package:waldo/features/categories/models/category.dart';
import 'package:waldo/l10n/app_localizations.dart';

import '../../models/transaction.dart';
import 'transaction_edit_sheet.dart';

/// One transaction: category icon, description over category, signed amount
/// and a "⋯" menu. Tapping opens it read-only; the menu edits or deletes.
class TransactionRow extends StatelessWidget {
  const TransactionRow({
    super.key,
    required this.transaction,
    required this.category,
    required this.currency,
    this.isAmountHidden = false,
  });

  final Transaction transaction;
  final Category? category;
  final Currency currency;

  /// Shows [hiddenAmount] instead of the figure (the eye toggle).
  final bool isAmountHidden;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.appColors;
    final isIncome = transaction.type == TransactionType.income;
    final amountColor = isIncome ? colors.primaryStrong : colors.error;
    final sign = isIncome ? '+' : '-';
    final description = transaction.description?.trim();
    final categoryLabel = category?.displayName(l10n);
    final amountText = isAmountHidden
        ? hiddenAmount
        : '$sign${formatCents(transaction.amount, locale: moneyLocale(context), currencyCode: currency.code)}';
    final amountStyle = context.bodyMdBold.copyWith(color: amountColor);
    final referenceAmount =
        '-${formatCents(_referenceAmountCents, locale: moneyLocale(context), currencyCode: currency.code)}';

    // A button to screen readers; a bare InkWell is read as plain text.
    return Semantics(
      button: true,
      child: InkWell(
        // A plain tap opens a read-only view - only the "⋯" menu's Edit
        // action opens it editable, so chevrons never appear by accident.
        onTap: () =>
            showTransactionEditSheet(context, transaction: transaction),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.sm,
            vertical: Spacing.sm,
          ),
          child: Row(
            children: [
              Container(
                width: BadgeSize.md,
                height: BadgeSize.md,
                decoration: BoxDecoration(
                  color: colors.onSurface.withValues(alpha: 0.06),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  category?.icon ?? AppIcons.receipt,
                  size: IconSize.md,
                  color: colors.onSurface,
                ),
              ),
              const SizedBox(width: Spacing.sm),
              // The amount stays on the right while the description keeps at
              // least as much room as a typical amount; with large text it moves
              // under it. Measuring a fixed amount, not this row's, keeps every
              // row in a list on the same layout.
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final amount = Text(
                      amountText,
                      maxLines: 1,
                      style: amountStyle,
                    );
                    final painter = TextPainter(
                      text: TextSpan(text: referenceAmount, style: amountStyle),
                      textScaler: MediaQuery.textScalerOf(context),
                      textDirection: Directionality.of(context),
                      maxLines: 1,
                    )..layout();
                    final stacked = painter.width * 2 > constraints.maxWidth;
                    painter.dispose();

                    final texts = Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          description == null || description.isEmpty
                              ? l10n.transactionDefaultDescription
                              : description,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.bodyMdBold,
                        ),
                        Text(
                          categoryLabel ?? l10n.uncategorized,
                          style: context.textTheme.bodySmall?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                        if (stacked) amount,
                      ],
                    );
                    if (stacked) return texts;
                    return Row(
                      children: [
                        Expanded(child: texts),
                        amount,
                      ],
                    );
                  },
                ),
              ),
              PopupMenuButton<_RowAction>(
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(Rounded.md),
                ),
                icon: Icon(
                  AppIcons.more,
                  size: IconSize.lg,
                  color: colors.onSurfaceVariant,
                ),
                onSelected: (action) {
                  switch (action) {
                    case _RowAction.edit:
                      showTransactionEditSheet(
                        context,
                        transaction: transaction,
                        startInEditMode: true,
                      );
                    case _RowAction.delete:
                      deleteTransactionWithUndo(context, transaction);
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: _RowAction.edit,
                    child: Row(
                      children: [
                        const Icon(AppIcons.edit, size: IconSize.lg),
                        const SizedBox(width: Spacing.xs),
                        Text(l10n.edit),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: _RowAction.delete,
                    child: Row(
                      children: [
                        Icon(
                          AppIcons.delete,
                          size: IconSize.lg,
                          color: colors.error,
                        ),
                        const SizedBox(width: Spacing.xs),
                        Text(
                          l10n.delete,
                          style: TextStyle(color: colors.error),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum _RowAction { edit, delete }

/// 999,99: a typical large amount, for deciding where amounts go.
const _referenceAmountCents = 99999;

/// A card of [TransactionRow]s, with hairlines that start under the text.
class TransactionCard extends StatelessWidget {
  const TransactionCard({
    super.key,
    required this.transactions,
    required this.categoriesById,
    required this.currency,
    this.isAmountHidden = false,
  });

  final List<Transaction> transactions;
  final Map<int, Category> categoriesById;
  final Currency currency;
  final bool isAmountHidden;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(Rounded.md),
      ),
      child: Column(
        children: [
          for (var i = 0; i < transactions.length; i++) ...[
            TransactionRow(
              transaction: transactions[i],
              category: categoriesById[transactions[i].categoryId],
              currency: currency,
              isAmountHidden: isAmountHidden,
            ),
            if (i < transactions.length - 1)
              Divider(
                height: 1,
                indent: Spacing.sm + BadgeSize.md + Spacing.sm,
                endIndent: Spacing.sm,
                color: colors.onSurfaceVariant.withValues(alpha: 0.1),
              ),
          ],
        ],
      ),
    );
  }
}
