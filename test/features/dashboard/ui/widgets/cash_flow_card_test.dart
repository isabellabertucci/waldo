import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waldo/core/constants/enums.dart';
import 'package:waldo/core/theme/motion.dart';
import 'package:waldo/core/utils/utils.dart';
import 'package:waldo/features/dashboard/models/dashboard_data.dart';
import 'package:waldo/features/dashboard/ui/widgets/cash_flow_card.dart';

import '../../../../helpers/test_app.dart';

final _october = DateTime(2026, 10);
final _september = DateTime(2026, 9);

/// Three months up to [month], spending [expense] cents in the last.
List<MonthlyCashFlow> _flows(DateTime month, {int expense = 1250}) => [
  for (var i = 2; i >= 0; i--)
    MonthlyCashFlow(
      month: DateTime(month.year, month.month - i),
      income: i == 0 ? 50000 : 0,
      expense: i == 0 ? expense : 0,
    ),
];

void main() {
  final shown = ValueNotifier((month: _october, flows: _flows(_october)));

  setUp(() => shown.value = (month: _october, flows: _flows(_october)));

  Future<void> pumpCard(
    WidgetTester tester, {
    bool hidden = false,
    bool reduceMotion = false,
  }) async {
    final db = await pumpWidgetWithProviders(
      tester,
      MediaQuery(
        data: MediaQueryData(disableAnimations: reduceMotion),
        child: Scaffold(
          body: ValueListenableBuilder(
            valueListenable: shown,
            builder: (context, shown, _) => CashFlowCard(
              month: shown.month,
              monthlyCashFlow: shown.flows,
              currency: Currency.eur,
              isBalanceHidden: hidden,
            ),
          ),
        ),
      ),
    );
    addTearDown(db.close);
  }

  /// Whether the line shows [fraction] of the way across.
  bool drawnTo(WidgetTester tester, double fraction) {
    final clip = find.descendant(
      of: find.byType(CashFlowCard),
      matching: find.byType(ClipPath),
    );
    final size = tester.getSize(clip);
    return tester
        .widget<ClipPath>(clip)
        .clipper!
        .getClip(size)
        .contains(Offset(size.width * fraction, 1));
  }

  double labelOpacity(WidgetTester tester, String text) => tester
      .widget<Opacity>(
        find.ancestor(of: find.text(text), matching: find.byType(Opacity)),
      )
      .opacity;

  testWidgets('Months with nothing stay on the zero line before a spike', (
    tester,
  ) async {
    shown.value = (
      month: _september,
      flows: [
        for (final month in [6, 7, 8])
          MonthlyCashFlow(month: DateTime(2026, month), income: 0, expense: 0),
        MonthlyCashFlow(month: _september, income: 0, expense: 50000),
      ],
    );
    await pumpCard(tester);

    final bars = tester.widget<LineChart>(find.byType(LineChart)).data;
    // A smooth curve otherwise dips below zero just before the spike.
    expect(bars.lineBarsData.single.preventCurveOverShooting, isTrue);
  });

  testWidgets('The line draws in from the left, then its end point pops and '
      'the month\'s total rises in', (tester) async {
    shown.value = (month: _september, flows: _flows(_september));
    await pumpCard(tester);

    shown.value = (month: _october, flows: _flows(_october));
    await tester.pump();
    await tester.pump(Motion.chartDraw ~/ 2);
    expect(drawnTo(tester, 0.1), isTrue);
    expect(drawnTo(tester, 0.9), isFalse);
    expect(labelOpacity(tester, '-€12.50'), 0);

    await tester.pump(Motion.chartDraw ~/ 2);
    expect(drawnTo(tester, 0.9), isTrue);
    await tester.pumpAndSettle();
    expect(labelOpacity(tester, '-€12.50'), 1);
  });

  testWidgets('New figures for the same month update the line without '
      'drawing it again; a new month draws its own', (tester) async {
    await pumpCard(tester);
    await tester.pumpAndSettle();

    shown.value = (month: _october, flows: _flows(_october, expense: 9900));
    await tester.pump();
    expect(drawnTo(tester, 0.9), isTrue);
    await tester.pumpAndSettle();
    expect(find.text('-€99.00'), findsOneWidget);

    shown.value = (month: _september, flows: _flows(_september));
    await tester.pump();
    expect(drawnTo(tester, 0.9), isFalse);
  });

  testWidgets('Scrolled away and back, the card doesn\'t draw again', (
    tester,
  ) async {
    final onScreen = ValueNotifier(true);
    final db = await pumpWidgetWithProviders(
      tester,
      Scaffold(
        body: ValueListenableBuilder(
          valueListenable: onScreen,
          builder: (context, onScreen, _) => onScreen
              ? CashFlowCard(
                  month: _october,
                  monthlyCashFlow: _flows(_october),
                  currency: Currency.eur,
                  isBalanceHidden: false,
                )
              : const SizedBox(),
        ),
      ),
    );
    addTearDown(db.close);

    onScreen.value = false;
    await tester.pump();
    onScreen.value = true;
    await tester.pump();
    expect(drawnTo(tester, 0.9), isTrue);
  });

  testWidgets('Switching to income reshapes the line where it is, with one '
      'click', (tester) async {
    final haptics = recordHaptics(tester);
    await pumpCard(tester);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Expense'));
    await tester.tap(find.text('Income'));
    await tester.pump();
    expect(drawnTo(tester, 0.9), isTrue);
    expect(
      tester.widget<LineChart>(find.byType(LineChart)).duration,
      Motion.chartMorph,
    );
    expect(haptics, ['HapticFeedbackType.selectionClick']);

    await tester.pumpAndSettle();
    expect(find.text('+€500.00'), findsOneWidget);
  });

  testWidgets('The month\'s total hides with the balance', (tester) async {
    await pumpCard(tester, hidden: true);
    await tester.pumpAndSettle();

    expect(find.text(hiddenAmount), findsOneWidget);
    expect(find.text('-€12.50'), findsNothing);
  });

  testWidgets('With reduce motion on, the line and its total are simply '
      'there', (tester) async {
    await pumpCard(tester, reduceMotion: true);

    expect(drawnTo(tester, 0.9), isTrue);
    expect(labelOpacity(tester, '-€12.50'), 1);
  });
}
