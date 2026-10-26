import 'package:flutter/material.dart';
import 'package:waldo/core/theme/app_icons.dart';
import 'package:waldo/core/theme/app_theme.dart';
import 'package:waldo/core/theme/icon_size.dart';
import 'package:waldo/core/theme/spacing.dart';
import 'package:waldo/l10n/app_localizations.dart';

/// What a row or card's ⋮ menu offers.
enum EditDeleteAction { edit, delete }

/// The ⋮ menu's items: Edit, then Delete in the error orange.
List<PopupMenuEntry<EditDeleteAction>> editDeleteMenuItems(
  BuildContext context,
) {
  final l10n = AppLocalizations.of(context);
  final colors = context.appColors;

  return [
    PopupMenuItem(
      value: EditDeleteAction.edit,
      child: Row(
        children: [
          const Icon(AppIcons.edit, size: IconSize.lg),
          const SizedBox(width: Spacing.xs),
          Text(l10n.edit),
        ],
      ),
    ),
    PopupMenuItem(
      value: EditDeleteAction.delete,
      child: Row(
        children: [
          Icon(AppIcons.delete, size: IconSize.lg, color: colors.error),
          const SizedBox(width: Spacing.xs),
          Text(l10n.delete, style: TextStyle(color: colors.error)),
        ],
      ),
    ),
  ];
}
