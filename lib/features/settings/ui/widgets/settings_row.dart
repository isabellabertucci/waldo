import 'package:flutter/material.dart';
import 'package:waldo/core/theme/app_icons.dart';
import 'package:waldo/core/theme/icon_size.dart';
import 'package:waldo/core/theme/app_theme.dart';
import 'package:waldo/core/theme/rounded.dart';
import 'package:waldo/core/theme/spacing.dart';

class SectionLabel extends StatelessWidget {
  const SectionLabel({required this.title, super.key});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Spacing.sm, left: Spacing.xxs),
      child: Text(
        title.toUpperCase(),
        style: context.labelXs.copyWith(
          color: context.appColors.onSurfaceVariant,
          letterSpacing: 1.0,
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
      indent: Spacing.lg + 36 + Spacing.sm,
      color: context.appColors.onSurfaceVariant.withValues(alpha: 0.12),
    );
  }
}

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

  /// A second line under [title] explaining what the row controls, e.g.
  /// "How amounts are shown" - optional, since a row as self-explanatory as
  /// Theme doesn't need one.
  final String? subtitle;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: Spacing.lg,
        vertical: Spacing.xs,
      ),
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: colors.surfaceContainer,
          borderRadius: BorderRadius.circular(Rounded.md),
        ),
        child: Icon(icon, size: IconSize.lg, color: colors.onSurfaceVariant),
      ),
      title: Text(title, style: context.bodyMdBold),
      subtitle: subtitle == null
          ? null
          : Text(
              subtitle!,
              style: context.textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: context.textTheme.bodyMedium?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: Spacing.xs),
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
