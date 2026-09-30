import 'package:flutter/material.dart';
import 'package:waldo/core/constants/enums.dart';
import 'package:waldo/core/router/app_router.dart';
import 'package:waldo/core/theme/app_theme.dart';
import 'package:waldo/core/theme/rounded.dart';
import 'package:waldo/core/theme/spacing.dart';
import 'package:waldo/core/utils/utils.dart';
import 'package:waldo/core/widgets/empty_state.dart';
import 'package:waldo/features/categories/categories_x.dart';
import 'package:waldo/l10n/app_localizations.dart';

import '../../models/dashboard_data.dart';

const _cardWidthDivisor = 1.5;

class CategorySpendingList extends StatelessWidget {
  const CategorySpendingList({
    super.key,
    required this.spendingByCategory,
    required this.currency,
  });

  final List<CategorySpending> spendingByCategory;
  final Currency currency;

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
                  l10n.spendingsByCategory,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: Spacing.sm),
              GestureDetector(
                onTap: () => const CategoriesRoute().push(context),
                child: Text(
                  l10n.seeAll,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: context.appColors.secondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: Spacing.md),
        if (spendingByCategory.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: Spacing.lg),
            child: EmptyState(
              icon: Icons.pie_chart_outline,
              title: l10n.noSpendingThisMonth,
            ),
          )
        else
          SizedBox(
            height: 108,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
              itemCount: spendingByCategory.length,
              separatorBuilder: (context, index) =>
                  const SizedBox(width: Spacing.md),
              itemBuilder: (context, index) {
                final spending = spendingByCategory[index];
                return _CategorySpendingCard(
                  spending: spending,
                  currency: currency,
                );
              },
            ),
          ),
      ],
    );
  }
}

class _CategorySpendingCard extends StatelessWidget {
  const _CategorySpendingCard({required this.spending, required this.currency});

  final CategorySpending spending;
  final Currency currency;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.appColors;
    final percentChange = spending.percentChangeFromLastMonth;
    final deltaColor = percentChange == null
        ? colors.onSurfaceVariant
        : percentChange > 0
        ? colors.error
        : colors.primaryStrong;
    final deltaText = percentChange == null
        ? null
        : l10n.percentFromLastMonth(
            '${percentChange > 0 ? '+' : ''}${percentChange.round()}%',
          );

    return Container(
      width: MediaQuery.of(context).size.width / _cardWidthDivisor,
      padding: const EdgeInsets.all(Spacing.md),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(Rounded.lg),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: colors.secondary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              spending.category.type.icon,
              color: colors.secondary,
              size: 18,
            ),
          ),
          const SizedBox(width: Spacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  spending.category.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  formatCents(
                    spending.amount,
                    currencyCode: currency.code,
                  ),
                  style: context.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (deltaText != null)
                  Text(
                    deltaText,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: deltaColor,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
