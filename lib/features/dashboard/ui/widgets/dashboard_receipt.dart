import 'package:flutter/material.dart';
import 'package:waldo/core/theme/app_icons.dart';
import 'package:waldo/core/theme/icon_size.dart';
import 'package:waldo/core/constants/enums.dart';
import 'package:waldo/core/theme/app_theme.dart';
import 'package:waldo/core/theme/rounded.dart';
import 'package:waldo/core/theme/spacing.dart';
import 'package:waldo/core/utils/utils.dart';
import 'package:waldo/core/widgets/dashed_border.dart';
import 'package:waldo/core/widgets/receipt_shell.dart';
import 'package:waldo/features/categories/categories_x.dart';
import 'package:waldo/l10n/app_localizations.dart';

import '../../models/dashboard_data.dart';

/// The receipt is narrower than the wallet card above it.
const _receiptWidth = 300.0;

/// Category rows shown before the rest collapse into one "Other" line.
const _maxCategoryRows = 5;

/// This month's income, expense and categories, drawn as a receipt under the
/// balance card. Tapping it opens the full transaction list.
class DashboardReceipt extends StatelessWidget {
  const DashboardReceipt({
    super.key,
    required this.monthLabel,
    required this.year,
    required this.monthlyIncome,
    required this.monthlyExpense,
    required this.spendingByCategory,
    required this.uncategorizedSpending,
    required this.isBalanceHidden,
    required this.currency,
    required this.hasWallets,
    required this.onTap,
    required this.onAddTransaction,
  });

  final String monthLabel;
  final int year;
  final int monthlyIncome;
  final int monthlyExpense;
  final List<CategorySpending> spendingByCategory;
  final int uncategorizedSpending;

  /// Masks every figure on the receipt (the eye toggle is a privacy switch).
  final bool isBalanceHidden;
  final Currency currency;

  /// With no wallet yet, the receipt shows a "comes later" message instead.
  final bool hasWallets;
  final VoidCallback onTap;
  final VoidCallback onAddTransaction;

  @override
  Widget build(BuildContext context) {
    if (!hasWallets) {
      return _NoWalletReceipt(monthLabel: monthLabel, year: year);
    }
    if (monthlyIncome == 0 &&
        monthlyExpense == 0 &&
        spendingByCategory.isEmpty) {
      return _EmptyReceipt(onAddTransaction: onAddTransaction);
    }

    final l10n = AppLocalizations.of(context);
    final colors = context.appColors;
    final currencyCode = currency.code;
    final saved = monthlyIncome - monthlyExpense;
    String amount(String formatted) =>
        isBalanceHidden ? hiddenAmount : formatted;
    final textStyles = context.textTheme;
    final visibleCategories = spendingByCategory
        .take(_maxCategoryRows)
        .toList();
    final otherCategories = spendingByCategory.skip(_maxCategoryRows).toList();
    final otherAmount = otherCategories.fold(0, (sum, c) => sum + c.amount);

    return Center(
      child: SizedBox(
        width: _receiptWidth,
        child: Column(
          children: [
            Material(
              color: colors.surface,
              child: InkWell(
                onTap: onTap,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(22, 20, 22, 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        l10n.dashboardReceiptHeader(
                          monthLabel.toUpperCase(),
                          '$year',
                        ),
                        textAlign: TextAlign.center,
                        // The receipt header's own size and tracking.
                        style: textStyles.bodySmall?.copyWith(
                          fontSize: 11, // one-off
                          letterSpacing: 0.8,
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: Spacing.sm),
                      DashedDivider(color: colors.onSurface),
                      const SizedBox(height: Spacing.sm),
                      ReceiptRow(
                        textStyles: textStyles,
                        label: l10n.transactionTypeIncome.toUpperCase(),
                        value: amount(
                          '+${formatCents(monthlyIncome, locale: moneyLocale(context), currencyCode: currencyCode)}',
                        ),
                        color: colors.primaryStrong,
                        bold: true,
                      ),
                      const SizedBox(height: Spacing.xs),
                      ReceiptRow(
                        textStyles: textStyles,
                        label: l10n.transactionTypeExpense.toUpperCase(),
                        value: amount(
                          '-${formatCents(monthlyExpense, locale: moneyLocale(context), currencyCode: currencyCode)}',
                        ),
                        color: colors.error,
                        bold: true,
                      ),
                      const SizedBox(height: Spacing.sm),
                      DashedDivider(color: colors.onSurface),
                      const SizedBox(height: Spacing.sm),
                      for (var i = 0; i < visibleCategories.length; i++) ...[
                        ReceiptRow(
                          textStyles: textStyles,
                          label: visibleCategories[i].category.displayName(
                            l10n,
                          ),
                          value: amount(
                            formatCents(
                              visibleCategories[i].amount,
                              locale: moneyLocale(context),
                              currencyCode: currencyCode,
                            ),
                          ),
                          color: colors.onSurface.withValues(alpha: 0.8),
                        ),
                        if (i < visibleCategories.length - 1 ||
                            otherCategories.isNotEmpty)
                          const SizedBox(height: Spacing.xs + 1),
                      ],
                      if (otherCategories.isNotEmpty)
                        ReceiptRow(
                          textStyles: textStyles,
                          label: l10n.dashboardReceiptOtherCategories(
                            otherCategories.length,
                          ),
                          value: amount(
                            formatCents(
                              otherAmount,
                              locale: moneyLocale(context),
                              currencyCode: currencyCode,
                            ),
                          ),
                          color: colors.onSurface.withValues(alpha: 0.8),
                        ),
                      if (uncategorizedSpending > 0) ...[
                        if (visibleCategories.isNotEmpty)
                          const SizedBox(height: Spacing.xs + 1),
                        ReceiptRow(
                          textStyles: textStyles,
                          label: l10n.uncategorized,
                          value: amount(
                            formatCents(
                              uncategorizedSpending,
                              locale: moneyLocale(context),
                              currencyCode: currencyCode,
                            ),
                          ),
                          color: colors.onSurface.withValues(alpha: 0.8),
                        ),
                      ],
                      const SizedBox(height: Spacing.sm + 2),
                      DashedDivider(color: colors.onSurface, thick: true),
                      const SizedBox(height: Spacing.sm),
                      ReceiptRow(
                        textStyles: textStyles,
                        label: l10n.monthNetLabel.toUpperCase(),
                        value: amount(
                          formatCents(
                            saved,
                            locale: moneyLocale(context),
                            currencyCode: currencyCode,
                          ),
                        ),
                        color: saved < 0 ? colors.error : colors.onSurface,
                        bold: true,
                        large: true,
                      ),
                      const SizedBox(height: Spacing.md - 4),
                      Barcode(color: colors.onSurface),
                    ],
                  ),
                ),
              ),
            ),
            ClipPath(
              clipper: const ReceiptZigzagClipper(),
              child: Container(height: 16, color: colors.surface),
            ),
          ],
        ),
      ),
    );
  }
}

