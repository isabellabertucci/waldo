import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waldo/core/theme/app_colors.dart';
import 'package:waldo/core/theme/app_theme.dart';
import 'package:waldo/core/widgets/month_selector.dart';
import 'package:waldo/core/widgets/stretch_pill.dart';
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

  for (final hintsScroll in [true, false]) {
    testWidgets('The left chevron nudges on first show only when asked to '
        '(hintsScroll: $hintsScroll)', (tester) async {
      tester.view.physicalSize = const Size(402, 874);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: MonthSelector(
              months: selectorMonths(DateTime(2026, 10, 8)),
              selectedMonth: DateTime(2026, 10),
              currentMonth: DateTime(2026, 10),
              locale: 'en',
              onSelect: (_) {},
              hintsScroll: hintsScroll,
            ),
          ),
        ),
      );
      await tester.pump();

      expect(tester.hasRunningAnimations, hintsScroll);
      await tester.pumpAndSettle();
    });
  }

  group('Chevrons pick the month next to the selected one', () {
    Future<List<DateTime>> pumpSelector(
      WidgetTester tester,
      DateTime selected,
    ) async {
      tester.view.physicalSize = const Size(402, 874);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final picked = <DateTime>[];
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: MonthSelector(
              months: selectorMonths(DateTime(2026, 10, 8)),
              selectedMonth: selected,
              currentMonth: DateTime(2026, 10),
              locale: 'en',
              onSelect: picked.add,
              hintsScroll: false,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      return picked;
    }

    testWidgets('The left one picks the month before', (tester) async {
      final picked = await pumpSelector(tester, DateTime(2026, 10));

      await tester.tap(find.byTooltip('Previous month'));
      expect(picked, [DateTime(2026, 9)]);
    });

    testWidgets('The right one picks the month after', (tester) async {
      final picked = await pumpSelector(tester, DateTime(2026, 9));

      await tester.tap(find.byTooltip('Next month'));
      expect(picked, [DateTime(2026, 10)]);
    });

    testWidgets('On the current month the right one does nothing: the '
        'future can\'t be picked', (tester) async {
      final picked = await pumpSelector(tester, DateTime(2026, 10));

      await tester.tap(find.byTooltip('Next month'));
      expect(picked, isEmpty);
    });
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

    for (final name in ['Previous month', 'Next month']) {
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

  testWidgets('The selected month\'s pill is painted under its Material, so a '
      'tap ripples over it', (tester) async {
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

    // A fill between the Material and the InkWell would hide the ink.
    final material = tester.widget<Material>(
      find
          .ancestor(of: find.text('October'), matching: find.byType(Material))
          .first,
    );
    expect(material.color, AppColors.light.transparent);
    final pill = tester.widget<StretchPill>(
      find.ancestor(
        of: find.text('October'),
        matching: find.byType(StretchPill),
      ),
    );
    expect(pill.color, AppColors.light.primary);
  });

  testWidgets('Picking another month clicks once; the picked one doesn\'t', (
    tester,
  ) async {
    final haptics = recordHaptics(tester);
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
    await tester.pumpAndSettle();

    await tester.tap(find.text('October'));
    expect(haptics, isEmpty);
    await tester.tap(find.text('Sep'));
    expect(haptics, ['HapticFeedbackType.selectionClick']);
  });
}
