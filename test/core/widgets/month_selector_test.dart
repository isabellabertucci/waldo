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
    final months = [
      for (var i = 11; i >= 0; i--) DateTime(2026, 10 - i),
      DateTime(2026, 11),
    ];
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

  testWidgets('Dragging past the current month snaps back to it, so no '
      'month is left half-cut', (tester) async {
    tester.view.physicalSize = const Size(402, 874);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final months = [
      for (var i = 11; i >= 0; i--) DateTime(2026, 10 - i),
      DateTime(2026, 11),
    ];
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
    final months = [
      for (var i = 11; i >= 0; i--) DateTime(2026, 10 - i),
      DateTime(2026, 11),
    ];
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
}
