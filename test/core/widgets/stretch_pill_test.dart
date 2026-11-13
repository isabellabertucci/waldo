import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waldo/core/theme/motion.dart';
import 'package:waldo/core/widgets/stretch_pill.dart';

import '../../helpers/test_app.dart';

void main() {
  final keys = List.generate(3, (_) => GlobalKey());
  final selected = ValueNotifier(0);

  setUp(() => selected.value = 0);

  Future<void> pumpRow(WidgetTester tester, {bool reduceMotion = false}) {
    return tester.pumpWidget(
      MediaQuery(
        data: MediaQueryData(disableAnimations: reduceMotion),
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: Align(
            alignment: Alignment.topLeft,
            child: ValueListenableBuilder(
              valueListenable: selected,
              builder: (context, index, _) => StretchPill(
                selectedKey: keys[index],
                color: const Color(0xFF000000),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (final key in keys)
                      Padding(
                        padding: const EdgeInsets.only(right: 20),
                        child: SizedBox(key: key, width: 60, height: 40),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Rect itemRect(WidgetTester tester, int index) =>
      tester.getRect(find.byKey(keys[index]));

  final lead = Motion.pillStretch * Motion.pillStretchLead;

  testWidgets('At rest the pill sits on the selected item', (tester) async {
    await pumpRow(tester);

    expect(paintedStretchPill(tester), itemRect(tester, 0));
  });

  testWidgets('Moving right, the front edge gets there first and the back '
      'edge catches up', (tester) async {
    await pumpRow(tester);

    selected.value = 2;
    await tester.pump();
    await tester.pump(lead);
    // Like a drop of ink: it covers both items at once.
    final midway = paintedStretchPill(tester);
    expect(midway.left, moreOrLessEquals(itemRect(tester, 0).left));
    expect(midway.right, moreOrLessEquals(itemRect(tester, 2).right));

    await tester.pumpAndSettle();
    expect(paintedStretchPill(tester), itemRect(tester, 2));
  });

  testWidgets('Moving left, the left edge leads', (tester) async {
    selected.value = 2;
    await pumpRow(tester);

    selected.value = 0;
    await tester.pump();
    await tester.pump(lead);
    final midway = paintedStretchPill(tester);
    expect(midway.left, moreOrLessEquals(itemRect(tester, 0).left));
    expect(midway.right, moreOrLessEquals(itemRect(tester, 2).right));

    await tester.pumpAndSettle();
    expect(paintedStretchPill(tester), itemRect(tester, 0));
  });

  testWidgets('A new pick mid-stretch starts from where the pill is, without '
      'a jump', (tester) async {
    await pumpRow(tester);

    selected.value = 2;
    await tester.pump();
    await tester.pump(Motion.pillStretch ~/ 2);
    final before = paintedStretchPill(tester);

    selected.value = 1;
    await tester.pump();
    expect(paintedStretchPill(tester), before);

    await tester.pumpAndSettle();
    expect(paintedStretchPill(tester), itemRect(tester, 1));
  });

  testWidgets('With reduce motion on, the pill is on the new item at once', (
    tester,
  ) async {
    await pumpRow(tester, reduceMotion: true);

    selected.value = 2;
    await tester.pump();
    await tester.pump();
    expect(paintedStretchPill(tester), itemRect(tester, 2));
  });
}
