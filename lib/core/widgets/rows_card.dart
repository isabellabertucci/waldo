import 'package:flutter/material.dart';
import 'package:waldo/core/theme/app_theme.dart';
import 'package:waldo/core/theme/badge_size.dart';
import 'package:waldo/core/theme/dynamic_type_scaler.dart';
import 'package:waldo/core/theme/icon_size.dart';
import 'package:waldo/core/theme/rounded.dart';
import 'package:waldo/core/theme/spacing.dart';
import 'package:waldo/core/widgets/heading.dart';

/// A section of rows on the white sheet (Settings, Categories): an
/// optional [title] in `overline`, then the rows on one `card` block,
/// divided by hairlines that start under the rows' names (DESIGN.md
/// "Rows card").
class RowsCard extends StatelessWidget {
  const RowsCard({required this.children, this.title, super.key});

  final List<Widget> children;
  final String? title;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    // Under the name: row padding, plus the disc and its gap when the disc
    // sits beside the name.
    final indent = DynamicTypeScaler.isAccessibilitySize(context)
        ? Spacing.sm
        : Spacing.sm + BadgeSize.lg + Spacing.component;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (title case final title?)
          Padding(
            padding: const EdgeInsets.only(bottom: Spacing.xs),
            child: Heading(
              child: Text(
                title.toUpperCase(),
                style: context.overline.copyWith(color: colors.inkMuted),
              ),
            ),
          ),
        // A Material, so the rows' ripples paint on the card, clipped to it.
        Material(
          color: colors.card,
          borderRadius: BorderRadius.circular(Rounded.md),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              for (var i = 0; i < children.length; i++) ...[
                if (i > 0)
                  Divider(height: 1, color: colors.line, indent: indent),
                children[i],
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// A row's round icon disc on a [RowsCard]: the sheet's white, as if cut
/// out of the card (DESIGN.md "Layout").
class RowDisc extends StatelessWidget {
  const RowDisc({required this.icon, this.color, super.key});

  final IconData icon;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      width: BadgeSize.lg,
      height: BadgeSize.lg,
      decoration: BoxDecoration(color: colors.sheet, shape: BoxShape.circle),
      child: Icon(icon, size: IconSize.lg, color: color ?? colors.inkMuted),
    );
  }
}
