import 'dart:ui' show CheckedState, Tristate;

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waldo/core/constants/db_constants.dart';
import 'package:waldo/features/transactions/models/transaction.dart';
import 'package:waldo/features/transactions/ui/widgets/transaction_edit_sheet.dart';
import 'package:waldo/features/transactions/ui/widgets/transaction_form_sheet.dart';

import '../helpers/golden_seed.dart';
import '../helpers/test_app.dart';

/// What screen readers would hear as plain text although a tap does
/// something: every tappable must also say it's a button (or a field,
/// switch, link...). A hand-made InkWell or GestureDetector misses it.
List<String> tappablesThatArentButtons() {
  bool hasRole(SemanticsData data) {
    final flags = data.flagsCollection;
    return flags.isButton ||
        flags.isTextField ||
        flags.isLink ||
        flags.isSlider ||
        flags.isChecked != CheckedState.none ||
        flags.isToggled != Tristate.none ||
        // The dark scrim behind a sheet; Flutter's own, tap to dismiss.
        data.label == 'Scrim';
  }

  return [
    for (final node in find.semantics.byPredicate((node) {
      final data = node.getSemanticsData();
      return data.hasAction(SemanticsAction.tap) && !hasRole(data);
    }).evaluate())
      node.label.isEmpty ? 'tooltip: ${node.tooltip}' : node.label,
  ];
}

void main() {
  /// Opens [open] from a button, over a database with a wallet, categories
  /// and two transactions.
  Future<void> pumpSheet(
    WidgetTester tester,
    void Function(BuildContext, Transaction) open,
  ) async {
    tester.view.physicalSize = const Size(402, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final db = await createTestDatabase();
    addTearDown(db.close);
    await seedGoldenData(db);
    final transaction = Transaction.fromMap(
      (await db.query(TransactionsTable.table, limit: 1)).first,
    );
    await pumpWidgetWithProviders(
      tester,
      Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () => open(context, transaction),
            child: const Text('open'),
          ),
        ),
      ),
      db: db,
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  final sheets = <String, void Function(BuildContext, Transaction)>{
    'new transaction sheet': (context, _) => showTransactionFormSheet(context),
    'transaction detail sheet': (context, t) =>
        showTransactionEditSheet(context, transaction: t),
    'transaction edit sheet': (context, t) => showTransactionEditSheet(
      context,
      transaction: t,
      startInEditMode: true,
    ),
  };

  for (final MapEntry(key: name, value: open) in sheets.entries) {
    testWidgets('Everything tappable in the $name is read as a button', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      await pumpSheet(tester, open);

      expect(tappablesThatArentButtons(), isEmpty);
      semantics.dispose();
    });
  }

  testWidgets('The selected category chip is read as selected', (tester) async {
    final semantics = tester.ensureSemantics();
    await pumpSheet(tester, (context, _) => showTransactionFormSheet(context));

    await tester.tap(find.text('Groceries'));
    await tester.pumpAndSettle();

    expect(
      tester.getSemantics(find.text('Groceries')),
      isSemantics(isButton: true, isSelected: true),
    );
    expect(
      tester.getSemantics(find.text('Education')),
      isSemantics(isButton: true, isSelected: false),
    );
    semantics.dispose();
  });
}
