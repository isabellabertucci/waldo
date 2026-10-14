import 'package:flutter/material.dart';
import 'package:waldo/core/theme/app_icons.dart';
import 'package:waldo/core/theme/app_theme.dart';
import 'package:waldo/core/theme/icon_size.dart';
import 'package:waldo/core/theme/spacing.dart';
import 'package:waldo/l10n/app_localizations.dart';

/// The ✕ in the top corner of a bottom sheet - a tinted, shadowless disc
/// (the sheet is already its own raised surface, unlike [CircleIconButton]'s
/// page-level buttons) that closes the sheet.
class SheetCloseButton extends StatelessWidget {
  const SheetCloseButton({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final l10n = AppLocalizations.of(context);

    return Tooltip(
      message: l10n.close,
      child: Material(
        color: colors.surfaceContainer,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: () => Navigator.of(context).pop(),
          child: Padding(
            padding: const EdgeInsets.all(Spacing.component),
            child: Icon(
              AppIcons.close,
              size: IconSize.lg,
              color: colors.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}
