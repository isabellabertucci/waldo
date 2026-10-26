import 'package:flutter/material.dart';
import 'package:waldo/core/constants/enums.dart';
import 'package:waldo/core/theme/app_theme.dart';
import 'package:waldo/core/theme/rounded.dart';
import 'package:waldo/core/theme/spacing.dart';
import 'package:waldo/l10n/app_localizations.dart';
import '../../transactions_x.dart';

/// The Expense/Income toggle: Expense fills orange, Income fills `primary`.
class TransactionTypeToggle extends StatelessWidget {
  const TransactionTypeToggle({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final TransactionType selected;
  final ValueChanged<TransactionType> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.appColors;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(Spacing.xxs),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(Rounded.pill),
      ),
      child: Row(
        children: [
          Expanded(
            child: _TypeToggleSegment(
              label: TransactionType.expense.label(l10n),
              selected: selected == TransactionType.expense,
              color: colors.error,
              onColor: colors.onPrimary,
              onTap: () => onChanged(TransactionType.expense),
            ),
          ),
          Expanded(
            child: _TypeToggleSegment(
              label: TransactionType.income.label(l10n),
              selected: selected == TransactionType.income,
              color: colors.primary,
              onColor: colors.onPrimary,
              onTap: () => onChanged(TransactionType.income),
            ),
          ),
        ],
      ),
    );
  }
}

class _TypeToggleSegment extends StatelessWidget {
  const _TypeToggleSegment({
    required this.label,
    required this.selected,
    required this.color,
    required this.onColor,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final Color color;
  final Color onColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Semantics(
      button: true,
      selected: selected,
      inMutuallyExclusiveGroup: true,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: Spacing.xs),
          decoration: BoxDecoration(
            color: selected ? color : colors.transparent,
            borderRadius: BorderRadius.circular(Rounded.pill),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: context.bodyMdBold.copyWith(
              color: selected ? onColor : colors.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}
