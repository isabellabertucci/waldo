import 'package:flutter/material.dart';
import 'package:waldo/core/theme/app_icons.dart';
import 'package:waldo/core/theme/app_theme.dart';
import 'package:waldo/core/theme/icon_size.dart';
import 'package:waldo/core/widgets/circle_icon_button.dart';
import 'package:waldo/l10n/app_localizations.dart';

/// The ✕ that closes a bottom sheet: a tinted disc with no shadow.
class SheetCloseButton extends StatelessWidget {
  const SheetCloseButton({super.key});

  @override
  Widget build(BuildContext context) {
    return CircleIconButton(
      flat: true,
      tooltip: AppLocalizations.of(context).close,
      onPressed: () => Navigator.of(context).pop(),
      child: Icon(
        AppIcons.close,
        size: IconSize.lg,
        color: context.appColors.onSurface,
      ),
    );
  }
}
