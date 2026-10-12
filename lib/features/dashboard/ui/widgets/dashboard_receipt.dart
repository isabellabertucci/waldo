import 'package:flutter/material.dart';
import 'package:waldo/core/theme/app_icons.dart';
import 'package:waldo/core/theme/icon_size.dart';
import 'package:waldo/core/constants/enums.dart';
import 'package:waldo/core/theme/app_theme.dart';
import 'package:waldo/core/theme/rounded.dart';
import 'package:waldo/core/theme/spacing.dart';
import 'package:waldo/core/utils/utils.dart';
import 'package:waldo/core/widgets/receipt_shell.dart';
import 'package:waldo/features/categories/categories_x.dart';
import 'package:waldo/l10n/app_localizations.dart';

import '../../models/dashboard_data.dart';

/// Width of the receipt's paper strip - narrower than the wallet above it
/// (like a real receipt sticking out of a pocket), so it reads as one
/// continuous object with the balance card rather than a separate section.
const _receiptWidth = 300.0;

/// How many category rows the receipt lists individually before collapsing
/// the rest into one "Other" line - a heavy user with dozens of categories
/// in a month would otherwise turn this into an endlessly scrolling slip.
/// [spendingByCategory] already arrives sorted by amount descending, so
/// this keeps the biggest, most useful lines and rolls the long tail into
/// one total that still reconciles with EXPENSE above it; the whole receipt
/// is already a tap-through to the full list for anyone who wants the rest.
const _maxCategoryRows = 5;

/// This month's income, expense and category breakdown, drawn as a
/// receipt attached directly under the balance card instead of as
/// separate stat cards - replaces [MonthlySummaryRow] and
/// [CategorySpendingList]. The whole receipt is one tap target through to
/// the full transaction list, since that's what a real receipt is a
/// shorthand for.
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

  /// Whether at least one wallet exists yet - with none, there is nothing
  /// to tap through to and no transaction to add, so the receipt shows a
  /// simple "comes later" message instead of the dashed hint-box CTA used
  /// when a wallet exists but this month has no transactions yet.
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
                        // Receipt-print header: its own fixed small-caps
                        // size + wide tracking, distinct from the app's
                        // label-xs (which uses a tighter 0.4 tracking).
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
                          '+${formatCents(monthlyIncome, currencyCode: currencyCode)}',
                        ),
                        color: colors.primaryStrong,
                        bold: true,
                      ),
                      const SizedBox(height: Spacing.xs),
                      ReceiptRow(
                        textStyles: textStyles,
                        label: l10n.transactionTypeExpense.toUpperCase(),
                        value: amount(
                          '-${formatCents(monthlyExpense, currencyCode: currencyCode)}',
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
                          label: visibleCategories[i].category.isDefault
                              ? visibleCategories[i].category.type.label(l10n)
                              : visibleCategories[i].category.name,
                          value: amount(
                            formatCents(
                              visibleCategories[i].amount,
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
                          formatCents(saved, currencyCode: currencyCode),
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

/// The receipt's shell (header, dashed divider, zigzag paper edge) with no
/// wallets to report on yet - same object as the filled-in receipt, just
/// with nothing printed on it yet.
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

/// Shown instead of the receipt when there's no income, expense or category
/// spending yet this month - matches the old [CategorySpendingList] empty
/// state so the "nothing here yet" call to action survives the redesign.
class _EmptyReceipt extends StatelessWidget {
  const _EmptyReceipt({required this.onAddTransaction});

  final VoidCallback onAddTransaction;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.appColors;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
      child: Container(
        padding: const EdgeInsets.all(Spacing.md),
        decoration: BoxDecoration(
          border: Border.all(
            color: colors.onSurfaceVariant.withValues(alpha: 0.4),
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(Rounded.lg),
        ),
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
    );
  }
}
