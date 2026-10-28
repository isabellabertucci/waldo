import 'package:flutter/material.dart';
import 'package:waldo/core/theme/alpha.dart';
import 'package:waldo/core/theme/badge_size.dart';
import 'package:waldo/core/theme/dynamic_type_scaler.dart';
import 'package:waldo/core/widgets/dashed_border.dart';
import 'package:waldo/core/widgets/whole_words_text.dart';
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
    final disc = Container(
      width: BadgeSize.md,
      height: BadgeSize.md,
      decoration: BoxDecoration(
        color: selected
            ? colors.primary
            : colors.onSurfaceVariant.withValues(alpha: Alpha.soft),
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        size: IconSize.md,
        color: selected ? colors.onPrimary : colors.onSurfaceVariant,
      ),
    );
    final labelStyle = context.bodySmBold.copyWith(color: colors.onSurface);

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
            // At accessibility sizes the tile is a row, so the label keeps
            // the whole width.
            child: DynamicTypeScaler.isAccessibilitySize(context)
                ? Padding(
                    padding: const EdgeInsets.all(Spacing.sm),
                    child: Row(
                      children: [
                        disc,
                        const SizedBox(width: Spacing.sm),
                        Expanded(
                          child: WholeWordsText(label, style: labelStyle),
                        ),
                      ],
                    ),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      disc,
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
                            style: labelStyle,
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
