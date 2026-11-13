import 'package:flutter/material.dart';
import 'package:waldo/core/theme/alpha.dart';
import 'package:waldo/core/theme/spacing.dart';
import 'package:waldo/core/theme/badge_size.dart';
import 'package:waldo/core/theme/icon_size.dart';

/// A tinted circle holding an icon: the confirm dialog's badge and the
/// transaction view's category badge. The room round it (where a dashed ring
/// once was) keeps it apart from the text beside it.
class TintedCircleBadge extends StatelessWidget {
  const TintedCircleBadge({super.key, required this.icon, required this.color});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      // A component gap of room round the disc.
      width: BadgeSize.xl + Spacing.component,
      height: BadgeSize.xl + Spacing.component,
      child: Center(
        child: Container(
          width: BadgeSize.xl,
          height: BadgeSize.xl,
          decoration: BoxDecoration(
            color: color.withValues(alpha: Alpha.soft),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: IconSize.xl, color: color),
        ),
      ),
    );
  }
}
