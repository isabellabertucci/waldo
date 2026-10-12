import 'package:flutter/material.dart';
import 'package:waldo/core/theme/app_icons.dart';
import 'package:waldo/core/theme/app_theme.dart';
import 'package:waldo/core/theme/icon_size.dart';
import 'package:waldo/core/theme/spacing.dart';
import 'package:waldo/l10n/app_localizations.dart';

/// The ✕ that closes a bottom sheet: a tinted disc with no shadow.
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
