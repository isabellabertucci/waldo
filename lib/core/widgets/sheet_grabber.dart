import 'package:flutter/material.dart';
import 'package:waldo/core/theme/app_theme.dart';
import 'package:waldo/core/theme/rounded.dart';

const _width = 36.0;
const _height = 4.0;

/// The short bar at the top of a bottom sheet, saying it can be dragged.
class SheetGrabber extends StatelessWidget {
  const SheetGrabber({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: _width,
        height: _height,
        decoration: BoxDecoration(
          color: context.appColors.onSurface.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(Rounded.pill),
        ),
      ),
    );
  }
}
