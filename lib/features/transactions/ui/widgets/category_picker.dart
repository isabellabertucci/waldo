import 'package:flutter/material.dart';
import 'package:waldo/core/theme/app_icons.dart';
import 'package:waldo/core/widgets/option_sheet.dart';
import 'package:waldo/features/categories/categories_x.dart';
import 'package:waldo/features/categories/models/category.dart';
import 'package:waldo/features/categories/ui/widgets/category_form_sheet.dart';
import 'package:waldo/l10n/app_localizations.dart';

/// The category picker of both transaction sheets: "New category", which
/// opens its sheet and picks what it creates, then None and every category.
Future<void> showCategoryPicker(
  BuildContext context, {
  required List<Category> categories,
  required int? selected,
  required ValueChanged<int?> onPicked,
}) {
  final l10n = AppLocalizations.of(context);

  return showOptionSheet<int?>(
    context,
    title: l10n.category,
    initialValue: selected,
    pickOnTap: true,
    options: [
      SheetOption(
        value: null,
        label: l10n.none,
        icon: AppIcons.categoryGeneric,
      ),
      for (final c in categories.inDisplayOrder(l10n))
        SheetOption(value: c.id, label: c.displayName(l10n), icon: c.icon),
    ],
    onConfirm: onPicked,
    action: (
      icon: AppIcons.add,
      label: l10n.newCategory,
      onTap: () async {
        final id = await showCategoryFormSheet(context);
        if (id != null) onPicked(id);
      },
    ),
  );
}
