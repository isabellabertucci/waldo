import 'package:flutter/material.dart';
import 'package:waldo/core/theme/app_theme.dart';
import 'package:waldo/core/theme/dynamic_type_scaler.dart';
import 'package:waldo/core/theme/icon_size.dart';
import 'package:waldo/core/theme/rounded.dart';
import 'package:waldo/core/theme/spacing.dart';

/// One pill in [ChoiceChips].
typedef ChoiceChip<T> = ({T value, IconData icon, String label});

/// Pills with an icon and a name, in a row that scrolls sideways; the
/// picked one in ink, the secondary colour, like the picked side of every
/// segmented choice (a wallet's type, a recent category). They wrap at
/// accessibility sizes, so every name shows whole.
class ChoiceChips<T> extends StatelessWidget {
  const ChoiceChips({
    super.key,
    required this.chips,
    required this.selected,
    required this.onTap,
  });

  final List<ChoiceChip<T>> chips;

  /// None picked when it matches no chip.
  final T? selected;
  final ValueChanged<T> onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final shape = BorderRadius.circular(Rounded.pill);
    final pills = [
      for (final chip in chips)
        Semantics(
          button: true,
          selected: chip.value == selected,
          child: Material(
            color: chip.value == selected ? colors.ink : colors.card,
            borderRadius: shape,
            child: InkWell(
              borderRadius: shape,
              onTap: () => onTap(chip.value),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  minHeight: kMinInteractiveDimension,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Spacing.sm,
                    vertical: Spacing.xs,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        chip.icon,
                        size: IconSize.md,
                        color: chip.value == selected
                            ? colors.onInk
                            : colors.ink,
                      ),
                      const SizedBox(width: Spacing.xs),
                      Flexible(
                        child: Text(
                          chip.label,
                          style: context.bodyStrong.copyWith(
                            color: chip.value == selected
                                ? colors.onInk
                                : colors.ink,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
    ];

    if (DynamicTypeScaler.isAccessibilitySize(context)) {
      return Wrap(spacing: Spacing.xs, runSpacing: Spacing.xs, children: pills);
    }
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      clipBehavior: Clip.none,
      child: Row(spacing: Spacing.xs, children: pills),
    );
  }
}
