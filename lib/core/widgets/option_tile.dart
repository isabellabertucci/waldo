import 'package:flutter/material.dart';
import 'package:waldo/core/theme/badge_size.dart';
import 'package:waldo/core/widgets/dashed_border.dart';
import 'package:waldo/core/theme/app_theme.dart';
import 'package:waldo/core/theme/icon_size.dart';
import 'package:waldo/core/theme/rounded.dart';
import 'package:waldo/core/theme/spacing.dart';

/// One tile in a pick-one grid (wallet type, category type): an icon disc
/// over a label, with an ink stitch and filled ink disc when selected.
class OptionTile extends StatelessWidget {
  const OptionTile({
    super.key,
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
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
      child: Material(
        color: colors.surfaceContainer,
        borderRadius: BorderRadius.circular(Rounded.md),
        child: InkWell(
          borderRadius: BorderRadius.circular(Rounded.md),
          onTap: onTap,
          child: DashedBorder(
            radius: Rounded.md,
            color: selected ? colors.primary : colors.transparent,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: BadgeSize.md,
                  height: BadgeSize.md,
                  decoration: BoxDecoration(
                    color: selected
                        ? colors.primary
                        : colors.onSurfaceVariant.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: IconSize.md,
                    color: selected
                        ? colors.onPrimary
                        : colors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: Spacing.xs),
                // A long label ("Cartão de crédito") wraps to a second line;
                // Flexible keeps it from overflowing the tile under large text.
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Spacing.xxs,
                    ),
                    child: Text(
                      label,
                      maxLines: 2,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      style: context.bodySmBold.copyWith(
                        color: colors.onSurface,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
