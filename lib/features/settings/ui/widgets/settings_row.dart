import 'package:flutter/material.dart';
import 'package:waldo/core/widgets/rows_card.dart';
import 'package:waldo/core/widgets/whole_words_text.dart';
import 'package:waldo/core/theme/dynamic_type_scaler.dart';
import 'package:waldo/core/theme/app_icons.dart';
import 'package:waldo/core/theme/icon_size.dart';
import 'package:waldo/core/theme/app_theme.dart';
import 'package:waldo/core/theme/spacing.dart';

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
      style: context.label.copyWith(color: colors.inkMuted),
    );

    final disc = RowDisc(icon: icon);
    final titleText = WholeWordsText(title, style: context.bodyStrong);

    return ListTile(
      onTap: onTap,
      // The section's card is the fill and the shape, not each row.
      tileColor: colors.transparent,
      shape: const RoundedRectangleBorder(),
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
                    style: context.label.copyWith(color: colors.inkMuted),
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
            size: IconSize.md,
            color: colors.inkMuted,
          ),
        ],
      ),
    );
  }
}
