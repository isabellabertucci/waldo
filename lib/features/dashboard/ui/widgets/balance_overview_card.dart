import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:waldo/core/constants/enums.dart';
import 'package:waldo/core/theme/app_theme.dart';
import 'package:waldo/core/theme/rounded.dart';
import 'package:waldo/core/theme/spacing.dart';
import 'package:waldo/core/utils/utils.dart';
import 'package:waldo/l10n/app_localizations.dart';

class BalanceOverviewCard extends StatefulWidget {
  const BalanceOverviewCard({
    super.key,
    required this.totalBalance,
    required this.monthlyIncome,
    required this.monthlyExpense,
    required this.currency,
  });

  final int totalBalance;
  final int monthlyIncome;
  final int monthlyExpense;
  final Currency currency;

  @override
  State<BalanceOverviewCard> createState() => _BalanceOverviewCardState();
}

class _BalanceOverviewCardState extends State<BalanceOverviewCard> {
  bool _isBalanceHidden = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.appColors;
    final currencyCode = widget.currency.name.toUpperCase();
    final month = DateFormat.MMMM(
      Localizations.localeOf(context).toString(),
    ).format(DateTime.now());

    final balanceText = _isBalanceHidden
        ? '••••••'
        : formatCents(widget.totalBalance, currencyCode: currencyCode);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(Spacing.xl),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colors.primaryStrong, colors.primary],
        ),
        borderRadius: BorderRadius.circular(Rounded.xl),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.myFinances,
                      style: context.textTheme.titleMedium?.copyWith(
                        color: colors.onPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      l10n.overviewSubtitle(month),
                      style: context.textTheme.bodySmall?.copyWith(
                        color: colors.onPrimary.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () =>
                    setState(() => _isBalanceHidden = !_isBalanceHidden),
                icon: Icon(
                  _isBalanceHidden
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: colors.onPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: Spacing.lg),
          Text(
            l10n.totalBalance,
            style: context.textTheme.bodySmall?.copyWith(
              color: colors.onPrimary.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: Spacing.xs),
          Text(
            balanceText,
            style: context.textTheme.headlineMedium?.copyWith(
              color: colors.onPrimary,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: Spacing.lg),
          Row(
            children: [
              Expanded(
                child: _SummaryPill(
                  label: l10n.transactionTypeIncome,
                  value:
                      '+${formatCents(widget.monthlyIncome, currencyCode: currencyCode)}',
                  onPrimary: colors.onPrimary,
                ),
              ),
              const SizedBox(width: Spacing.md),
              Expanded(
                child: _SummaryPill(
                  label: l10n.transactionTypeExpense,
                  value:
                      '-${formatCents(widget.monthlyExpense, currencyCode: currencyCode)}',
                  onPrimary: colors.onPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryPill extends StatelessWidget {
  const _SummaryPill({
    required this.label,
    required this.value,
    required this.onPrimary,
  });

  final String label;
  final String value;
  final Color onPrimary;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.md,
        vertical: Spacing.sm,
      ),
      decoration: BoxDecoration(
        color: onPrimary.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(Rounded.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: context.textTheme.bodySmall?.copyWith(
              color: onPrimary.withValues(alpha: 0.8),
            ),
          ),
          Text(
            value,
            style: context.textTheme.titleSmall?.copyWith(
              color: onPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
