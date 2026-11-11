import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waldo/core/utils/utils.dart';
import 'package:waldo/core/widgets/balance_amount.dart';

void main() {
  const amount = r'$1,234.00';

  Future<void> pump(
    WidgetTester tester, {
    required bool hidden,
    bool reduceMotion = false,
  }) {
    return tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(disableAnimations: reduceMotion),
          child: BalanceAmount(
            amount: amount,
            hidden: hidden,
            style: const TextStyle(),
          ),
        ),
      ),
    );
  }

  testWidgets('Opened already hidden, it shows the dots without animating', (
    tester,
  ) async {
    await pump(tester, hidden: true);

    expect(find.text(hiddenAmount), findsOneWidget);
    expect(find.text(amount), findsNothing);
    expect(tester.hasRunningAnimations, isFalse);
  });

  testWidgets('Hiding tucks the amount away, then only the dots are left', (
    tester,
  ) async {
    await pump(tester, hidden: false);
    await pump(tester, hidden: true);

    await tester.pump(const Duration(milliseconds: 100));
    expect(tester.hasRunningAnimations, isTrue);
    expect(find.text(amount), findsOneWidget, reason: 'still tucking away');

    await tester.pumpAndSettle();
    expect(find.text(hiddenAmount), findsOneWidget);
    // Gone from the tree, so a screen reader can't read it.
    expect(find.text(amount), findsNothing);
  });

  testWidgets('Toggled quickly back and forth, one of the two is left', (
    tester,
  ) async {
    await pump(tester, hidden: false);
    for (final hidden in [true, false, true]) {
      await pump(tester, hidden: hidden);
      await tester.pump(const Duration(milliseconds: 50));
    }

    await tester.pumpAndSettle();
    expect(find.text(hiddenAmount), findsOneWidget);
    expect(find.text(amount), findsNothing);
  });

  testWidgets('With reduce motion on, the switch is instant', (tester) async {
    await pump(tester, hidden: false, reduceMotion: true);
    await pump(tester, hidden: true, reduceMotion: true);
    await tester.pump();

    expect(tester.hasRunningAnimations, isFalse);
    expect(find.text(amount), findsNothing);
    expect(find.text(hiddenAmount), findsOneWidget);
  });
}
