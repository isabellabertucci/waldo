import 'package:flutter/material.dart';
import 'package:waldo/core/theme/spacing.dart';

/// Keeps a page phone-width and centred on a tablet, instead of stretching
/// every card across the screen.
class PageWidth extends StatelessWidget {
  const PageWidth({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: Spacing.maxPageWidth),
        child: child,
      ),
    );
  }
}
