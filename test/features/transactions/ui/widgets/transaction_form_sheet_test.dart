import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:waldo/features/transactions/ui/widgets/transaction_form_sheet.dart';

import '../../../../helpers/test_app.dart';

void main() {
  testWidgets('The "New" chip is as tall as the category chips', (
    tester,
  ) async {
    final db = await pumpWidgetWithProviders(
      tester,
      Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () => showTransactionFormSheet(context),
            child: const Text('open'),
          ),
        ),
      ),
    );
    addTearDown(db.close);
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    double chipHeight(String label) => tester
        .getSize(
          find.ancestor(of: find.text(label), matching: find.byType(InkWell)),
        )
        .height;

    expect(chipHeight('New'), chipHeight('Education'));
  });
}
