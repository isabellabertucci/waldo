import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waldo/core/theme/spacing.dart';
import 'package:waldo/core/widgets/page_width.dart';

void main() {
  Future<Rect> pumpAt(WidgetTester tester, double width) async {
    tester.view.physicalSize = Size(width, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: PageWidth(child: SizedBox.expand(key: Key('page'))),
      ),
    );
    return tester.getRect(find.byKey(const Key('page')));
  }

  testWidgets('On a tablet the page stays phone-width and centred', (
    tester,
  ) async {
    final page = await pumpAt(tester, 1376);

    expect(page.width, Spacing.maxPageWidth);
    expect(page.center.dx, 1376 / 2);
    expect(page.top, 0);
  });

  testWidgets('On a phone the page fills the width', (tester) async {
    final page = await pumpAt(tester, 402);

    expect(page.width, 402);
  });
}
