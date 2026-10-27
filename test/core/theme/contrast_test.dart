import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waldo/core/theme/app_colors.dart';

/// WCAG 2's contrast ratio between two opaque colours.
double contrast(Color a, Color b) {
  final (light, dark) = a.computeLuminance() > b.computeLuminance()
      ? (a, b)
      : (b, a);
  return (light.computeLuminance() + 0.05) / (dark.computeLuminance() + 0.05);
}

void main() {
  for (final (name, colors) in [
    ('light', AppColors.light),
    ('dark', AppColors.dark),
  ]) {
    group('In $name mode', () {
      // Text, placeholders included: 4.5:1 (WCAG 1.4.3, AA).
      final text = {
        'text on a card': (colors.onSurface, colors.surface),
        'text on the page': (colors.onSurface, colors.surfaceContainer),
        'secondary text on a card': (colors.onSurfaceVariant, colors.surface),
        'secondary text on the page': (
          colors.onSurfaceVariant,
          colors.surfaceContainer,
        ),
        'a primary button': (colors.onPrimary, colors.primary),
        'an orange button': (colors.onPrimary, colors.error),
        'an expense on a card': (colors.error, colors.surface),
        'an expense on the page': (colors.error, colors.surfaceContainer),
        'text on leather': (colors.onLeather, colors.leather),
      };
      for (final MapEntry(key: use, value: (fg, bg)) in text.entries) {
        test('$use reads at 4.5:1 or more', () {
          expect(contrast(fg, bg), greaterThanOrEqualTo(4.5));
        });
      }

      // An icon in its badge disc: 3:1 (WCAG 1.4.11).
      test('a badge icon reads at 3:1 or more on either disc', () {
        for (final disc in [colors.surface, colors.surfaceContainer]) {
          expect(contrast(colors.onSurfaceVariant, disc), greaterThan(3));
        }
      });
    });
  }
}
