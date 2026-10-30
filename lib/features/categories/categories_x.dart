import 'package:flutter/material.dart';
import 'package:waldo/core/constants/enums.dart';
import 'package:waldo/core/theme/app_icons.dart';
import 'package:waldo/l10n/app_localizations.dart';

import 'models/category.dart';

extension CategoryTypeLabel on CategoryType {
  String label(AppLocalizations l10n) {
    return switch (this) {
      CategoryType.groceries => l10n.categoryTypeGroceries,
      CategoryType.transportation => l10n.categoryTypeTransportation,
      CategoryType.subscriptions => l10n.categoryTypeSubscriptions,
      CategoryType.education => l10n.categoryTypeEducation,
      CategoryType.investments => l10n.categoryTypeInvestments,
      CategoryType.others => l10n.categoryTypeOthers,
    };
  }
}

extension CategoryTypeIcon on CategoryType {
  IconData get icon {
    return switch (this) {
      CategoryType.groceries => AppIcons.categoryGroceries,
      CategoryType.transportation => AppIcons.categoryTransportation,
      CategoryType.subscriptions => AppIcons.categorySubscriptions,
      CategoryType.education => AppIcons.categoryEducation,
      CategoryType.investments => AppIcons.categoryInvestments,
      CategoryType.others => AppIcons.categoryOthers,
    };
  }
}

extension CategoryDisplayName on Category {
  /// The name the user sees: built-ins are translated from their type.
  String displayName(AppLocalizations l10n) =>
      isDefault ? type.label(l10n) : name;

  /// Its name in every app language, so a custom category can't clash with a
  /// built-in after the language changes.
  Iterable<String> get namesInEveryLanguage => isDefault
      ? AppLocalizations.supportedLocales.map(
          (locale) => type.label(lookupAppLocalizations(locale)),
        )
      : [name];
}

extension CategoryIcon on Category {
  /// Built-ins keep their own icon; a user-named category gets a plain tag.
  IconData get icon => isDefault ? type.icon : AppIcons.categoryGeneric;
}

extension CategoryOthers on Category {
  /// The built-in catch-all: deleted categories' transactions move here, so
  /// it can't be deleted itself and always lists last.
  bool get isOthers => isDefault && type == CategoryType.others;
}

extension CategoryListOrder on Iterable<Category> {
  /// A-Z by the name on screen, with the catch-all "Others" last: the order
  /// of every category list, so each one reads the same.
  List<Category> inDisplayOrder(AppLocalizations l10n) {
    return [...this]..sort((a, b) {
      if (a.isOthers != b.isOthers) return a.isOthers ? 1 : -1;
      return a
          .displayName(l10n)
          .toLowerCase()
          .compareTo(b.displayName(l10n).toLowerCase());
    });
  }
}
