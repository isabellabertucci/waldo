import 'package:flutter/material.dart';
import 'package:waldo/core/widgets/balance_amount.dart';
import 'package:waldo/core/widgets/whole_words_text.dart';
import 'package:waldo/core/constants/enums.dart';
import 'package:waldo/core/theme/app_icons.dart';
import 'package:waldo/core/theme/app_theme.dart';
import 'package:waldo/core/theme/badge_size.dart';
import 'package:waldo/core/theme/dynamic_type_scaler.dart';
import 'package:waldo/core/theme/icon_size.dart';
import 'package:waldo/core/theme/spacing.dart';
import 'package:waldo/core/utils/utils.dart';
import 'package:waldo/core/widgets/badge_row.dart';
import 'package:waldo/core/widgets/option_sheet.dart';
import 'package:waldo/features/categories/categories_x.dart';
import 'package:waldo/features/categories/models/category.dart';
import 'package:waldo/l10n/app_localizations.dart';

import '../../models/transaction.dart';
import 'transaction_edit_sheet.dart';

/// One transaction, as a wallet row is: category icon, description over
/// category, signed amount and a chevron. A tap opens it read-only; a long
/// press edits or deletes it.
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

  void _showActions(BuildContext context, String title) {
    final l10n = AppLocalizations.of(context);
    showActionSheet(
      context,
      title: title,
      actions: [
        (
          icon: AppIcons.edit,
          label: l10n.edit,
          onTap: () => showTransactionEditSheet(
            context,
            transaction: transaction,
            startInEditMode: true,
          ),
        ),
        (
          icon: AppIcons.delete,
          label: l10n.delete,
          onTap: () => deleteTransactionWithUndo(context, transaction),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.appColors;
    final muted = colors.inkMuted;
    final isIncome = transaction.type == TransactionType.income;
    final amountColor = isIncome ? colors.positive : colors.negative;
    final sign = isIncome ? '+' : '-';
    final description = transaction.description?.trim();
    final title = description == null || description.isEmpty
        ? l10n.transactionDefaultDescription
        : description;
    final categoryLabel = category?.displayName(l10n);
    final amountText =
        '$sign${formatCents(transaction.amount, locale: moneyLocale(context), currencyCode: currency.code)}';
    final amountStyle = context.amountRow.copyWith(color: amountColor);
    final referenceAmount =
        '-${formatCents(_referenceAmountCents, locale: moneyLocale(context), currencyCode: currency.code)}';
    final disc = Container(
      width: BadgeSize.md,
      height: BadgeSize.md,
      decoration: BoxDecoration(color: colors.card, shape: BoxShape.circle),
      child: Icon(
        category?.icon ?? AppIcons.receipt,
        size: IconSize.md,
        color: colors.ink,
      ),
    );

    // A button to screen readers; a bare InkWell is read as plain text.
    return Semantics(
      button: true,
      onLongPressHint: l10n.transactionActionsHint,
      child: InkWell(
        // A plain tap opens a read-only view; only Edit, from the long
        // press, opens it editable.
        onTap: () =>
            showTransactionEditSheet(context, transaction: transaction),
        onLongPress: () => _showActions(context, title),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: Spacing.component),
          child: BadgeRow(
            badge: disc,
            trailing: Icon(
              AppIcons.chevronRight,
              size: IconSize.md,
              color: muted,
            ),
            // The amount stays on the right while the description keeps at
            // least as much room as a typical amount; with large text it moves
            // under it. Measuring a fixed amount, not this row's, keeps every
            // row in a list on the same layout.
            child: LayoutBuilder(
              builder: (context, constraints) {
                final painter = TextPainter(
                  text: TextSpan(text: referenceAmount, style: amountStyle),
                  textScaler: MediaQuery.textScalerOf(context),
                  textDirection: Directionality.of(context),
                  maxLines: 1,
                )..layout();
                final stacked =
                    DynamicTypeScaler.isAccessibilitySize(context) ||
                    painter.width * 2 > constraints.maxWidth;
                painter.dispose();
                final amount = BalanceAmount(
                  amount: amountText,
                  hidden: isAmountHidden,
                  style: amountStyle,
                  alignment: stacked
                      ? AlignmentDirectional.centerStart
                      : AlignmentDirectional.centerEnd,
                );

                final texts = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    WholeWordsText.singleLine(title, style: context.bodyStrong),
                    WholeWordsText(
                      categoryLabel ?? l10n.uncategorized,
                      style: context.label.copyWith(color: muted),
                    ),
                    // A whole amount shrinks rather than being cut.
                    if (stacked)
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: AlignmentDirectional.centerStart,
                        child: amount,
                      ),
                  ],
                );
                if (stacked) return texts;
                return Row(
                  children: [
                    Expanded(child: texts),
                    // So a cut title never touches the amount.
                    const SizedBox(width: Spacing.sm),
                    amount,
                    const SizedBox(width: Spacing.xs),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

/// 999,99: a typical large amount, for deciding where amounts go.
const _referenceAmountCents = 99999;

/// [TransactionRow]s straight on the sheet, hairlines between them, as the
/// wallets list is.
class TransactionRows extends StatelessWidget {
  const TransactionRows({
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

    return Column(
      children: [
        for (final (i, transaction) in transactions.indexed) ...[
          if (i > 0) Divider(height: 1, color: colors.divider),
          TransactionRow(
            transaction: transaction,
            category: categoriesById[transaction.categoryId],
            currency: currency,
            isAmountHidden: isAmountHidden,
          ),
        ],
      ],
    );
  }
}
