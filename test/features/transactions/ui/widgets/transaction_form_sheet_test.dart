import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:waldo/core/constants/app_constants.dart';
import 'package:waldo/features/transactions/ui/widgets/transaction_form_sheet.dart';

import '../../../../helpers/test_app.dart';

void main() {
  Future<void> openSheet(WidgetTester tester) async {
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
  }

  testWidgets('The "New" chip is as tall as the category chips', (
    tester,
  ) async {
    await openSheet(tester);

    double chipHeight(String label) => tester
        .getSize(
          find.ancestor(of: find.text(label), matching: find.byType(InkWell)),
        )
        .height;

    expect(chipHeight('New'), chipHeight('Education'));
  });

  testWidgets('The category section says it is optional', (tester) async {
    await openSheet(tester);
    expect(find.textContaining('Optional', findRichText: true), findsOneWidget);
  });

  testWidgets('The description stops at the limit and shows a counter near '
      'it', (tester) async {
    await openSheet(tester);
    final field = find.byKey(const Key('transactionDescriptionField'));

    await tester.enterText(field, 'a' * 20);
    await tester.pump();
    expect(find.textContaining('/100'), findsNothing);

    await tester.enterText(field, 'a' * 120);
    await tester.pump();
    expect(
      tester
          .widget<EditableText>(
            find.descendant(of: field, matching: find.byType(EditableText)),
          )
          .controller
          .text
          .length,
      maxTransactionDescriptionLength,
    );
    expect(find.text('100/100'), findsOneWidget);
  });
}
