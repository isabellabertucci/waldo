import 'package:flutter/material.dart';
import 'package:waldo/core/theme/badge_size.dart';
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
    return Divider(
      height: 1,
      // Starts under the title: row padding + badge + title gap.
      indent: Spacing.sm + BadgeSize.lg + Spacing.component,
      color: context.appColors.onSurfaceVariant.withValues(alpha: 0.12),
    );
  }
}

/// From this text size up, the value moves under the title so the title
/// keeps the row's width.
const _stackValueTextScale = 1.5; // one-off

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
    final valueText = Text(
      value,
      style: context.textTheme.bodyMedium?.copyWith(
        color: colors.onSurfaceVariant,
      ),
    );

    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: Spacing.sm,
        vertical: Spacing.xxs,
      ),
      horizontalTitleGap: Spacing.component,
      // Same disc as the option sheet's, so both screens match.
      leading: Container(
        width: BadgeSize.lg,
        height: BadgeSize.lg,
        decoration: BoxDecoration(
          color: colors.fieldFill,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: IconSize.lg, color: colors.onSurfaceVariant),
      ),
      title: Text(title, style: context.bodyMdBold),
      subtitle: subtitle == null && !stacked
          ? null
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (subtitle != null)
                  Text(
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
