import 'package:flutter/material.dart';
import 'package:waldo/core/theme/app_colors.dart';

/// How a state looks, from one place, so every picked option and every
/// focused field change together (DESIGN.md "States"). The line is ink
/// (`primary`), from the palette and far past the 3:1 a state's outline
/// needs (WCAG 1.4.11): the light green on cream has only 1.3:1. The
/// filled marks are the light green, with ink on them.
abstract final class StateStyle {
  static const borderWidth = 2.0;

  /// The line round a picked option. There at rest too, clear, so picking
  /// doesn't shift what's inside.
  static BorderSide picked(AppColors colors, {required bool selected}) =>
      BorderSide(
        color: selected ? colors.ink : colors.transparent,
        width: borderWidth,
      );

  /// A picked option's marks (its disc, its tick) and what's drawn on them.
  static Color pickedFill(AppColors colors) => colors.accent;
  static Color onPickedFill(AppColors colors) => colors.onAccent;

  /// The line round the field being typed in. There at rest too, clear, so
  /// focusing doesn't shift the text; the label over the field says where
  /// it is.
  static BorderSide focused(AppColors colors, {required bool focused}) =>
      BorderSide(
        color: focused ? colors.ink : colors.transparent,
        width: borderWidth,
      );
}
