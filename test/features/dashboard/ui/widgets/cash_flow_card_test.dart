import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waldo/core/constants/enums.dart';
import 'package:waldo/features/dashboard/models/dashboard_data.dart';
import 'package:waldo/features/dashboard/ui/widgets/cash_flow_card.dart';

import '../../../../helpers/test_app.dart';

void main() {
  testWidgets('Months with nothing stay on the zero line before a spike', (
    tester,
  ) async {
    final db = await pumpWidgetWithProviders(
      tester,
      Scaffold(
        body: CashFlowCard(
          monthlyCashFlow: [
            for (final month in [6, 7, 8])
              MonthlyCashFlow(
                month: DateTime(2026, month),
                income: 0,
                expense: 0,
              ),
            MonthlyCashFlow(
              month: DateTime(2026, 9),
              income: 0,
              expense: 50000,
            ),
          ],
          currency: Currency.eur,
          isBalanceHidden: false,
        ),
      ),
    );
    addTearDown(db.close);

    final bars = tester.widget<LineChart>(find.byType(LineChart)).data;
    // A smooth curve otherwise dips below zero just before the spike.
    expect(bars.lineBarsData.single.preventCurveOverShooting, isTrue);
  });
}