/// An empty receipt, for when there are no wallets yet.
class _NoWalletReceipt extends StatelessWidget {
  const _NoWalletReceipt({required this.monthLabel, required this.year});

  final String monthLabel;
  final int year;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.appColors;

    return Center(
      child: SizedBox(
        width: _receiptWidth,
        child: Column(
          children: [
            Material(
              color: colors.surface,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(22, 20, 22, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      l10n.dashboardReceiptHeader(
                        monthLabel.toUpperCase(),
                        '$year',
                      ),
                      textAlign: TextAlign.center,
                      // Same receipt-print header treatment as above.
                      style: context.textTheme.bodySmall?.copyWith(
                        fontSize: 11, // one-off
                        letterSpacing: 0.8,
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: Spacing.sm),
                    DashedDivider(color: colors.onSurface),
                    const SizedBox(height: Spacing.md),
                    Text(
                      l10n.dashboardReceiptNoWallet,
                      textAlign: TextAlign.center,
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            ClipPath(
              clipper: const ReceiptZigzagClipper(),
              child: Container(height: 16, color: colors.surface),
            ),
          ],
        ),
      ),
    );
  }
}

/// Shown instead of the receipt when this month has no transactions yet.
class _EmptyReceipt extends StatelessWidget {
  const _EmptyReceipt({required this.onAddTransaction});

  final VoidCallback onAddTransaction;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.appColors;

    // Unlike the receipt, this box doesn't tuck under the card, so it needs a gap.
    return Padding(
      padding: const EdgeInsets.fromLTRB(Spacing.lg, Spacing.md, Spacing.lg, 0),
      child: DashedBorder(
        radius: Rounded.lg,
        color: colors.onSurfaceVariant.withValues(alpha: 0.4),
        child: Container(
          padding: const EdgeInsets.all(Spacing.md),
          child: Column(
            children: [
              Text(
                l10n.categorySpendingEmptyHint,
                textAlign: TextAlign.center,
                style: context.textTheme.bodySmall?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: Spacing.sm),
              TextButton.icon(
                onPressed: onAddTransaction,
                style: TextButton.styleFrom(
                  backgroundColor: colors.primary,
                  foregroundColor: colors.onPrimary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: Spacing.md,
                    vertical: Spacing.sm,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(Rounded.pill),
                  ),
                ),
                icon: const Icon(AppIcons.add, size: IconSize.lg),
                label: Text(l10n.addFirstTransactionButton),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
