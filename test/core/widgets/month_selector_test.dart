import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waldo/core/widgets/month_selector.dart';

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
}
