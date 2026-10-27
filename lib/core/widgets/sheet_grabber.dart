import 'package:flutter/material.dart';
import 'package:waldo/core/theme/alpha.dart';
import 'package:waldo/core/theme/component_size.dart';
import 'package:waldo/core/theme/app_theme.dart';
import 'package:waldo/core/theme/rounded.dart';

/// The short bar at the top of a bottom sheet, saying it can be dragged.
class SheetGrabber extends StatelessWidget {
  const SheetGrabber({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: ComponentSize.grabber.width,
        height: ComponentSize.grabber.height,
        decoration: BoxDecoration(
          color: context.appColors.onSurface.withValues(alpha: Alpha.soft),
          borderRadius: BorderRadius.circular(Rounded.pill),
        ),
      ),
    );
  }
}
