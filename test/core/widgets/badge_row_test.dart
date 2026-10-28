import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waldo/core/widgets/badge_row.dart';

void main() {
  Future<void> pump(WidgetTester tester, double textScale) {
    return tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
          child: const Center(
            child: BadgeRow(
              badge: SizedBox.square(key: Key('badge'), dimension: 24),
              trailing: SizedBox.square(key: Key('trailing'), dimension: 24),
              child: Text('Label', key: Key('text')),
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('The badge sits beside the text', (tester) async {
    await pump(tester, 1);

    final badge = tester.getRect(find.byKey(const Key('badge')));
    final text = tester.getRect(find.byKey(const Key('text')));
    expect(badge.right, lessThanOrEqualTo(text.left));
  });

  testWidgets('At accessibility sizes the badge moves above the text', (
    tester,
  ) async {
    await pump(tester, 2);

    final badge = tester.getRect(find.byKey(const Key('badge')));
    final text = tester.getRect(find.byKey(const Key('text')));
    final trailing = tester.getRect(find.byKey(const Key('trailing')));
    expect(badge.bottom, lessThanOrEqualTo(text.top));
    expect(badge.left, text.left);
    expect(trailing.left, greaterThanOrEqualTo(text.right));
  });
}
