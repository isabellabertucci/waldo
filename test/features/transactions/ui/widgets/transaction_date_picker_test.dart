import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:waldo/features/transactions/ui/widgets/transaction_date_picker.dart';

void main() {
  final now = DateTime(2026, 10, 26, 15, 30);

  Future<DatePickerDialog> openPicker(
    WidgetTester tester,
    DateTime initialDate,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () => showTransactionDatePicker(
              context,
              initialDate: initialDate,
              now: now,
            ),
            child: const Text('open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    return tester.widget<DatePickerDialog>(find.byType(DatePickerDialog));
  }

  testWidgets('Stops at today, since later months cannot be shown', (
    tester,
  ) async {
    final dialog = await openPicker(tester, now);
    expect(dialog.lastDate, DateTime(2026, 10, 26));
  });

  testWidgets('Still opens on a date saved after today', (tester) async {
    final dialog = await openPicker(tester, DateTime(2026, 12, 1));
    expect(dialog.lastDate, DateTime(2026, 12, 1));
  });
}
