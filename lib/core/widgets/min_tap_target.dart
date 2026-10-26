import 'package:flutter/material.dart';

/// Grows a small control's touch area to the 48px minimum (Material's; Apple
/// asks for 44pt) without changing how it looks: a tap in the margin around
/// [child] still runs [onTap]. Put the control's `Semantics` outside this, so
/// screen readers focus the whole area too.
class MinTapTarget extends StatelessWidget {
  const MinTapTarget({super.key, required this.onTap, required this.child});

  final VoidCallback? onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      // The control inside already gives screen readers its tap.
      excludeFromSemantics: true,
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minWidth: kMinInteractiveDimension,
          minHeight: kMinInteractiveDimension,
        ),
        child: Center(widthFactor: 1, heightFactor: 1, child: child),
      ),
    );
  }
}
