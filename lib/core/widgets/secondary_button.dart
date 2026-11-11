import 'package:flutter/material.dart';
import 'package:waldo/core/theme/alpha.dart';
import 'package:waldo/core/theme/component_size.dart';
import 'package:waldo/core/theme/app_theme.dart';
import 'package:waldo/core/theme/rounded.dart';
import 'package:waldo/core/theme/spacing.dart';

/// Low-emphasis text button beside a section or sheet title, on the same
/// faint grey fill as the month selector's arrows.
class SecondaryButton extends StatelessWidget {
  const SecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: colors.onSurface.withValues(alpha: Alpha.faint),
        foregroundColor: colors.onSurface,
        textStyle: context.bodyMdStrong,
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.component,
          vertical: Spacing.xxs,
        ),
        minimumSize: const Size(0, ComponentSize.compactButton),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Rounded.pill),
        ),
        elevation: 0,
      ),
      child: Text(label),
    );
  }
}
