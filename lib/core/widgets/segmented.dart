import 'package:flutter/material.dart';
import 'package:waldo/core/theme/app_theme.dart';
import 'package:waldo/core/theme/dynamic_type_scaler.dart';
import 'package:waldo/core/theme/motion.dart';
import 'package:waldo/core/theme/rounded.dart';
import 'package:waldo/core/theme/spacing.dart';

/// Two or three views of the same thing (DESIGN.md "Segmented"): a `card`
/// track as wide as the sheet, the picked option filled in ink.
class Segmented<T> extends StatelessWidget {
  const Segmented({
    super.key,
    required this.options,
    required this.selected,
    required this.onChanged,
  });

  /// Each option's value and short label, in order.
  final List<(T, String)> options;
  final T selected;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
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
            for (final (value, label) in options)
              Expanded(
                child: _Segment(
                  label: label,
                  selected: value == selected,
                  onTap: () => onChanged(value),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({
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
        // Taps on the track's margin count too.
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: ConstrainedBox(
          // The whole segment, track margin included, is a full touch.
          constraints: const BoxConstraints(
            minHeight: kMinInteractiveDimension,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: Spacing.xxs),
            child: AnimatedContainer(
              duration: context.motion(Motion.toggle),
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(
                horizontal: Spacing.xs,
                vertical: Spacing.component - Spacing.xxs,
              ),
              decoration: BoxDecoration(
                color: selected ? colors.ink : colors.transparent,
                borderRadius: BorderRadius.circular(Rounded.pill),
              ),
              // The word stays whole: it shrinks before it would wrap.
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  maxLines: 1,
                  style: context.bodyStrong.copyWith(
                    color: selected ? colors.onInk : colors.inkMuted,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
