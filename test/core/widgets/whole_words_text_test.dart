import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waldo/core/widgets/whole_words_text.dart';

void main() {
  // The test font draws every letter as a square as wide as the font size,
  // on lines exactly one font size tall.
  int lines(RenderParagraph paragraph, double fontSize) =>
      (paragraph.size.height / paragraph.textScaler.scale(fontSize)).round();

  Future<RenderParagraph> pump(
    WidgetTester tester,
    Widget text, {
    double textScale = 1,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
          child: Center(child: SizedBox(width: 200, child: text)),
        ),
      ),
    );
    return tester.renderObject<RenderParagraph>(find.byType(RichText));
  }

  testWidgets('A word wider than the line shrinks instead of breaking', (
    tester,
  ) async {
    // 12 letters at 40 = 480 wide, in a 200 wide box.
    final paragraph = await pump(
      tester,
      const WholeWordsText('Supermercado', style: TextStyle(fontSize: 40)),
    );

    expect(lines(paragraph, 40), 1);
    expect(paragraph.size.width, lessThanOrEqualTo(200));
  });

  testWidgets('Words that fit keep their size and wrap between words', (
    tester,
  ) async {
    final paragraph = await pump(
      tester,
      const WholeWordsText('ab cd ef gh', style: TextStyle(fontSize: 40)),
    );

    expect(paragraph.textScaler.scale(40), 40);
    expect(lines(paragraph, 40), greaterThan(1));
  });

  testWidgets('singleLine is one cut line, and wraps at accessibility sizes', (
    tester,
  ) async {
    const text = WholeWordsText.singleLine(
      'ab cd ef gh ij',
      style: TextStyle(fontSize: 20),
    );

    final normal = await pump(tester, text);
    expect(normal.maxLines, 1);
    expect(normal.overflow, TextOverflow.ellipsis);

    final large = await pump(tester, text, textScale: 2);
    expect(large.maxLines, isNull);
    expect(lines(large, 20), greaterThan(1));
  });
}
