import 'package:flutter/material.dart';
import 'package:waldo/core/theme/dynamic_type_scaler.dart';
import 'package:waldo/core/theme/motion.dart';
import 'package:waldo/core/constants/enums.dart';
import 'package:waldo/core/theme/app_theme.dart';
import 'package:waldo/core/theme/rounded.dart';
import 'package:waldo/core/theme/spacing.dart';
import 'package:waldo/l10n/app_localizations.dart';
import '../../transactions_x.dart';

/// The Expense/Income toggle: the picked one is a solid ink pill on the
/// `card` track, like every picked choice.
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
      // The top and bottom margin is inside each segment's touch.
      padding: const EdgeInsets.symmetric(horizontal: Spacing.xxs),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(Rounded.pill),
      ),
      // Segmented controls stop growing where bars do, as on iOS.
      child: MediaQuery.withClampedTextScaling(
        maxScaleFactor: DynamicTypeScaler.barMaxScale,
        child: Row(
          children: [
            // Expense first: it's what most transactions are.
            for (final type in [
              TransactionType.expense,
              TransactionType.income,
            ])
              Expanded(
                child: _TypeToggleSegment(
                  label: type.label(l10n),
                  selected: selected == type,
                  onTap: () => onChanged(type),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _TypeToggleSegment extends StatelessWidget {
  const _TypeToggleSegment({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Semantics(
      button: true,
      selected: selected,
      inMutuallyExclusiveGroup: true,
      child: GestureDetector(
        // Taps on the track's margin count too: a 48px-tall touch.
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: Spacing.xxs),
          child: AnimatedContainer(
            duration: Motion.toggle,
            padding: const EdgeInsets.symmetric(vertical: Spacing.component),
            decoration: BoxDecoration(
              color: selected ? colors.ink : colors.transparent,
              borderRadius: BorderRadius.circular(Rounded.pill),
            ),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: context.bodyStrong.copyWith(
                color: selected ? colors.onInk : colors.inkMuted,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
