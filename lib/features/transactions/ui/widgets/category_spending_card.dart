import 'package:flutter/material.dart';
import 'package:waldo/core/constants/enums.dart';
import 'package:waldo/core/theme/app_icons.dart';
import 'package:waldo/core/theme/app_theme.dart';
import 'package:waldo/core/theme/badge_size.dart';
import 'package:waldo/core/theme/component_size.dart';
import 'package:waldo/core/theme/icon_size.dart';
import 'package:waldo/core/theme/rounded.dart';
import 'package:waldo/core/theme/spacing.dart';
import 'package:waldo/core/utils/utils.dart';
import 'package:waldo/core/widgets/badge_row.dart';
import 'package:waldo/core/widgets/heading.dart';
import 'package:waldo/core/widgets/whole_words_text.dart';
import 'package:waldo/features/categories/categories_x.dart';
import 'package:waldo/l10n/app_localizations.dart';

import 'package:waldo/features/dashboard/models/dashboard_data.dart';

/// Category lines shown before the rest fold into one "Other" line.
const _maxRows = 5;

/// "Spending by category": the month's expense per category, dearest first,
/// each with a bar against the dearest - the part of the old receipt worth
/// keeping.
class CategorySpendingCard extends StatelessWidget {
  const CategorySpendingCard({
    super.key,
    required this.spendingByCategory,
    required this.uncategorizedSpending,
    required this.currency,
    required this.isBalanceHidden,
  });

  final List<CategorySpending> spendingByCategory;
  final int uncategorizedSpending;
  final Currency currency;
  final bool isBalanceHidden;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.appColors;
    final shown = spendingByCategory.take(_maxRows).toList();
    final rest = spendingByCategory.skip(_maxRows).toList();
    final lines = [
      for (final s in shown)
        (s.category.icon, s.category.displayName(l10n), s.amount),
      if (rest.isNotEmpty)
        (
          AppIcons.categoryOthers,
          l10n.dashboardReceiptOtherCategories(rest.length),
          rest.fold(0, (sum, s) => sum + s.amount),
        ),
      if (uncategorizedSpending > 0)
        (AppIcons.categoryNone, l10n.uncategorized, uncategorizedSpending),
    ];
    final dearest = lines.fold(0, (most, l) => l.$3 > most ? l.$3 : most);

    return Container(
      padding: const EdgeInsets.all(Spacing.md - Spacing.xxs),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(Rounded.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Heading(
            child: Text(l10n.categorySpending, style: context.titleSection),
          ),
          const SizedBox(height: Spacing.sm),
          if (lines.isEmpty)
            Text(
              l10n.categorySpendingEmptyHint,
              style: context.label.copyWith(color: colors.inkMuted),
            ),
          for (final (i, (icon, name, amount)) in lines.indexed) ...[
            if (i > 0) const SizedBox(height: Spacing.component),
            _CategoryLine(
              icon: icon,
              name: name,
              amount: isBalanceHidden
                  ? hiddenAmount
                  : formatCents(
                      amount,
                      locale: moneyLocale(context),
                      currencyCode: currency.code,
                    ),
              share: dearest == 0 ? 0 : amount / dearest,
            ),
          ],
        ],
      ),
    );
  }
}

class _CategoryLine extends StatelessWidget {
  const _CategoryLine({
    required this.icon,
    required this.name,
    required this.amount,
    required this.share,
  });

  final IconData icon;
  final String name;
  final String amount;

  /// This line's amount over the dearest line's, 0-1.
  final double share;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return MergeSemantics(
      child: BadgeRow(
        badge: Container(
          width: BadgeSize.lg,
          height: BadgeSize.lg,
          decoration: BoxDecoration(
            color: colors.sheet,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: IconSize.md, color: colors.ink),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: WholeWordsText.singleLine(
                    name,
                    style: context.bodyStrong,
                  ),
                ),
                const SizedBox(width: Spacing.xs),
                // Spent, so it reads as an expense - but in ink: red on
                // every line would shout.
                Text(
                  amount,
                  style: context.amountRow.copyWith(color: colors.ink),
                ),
              ],
            ),
            const SizedBox(height: Spacing.xxs),
            ExcludeSemantics(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(Rounded.pill),
                child: LinearProgressIndicator(
                  value: share,
                  minHeight: ComponentSize.categoryBar,
                  backgroundColor: colors.sheet,
                  color: colors.ink,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
