import 'package:flutter/material.dart';
import 'package:waldo/core/widgets/whole_words_text.dart';
import 'package:waldo/core/theme/badge_size.dart';
import 'package:waldo/core/theme/dynamic_type_scaler.dart';
import 'package:waldo/core/theme/app_icons.dart';
import 'package:waldo/core/theme/icon_size.dart';
import 'package:waldo/core/theme/app_theme.dart';
import 'package:waldo/core/theme/spacing.dart';
import 'package:waldo/core/widgets/heading.dart';

class SectionLabel extends StatelessWidget {
  const SectionLabel({required this.title, super.key});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Spacing.xs),
      child: Heading(
        child: Text(
          title.toUpperCase(),
          style: context.labelXs.copyWith(
            color: context.appColors.onSurfaceVariant,
            letterSpacing: 1.0,
          ),
        ),
      ),
    );
  }
}

class SettingsCard extends StatelessWidget {
  const SettingsCard({required this.children, super.key});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      // No outer margin, so the card lines up with the page gutter.
      margin: EdgeInsets.zero,
      child: Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) const _RowDivider(),
            children[i],
          ],
        ],
      ),
    );
  }
}

class _RowDivider extends StatelessWidget {
  const _RowDivider();

  @override
  Widget build(BuildContext context) {
    // Starts under the title: row padding, plus the disc and its gap when
    // the disc sits beside the title.
    return Divider(
      indent: DynamicTypeScaler.isAccessibilitySize(context)
          ? Spacing.sm
          : Spacing.sm + BadgeSize.lg + Spacing.component,
    );
  }
}

/// From this text size up, the value moves under the title so the title
/// keeps the row's width.
const _stackValueTextScale = 1.5;

class SettingsRow extends StatelessWidget {
  const SettingsRow({
    required this.icon,
    required this.title,
    required this.value,
    required this.onTap,
    this.subtitle,
    super.key,
  });

  final IconData icon;
  final String title;

  /// Optional second line under [title], e.g. "How amounts are shown".
  final String? subtitle;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final stacked =
        MediaQuery.textScalerOf(context).scale(1) >= _stackValueTextScale;
    // At accessibility sizes the disc moves above the title, so long words
    // get the row's full width instead of breaking.
    final discAbove = DynamicTypeScaler.isAccessibilitySize(context);
    final valueText = WholeWordsText(
      value,
      style: context.textTheme.bodyMedium?.copyWith(
        color: colors.onSurfaceVariant,
      ),
    );

    // Same disc as the option sheet's, so both screens match.
    final disc = Container(
      width: BadgeSize.lg,
      height: BadgeSize.lg,
      decoration: BoxDecoration(
        // The page behind the card, as if the disc were cut out of it.
        color: colors.surfaceContainer,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: IconSize.lg, color: colors.onSurfaceVariant),
    );
    final titleText = WholeWordsText(title, style: context.bodyMdBold);

    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: Spacing.sm,
        vertical: Spacing.xxs,
      ),
      horizontalTitleGap: Spacing.component,
      leading: discAbove ? null : disc,
      title: discAbove
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                disc,
                const SizedBox(height: Spacing.xs),
                titleText,
              ],
            )
          : titleText,
      subtitle: subtitle == null && !stacked
          ? null
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (subtitle != null)
                  WholeWordsText(
                    subtitle!,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                if (stacked) valueText,
              ],
            ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!stacked) ...[valueText, const SizedBox(width: Spacing.xs)],
          Icon(
            AppIcons.chevronRight,
            size: IconSize.xl,
            color: colors.onSurfaceVariant,
          ),
        ],
      ),
    );
  }
}
