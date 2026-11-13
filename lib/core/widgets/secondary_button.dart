import 'package:flutter/material.dart';
import 'package:waldo/core/theme/component_size.dart';
import 'package:waldo/core/theme/app_theme.dart';
import 'package:waldo/core/theme/rounded.dart';
import 'package:waldo/core/theme/spacing.dart';

/// A small action inside a card or beside a title ("See all"): a light
/// green `accent` pill, as green marks details (DESIGN.md "Buttons").
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
        backgroundColor: colors.accent,
        foregroundColor: colors.onAccent,
        textStyle: context.bodyStrong,
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
