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
        'text on a card': (colors.ink, colors.sheet),
        'text on the page': (colors.ink, colors.bg),
        'secondary text on a card': (colors.inkMuted, colors.sheet),
        'secondary text on the page': (colors.inkMuted, colors.bg),
        'a primary button': (colors.onInk, colors.ink),
        'an orange button': (colors.onInk, colors.negative),
        'an expense on a card': (colors.negative, colors.sheet),
        'an expense on the page': (colors.negative, colors.bg),
        'text on leather': (colors.onLeather, colors.leather),
      };
      for (final MapEntry(key: use, value: (fg, bg)) in text.entries) {
        test('$use reads at 4.5:1 or more', () {
          expect(contrast(fg, bg), greaterThanOrEqualTo(4.5));
        });
      }

      // An icon in its badge disc: 3:1 (WCAG 1.4.11).
      test('a badge icon reads at 3:1 or more on either disc', () {
        for (final disc in [colors.sheet, colors.bg]) {
          expect(contrast(colors.inkMuted, disc), greaterThan(3));
        }
      });
    });
  }
}
