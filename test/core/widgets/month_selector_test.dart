import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waldo/core/theme/app_theme.dart';
import 'package:waldo/core/widgets/month_selector.dart';
import 'package:waldo/l10n/app_localizations.dart';

import '../../helpers/test_app.dart';

void main() {
  testWidgets('Only the selected month is spelled out; months from another '
      'year show the year, so none repeat', (tester) async {
    // October 2026: the row runs from November 2025 to November 2026.
    final months = selectorMonths(DateTime(2026, 10, 8));
    final db = await pumpWidgetWithProviders(
      tester,
      Scaffold(
        body: MonthSelector(
          months: months,
          selectedMonth: DateTime(2026, 10),
          currentMonth: DateTime(2026, 10),
          locale: 'en',
          onSelect: (_) {},
        ),
      ),
    );
    addTearDown(db.close);

    expect(find.text('October'), findsOneWidget); // selected: full name
    expect(find.text('Sep'), findsOneWidget); // neighbours: short
    expect(find.text('Nov'), findsOneWidget); // next November, this year
    expect(find.text('Nov 2025'), findsOneWidget); // last November
  });

  testWidgets('Screen readers hear which month is selected, and that next '
      'month is off', (tester) async {
    final semantics = tester.ensureSemantics();
    final db = await pumpWidgetWithProviders(
      tester,
      Scaffold(
        body: MonthSelector(
          months: selectorMonths(DateTime(2026, 10, 8)),
          selectedMonth: DateTime(2026, 10),
          currentMonth: DateTime(2026, 10),
          locale: 'en',
          onSelect: (_) {},
        ),
      ),
    );
    addTearDown(db.close);

    expect(
      tester.getSemantics(find.text('October')),
      isSemantics(isButton: true, isSelected: true, isEnabled: true),
    );
    expect(
      tester.getSemantics(find.text('Sep')),
      isSemantics(isButton: true, isSelected: false, isEnabled: true),
    );
    expect(
      tester.getSemantics(find.text('Nov')),
      isSemantics(isButton: true, isEnabled: false),
    );
    semantics.dispose();
  });

  testWidgets('When the text size changes the selected month stays centred', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(402, 874);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    final db = await pumpWidgetWithProviders(
      tester,
      Scaffold(
        body: MonthSelector(
          months: selectorMonths(DateTime(2026, 10, 8)),
          selectedMonth: DateTime(2026, 10),
          currentMonth: DateTime(2026, 10),
          locale: 'en',
          onSelect: (_) {},
        ),
      ),
    );
    addTearDown(db.close);
    final rowCentre = tester.getCenter(find.byType(Scrollable)).dx;
    expect(tester.getCenter(find.text('October')).dx, closeTo(rowCentre, 1));

    // Changed in the phone's settings while the app is open.
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    await tester.pumpAndSettle();

    expect(tester.getCenter(find.text('October')).dx, closeTo(rowCentre, 1));
  });

  testWidgets('In January, last December shows its year and next February '
      'does not', (tester) async {
    // The dashboard's list: 12 months back from January 2027, plus one.
    final months = selectorMonths(DateTime(2027, 1, 15));
    expect(months.first, DateTime(2026, 2));
    expect(months.last, DateTime(2027, 2));

    final db = await pumpWidgetWithProviders(
      tester,
      Scaffold(
        body: MonthSelector(
          months: months,
          selectedMonth: DateTime(2027, 1),
          currentMonth: DateTime(2027, 1),
          locale: 'en',
          onSelect: (_) {},
        ),
      ),
    );
    addTearDown(db.close);

    expect(find.text('January'), findsOneWidget);
    expect(find.text('Dec 2026'), findsOneWidget);
    expect(find.text('Feb'), findsOneWidget); // next month, this year
  });

  testWidgets('Dragging past the current month snaps back to it, so no '
      'month is left half-cut', (tester) async {
    tester.view.physicalSize = const Size(402, 874);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final months = selectorMonths(DateTime(2026, 10, 8));
    final db = await pumpWidgetWithProviders(
      tester,
      Scaffold(
        body: MonthSelector(
          months: months,
          selectedMonth: DateTime(2026, 10),
          currentMonth: DateTime(2026, 10),
          locale: 'en',
          onSelect: (_) {},
        ),
      ),
    );
    addTearDown(db.close);
    await tester.pumpAndSettle();

    await tester.drag(find.text('October'), const Offset(-300, 0));
    await tester.pumpAndSettle();

    final center = tester.getCenter(find.text('October')).dx;
    final rowCenter = tester.getCenter(find.byType(SingleChildScrollView)).dx;
    expect(center, moreOrLessEquals(rowCenter, epsilon: 1));
  });

  testWidgets('Opens already centred on the selected month, with no scroll '
      'animation', (tester) async {
    tester.view.physicalSize = const Size(402, 874);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final months = selectorMonths(DateTime(2026, 10, 8));
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: MonthSelector(
            months: months,
            selectedMonth: DateTime(2026, 10),
            currentMonth: DateTime(2026, 10),
            locale: 'en',
            onSelect: (_) {},
          ),
        ),
      ),
    );
    // One frame after the first layout: an animation would barely have started.
    await tester.pump();

    final center = tester.getCenter(find.text('October')).dx;
    final rowCenter = tester.getCenter(find.byType(SingleChildScrollView)).dx;
    expect(center, moreOrLessEquals(rowCenter, epsilon: 1));
  });

  testWidgets('Both chevrons are named 48dp buttons, and so are the months', (
    tester,
  ) async {
    final months = [for (var i = 11; i >= 0; i--) DateTime(2026, 10 - i)];
    final db = await pumpWidgetWithProviders(
      tester,
      Scaffold(
        body: MonthSelector(
          months: months,
          selectedMonth: DateTime(2026, 10),
          currentMonth: DateTime(2026, 10),
          locale: 'en',
          onSelect: (_) {},
        ),
      ),
    );
    addTearDown(db.close);

    for (final name in ['Earlier months', 'Later months']) {
      final chevron = find.byTooltip(name);
      expect(chevron, findsOneWidget);
      expect(tester.getSize(chevron).shortestSide, greaterThanOrEqualTo(48));
    }
    expect(
      tester.getSize(find.text('October')).height,
      lessThan(48),
      reason: 'the label alone is small...',
    );
    final pill = find.ancestor(
      of: find.text('October'),
      matching: find.byType(InkWell),
    );
    expect(
      tester.getSize(pill.first).height,
      greaterThanOrEqualTo(48),
      reason: '...but the pill around it is a full tap target',
    );
  });
}
