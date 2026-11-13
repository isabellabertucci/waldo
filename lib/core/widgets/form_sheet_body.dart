import 'package:flutter/material.dart';
import 'package:waldo/core/theme/spacing.dart';

/// A form sheet's content. It scrolls when it's taller than the sheet, and
/// the room at the bottom (keyboard, home indicator) is inside the scroll,
/// so the last button scrolls fully into view instead of being cut.
class FormSheetBody extends StatelessWidget {
  const FormSheetBody({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        Spacing.md,
        Spacing.sm,
        Spacing.md,
        MediaQuery.viewInsetsOf(context).bottom +
            MediaQuery.paddingOf(context).bottom +
            Spacing.md,
      ),
      child: child,
    );
  }
}
