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
}
