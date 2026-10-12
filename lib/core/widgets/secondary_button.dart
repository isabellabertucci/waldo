import 'package:flutter/material.dart';
import 'package:waldo/core/theme/app_theme.dart';
import 'package:waldo/core/theme/rounded.dart';
import 'package:waldo/core/theme/spacing.dart';

/// Low-emphasis pill: filled on the page, bare text on a sheet.
class SecondaryButton extends StatelessWidget {
  const SecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.onSheet = false,
  });

  final String label;
  final VoidCallback onPressed;

  /// True on a sheet, where a fill would read as another field.
  final bool onSheet;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: onSheet ? colors.transparent : colors.surface,
        foregroundColor: colors.onSurface,
        textStyle: context.bodyMdStrong,
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.component,
          vertical: Spacing.xxs,
        ),
        minimumSize: const Size(0, 32),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Rounded.pill),
        ),
        elevation: 0,
      ),
      child: Text(label),
    );
  }
}
