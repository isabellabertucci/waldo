import 'dart:ui' show CheckedState, Tristate;

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waldo/core/constants/db_constants.dart';
import 'package:waldo/core/widgets/dashed_stitch_button.dart';
import 'package:waldo/features/categories/ui/categories_screen.dart';
import 'package:waldo/features/dashboard/ui/dashboard_screen.dart';
import 'package:waldo/features/settings/ui/settings_screen.dart';
import 'package:waldo/features/transactions/ui/all_transactions_screen.dart';
import 'package:waldo/features/transactions/ui/transactions_screen.dart';
import 'package:waldo/features/transactions/models/transaction.dart';
import 'package:waldo/features/transactions/ui/widgets/transaction_edit_sheet.dart';
import 'package:waldo/features/transactions/ui/widgets/transaction_form_sheet.dart';
import 'package:waldo/features/wallets/models/wallet.dart';
import 'package:waldo/features/wallets/ui/wallets_screen.dart';

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

  /// A field read with its visible label, not just its example text.
  void expectNamed(WidgetTester tester, String key, String label) {
    final node = tester.getSemantics(find.byKey(Key(key)));
    expect(node.flagsCollection.isTextField, isTrue);
    expect(node.label, startsWith(label));
  }

  testWidgets('The new wallet fields are read with their labels', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    final db = await createTestDatabase();
    addTearDown(db.close);
    await pumpWidgetWithProviders(tester, const WalletsScreen(), db: db);
    await tester.tap(find.byType(DashedStitchButton));
    await tester.pumpAndSettle();

    expectNamed(tester, 'walletNameField', 'Name, required');
    expectNamed(tester, 'walletBalanceField', 'How much is in it today?');
    semantics.dispose();
  });

  testWidgets('The new category field is read with its label', (tester) async {
    final semantics = tester.ensureSemantics();
    final db = await pumpWidgetWithProviders(tester, const CategoriesScreen());
    addTearDown(db.close);

    expectNamed(tester, 'categoryNameField', 'New category');
    semantics.dispose();
  });

  testWidgets('The new transaction fields are read with their labels', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await pumpSheet(tester, (context, _) => showTransactionFormSheet(context));

    expectNamed(tester, 'transactionAmountField', 'Amount, required');
    expectNamed(tester, 'transactionDescriptionField', 'Title');
    semantics.dispose();
  });

  testWidgets('The transaction edit fields are read with their labels', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await pumpSheet(tester, sheets['transaction edit sheet']!);

    expectNamed(tester, 'txNameField', 'Title');
    expectNamed(tester, 'txNoteField', 'Note');
    // An empty note gives an example, not its label again.
    expect(
      tester.getSemantics(find.byKey(const Key('txNoteField'))).label,
      'Note\nAnything to remember?',
    );
    semantics.dispose();
  });

  testWidgets('The transaction detail sheet reads each label with its value', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await pumpSheet(tester, sheets['transaction detail sheet']!);

    expect(
      tester.getSemantics(find.text('Paycheck')).label,
      'Paycheck\nGroceries · Income',
    );
    for (final label in ['Amount', 'Date', 'Wallet', 'Note']) {
      // The label and its value share one node, so it's more than the label.
      expect(
        tester.getSemantics(find.text(label)).label,
        startsWith('$label\n'),
      );
    }
    semantics.dispose();
  });

  for (final MapEntry(key: name, value: screen) in const {
    'dashboard': DashboardScreen(),
    'transaction list': AllTransactionsScreen(),
  }.entries) {
    testWidgets('A transaction row on the $name is read as a button', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      tester.view.physicalSize = const Size(402, 1400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final db = await createTestDatabase();
      addTearDown(db.close);
      await seedGoldenData(db);
      await pumpWidgetWithProviders(tester, screen, db: db);

      final row = tester.getSemantics(find.text('Weekly groceries'));
      expect(row.flagsCollection.isButton, isTrue);
      // Only the row itself, not the section or day heading above it.
      expect(row.label, startsWith('Weekly groceries'));
      semantics.dispose();
    });
  }

  testWidgets('Section and day titles are headings, apart from the rows', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    tester.view.physicalSize = const Size(402, 3000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final db = await createTestDatabase();
    addTearDown(db.close);
    await seedGoldenData(db);
    await pumpWidgetWithProviders(tester, const DashboardScreen(), db: db);

    for (final title in ['Recent transactions', 'Cash flow']) {
      expect(
        tester.getSemantics(find.text(title)),
        isSemantics(label: title, isHeader: true),
      );
    }

    await tester.pumpWidget(const SizedBox());
    await pumpWidgetWithProviders(
      tester,
      const AllTransactionsScreen(),
      db: db,
    );
    final day = find.textContaining(RegExp(r'^[A-Z]{3} \d+ [A-Z]{3}$'));
    expect(day, findsWidgets);
    for (final e in day.evaluate()) {
      final node = tester.getSemantics(find.byWidget(e.widget));
      expect(node.flagsCollection.isHeader, isTrue);
      expect(node.label, (e.widget as Text).data);
    }
    semantics.dispose();
  });

  testWidgets('Every screen title is a heading', (tester) async {
    final semantics = tester.ensureSemantics();
    final db = await createTestDatabase();
    addTearDown(db.close);
    await seedGoldenData(db);
    final wallet = Wallet.fromMap(
      (await db.query(WalletsTable.table, limit: 1)).first,
    );

    for (final (screen, title) in [
      (const WalletsScreen(), 'Wallets'),
      (const SettingsScreen(), 'Settings'),
      (const CategoriesScreen(), 'Categories'),
      (TransactionsScreen(walletId: wallet.id!), wallet.name),
    ]) {
      await tester.pumpWidget(const SizedBox());
      await pumpWidgetWithProviders(tester, screen, db: db);

      expect(
        tester.getSemantics(find.text(title).first),
        isSemantics(label: title, isHeader: true),
        reason: title,
      );
    }
    semantics.dispose();
  });

  testWidgets('Settings group names are headings', (tester) async {
    final semantics = tester.ensureSemantics();
    tester.view.physicalSize = const Size(402, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final db = await pumpWidgetWithProviders(tester, const SettingsScreen());
    addTearDown(db.close);

    for (final group in ['MONEY', 'APPEARANCE']) {
      expect(
        tester.getSemantics(find.text(group)),
        isSemantics(label: group, isHeader: true),
      );
    }
    semantics.dispose();
  });
}
