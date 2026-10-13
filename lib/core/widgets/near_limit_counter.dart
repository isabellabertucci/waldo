import 'package:flutter/material.dart';
import 'package:waldo/core/theme/app_theme.dart';

/// A [TextField.buildCounter] that stays hidden until the text reaches 80% of
/// `maxLength`, then shows "87/100" - in `error` once the limit stops typing.
Widget? nearLimitCounter(
  BuildContext context, {
  required int currentLength,
  required int? maxLength,
  required bool isFocused,
}) {
  if (maxLength == null || currentLength < maxLength * 0.8) return null;
  final colors = context.appColors;
  return Text(
    '$currentLength/$maxLength',
    style: context.textTheme.bodySmall?.copyWith(
      color: currentLength >= maxLength
          ? colors.error
          : colors.onSurfaceVariant,
    ),
  );
}
