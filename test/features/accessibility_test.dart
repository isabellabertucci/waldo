import 'dart:ui' show CheckedState, SemanticsRole, Tristate;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:waldo/features/dashboard/ui/widgets/cash_flow_card.dart';
import 'package:waldo/features/dashboard/models/dashboard_data.dart';
import 'package:waldo/core/constants/enums.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waldo/core/constants/db_constants.dart';
import 'package:waldo/features/wallets/ui/widgets/wallet_form_sheet.dart';
import 'package:waldo/features/transactions/ui/widgets/transaction_filter_sheet.dart';
import 'package:waldo/features/transactions/models/transaction_filter.dart';
import 'package:waldo/core/widgets/confirmation_dialog.dart';
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

  /// Each text is its own heading node (or, for a merged title, part of one).
  void expectHeadings(WidgetTester tester, List<String> texts) {
    for (final text in texts) {
      expect(
        tester.getSemantics(find.textContaining(text).first),
        isSemantics(isHeader: true),
        reason: text,
      );
    }
  }

  final sheetHeadings =
      <String, (void Function(BuildContext, Transaction), List<String>)>{
        'new transaction sheet': (
          sheets['new transaction sheet']!,
          ['New transaction', 'CATEGORY'],
        ),
        'transaction edit sheet': (
          sheets['transaction edit sheet']!,
          ['Edit transaction'],
        ),
        'new wallet sheet': (
          (context, _) => showWalletFormSheet(context),
          ['New wallet', 'TYPE', 'STARTING BALANCE'],
        ),
        'filter sheet': (
          (context, _) => showModalBottomSheet<void>(
            context: context,
            builder: (_) => TransactionFilterSheet(
              initial: TransactionFilter(month: DateTime(2026, 10)),
              locale: 'en',
              now: DateTime(2026, 10, 22),
              countForFilter: (_) => 0,
            ),
          ),
          ['Filter', 'TYPE', 'MONTH'],
        ),
      };
  for (final MapEntry(key: name, value: (open, headings))
      in sheetHeadings.entries) {
    testWidgets('The $name title and section labels are headings', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      await pumpSheet(tester, open);

      expectHeadings(tester, headings);
      semantics.dispose();
    });
  }

  testWidgets('"Optional" is read with its section heading', (tester) async {
    final semantics = tester.ensureSemantics();
    await pumpSheet(tester, (context, _) => showWalletFormSheet(context));

    expect(
      tester.getSemantics(find.text('STARTING BALANCE')).label,
      'STARTING BALANCE\nOptional',
    );
    semantics.dispose();
  });

  testWidgets('The detail title is one heading with its category and type', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await pumpSheet(tester, sheets['transaction detail sheet']!);

    expect(
      tester.getSemantics(find.text('Paycheck')),
      isSemantics(label: 'Paycheck\nGroceries · Income', isHeader: true),
    );
    semantics.dispose();
  });

  testWidgets('On Android the delete dialog is announced as an alert, with '
      'its title apart', (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    final semantics = tester.ensureSemantics();
    await pumpSheet(
      tester,
      (context, _) => ConfirmationDialog.show(
        context,
        title: 'Delete category?',
        content: 'This will delete "Education".',
        confirmLabel: 'Delete',
      ),
    );

    expect(
      find.semantics.byPredicate(
        (node) =>
            node.label == 'Alert' &&
            node.flagsCollection.scopesRoute &&
            node.flagsCollection.namesRoute,
      ),
      findsOne,
    );
    expect(
      tester.getSemantics(find.text('Delete category?')).label,
      'Delete category?',
    );
    semantics.dispose();
    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets('A settings picker title is a heading', (tester) async {
    final semantics = tester.ensureSemantics();
    tester.view.physicalSize = const Size(402, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final db = await pumpWidgetWithProviders(tester, const SettingsScreen());
    addTearDown(db.close);
    await tester.tap(find.text('Theme'));
    await tester.pumpAndSettle();
    expect(
      tester.getSemantics(find.text('Theme').last),
      isSemantics(label: 'Theme', isHeader: true),
    );
    semantics.dispose();
  });

  testWidgets('The amount editor title is a heading', (tester) async {
    final semantics = tester.ensureSemantics();
    await pumpSheet(tester, sheets['transaction edit sheet']!);
    await tester.tap(find.byKey(const Key('txAmountField')));
    await tester.pumpAndSettle();

    expect(
      tester.getSemantics(find.text('Amount')),
      isSemantics(label: 'Amount', isHeader: true),
    );
    semantics.dispose();
  });

  /// Read like Flutter's single-select SegmentedButton: a button, its
  /// selected state, one choice of a group.
  void expectSingleChoice(WidgetTester tester, String label, bool selected) {
    expect(
      tester.getSemantics(find.text(label).last),
      isSemantics(
        label: label,
        isButton: true,
        isSelected: selected,
        isInMutuallyExclusiveGroup: true,
      ),
      reason: label,
    );
  }

  testWidgets('The filter type options are single-choice buttons', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await pumpSheet(tester, sheetHeadings['filter sheet']!.$1);

    expectSingleChoice(tester, 'All', true);
    expectSingleChoice(tester, 'Income', false);
    expectSingleChoice(tester, 'Expense', false);
    expectSingleChoice(tester, 'October', true);
    semantics.dispose();
  });

  testWidgets('The expense/income toggles are single-choice buttons', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    tester.view.physicalSize = const Size(402, 3000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final db = await createTestDatabase();
    addTearDown(db.close);
    await seedGoldenData(db);
    // The cash flow card's toggle.
    await pumpWidgetWithProviders(tester, const DashboardScreen(), db: db);
    expectSingleChoice(tester, 'Expense', true);
    expectSingleChoice(tester, 'Income', false);
    semantics.dispose();
  });

  testWidgets('The new transaction type toggle is single-choice', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await pumpSheet(tester, sheets['new transaction sheet']!);

    expectSingleChoice(tester, 'Expense', true);
    expectSingleChoice(tester, 'Income', false);
    semantics.dispose();
  });

  testWidgets('A wallet card and its menu are buttons, the menu named by '
      'its wallet', (tester) async {
    final semantics = tester.ensureSemantics();
    final db = await createTestDatabase();
    addTearDown(db.close);
    await seedGoldenData(db);
    await pumpWidgetWithProviders(tester, const WalletsScreen(), db: db);

    expect(
      tester.getSemantics(find.text('Everyday')),
      isSemantics(isButton: true),
    );
    expect(
      tester.getSemantics(find.byTooltip('Everyday options')),
      isSemantics(isButton: true, tooltip: 'Everyday options'),
    );
    semantics.dispose();
  });

  testWidgets('A transaction row menu is named by its transaction', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    final db = await createTestDatabase();
    addTearDown(db.close);
    await seedGoldenData(db);
    await pumpWidgetWithProviders(
      tester,
      const AllTransactionsScreen(),
      db: db,
    );

    for (final title in ['Weekly groceries', 'Paycheck']) {
      expect(
        tester.getSemantics(find.byTooltip('$title options')),
        isSemantics(isButton: true, tooltip: '$title options'),
      );
    }
    semantics.dispose();
  });

  // Flutter's own accessibility checks: 48px touch targets (Material; Apple
  // asks 44pt), a name on everything tappable, readable text contrast.
  final guidelines = {
    'touch targets are at least 48px': androidTapTargetGuideline,
    'everything tappable has a name': labeledTapTargetGuideline,
    'text contrast is readable': textContrastGuideline,
  };
  final screens = <String, Widget>{
    'dashboard': const DashboardScreen(),
    'wallets screen': const WalletsScreen(),
    'settings screen': const SettingsScreen(),
    'categories screen': const CategoriesScreen(),
    'transaction list': const AllTransactionsScreen(),
  };
  for (final MapEntry(key: check, value: guideline) in guidelines.entries) {
    for (final MapEntry(key: name, value: screen) in screens.entries) {
      testWidgets('On the $name, $check', (tester) async {
        final semantics = tester.ensureSemantics();
        tester.view.physicalSize = const Size(402, 2400);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        final db = await createTestDatabase();
        addTearDown(db.close);
        await seedGoldenData(db);
        await pumpWidgetWithProviders(tester, screen, db: db);

        await expectLater(tester, meetsGuideline(guideline));
        semantics.dispose();
      });
    }
    for (final MapEntry(key: name, value: open) in {
      ...sheets,
      'new wallet sheet': sheetHeadings['new wallet sheet']!.$1,
      'filter sheet': sheetHeadings['filter sheet']!.$1,
    }.entries) {
      testWidgets('In the $name, $check', (tester) async {
        final semantics = tester.ensureSemantics();
        await pumpSheet(tester, open);

        await expectLater(tester, meetsGuideline(guideline));
        semantics.dispose();
      });
    }
  }

  testWidgets('The navbar is a tab bar whose tabs are named once', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    final db = await createTestDatabase();
    addTearDown(db.close);
    await pumpTestApp(tester, db: db);

    final tabs = find.semantics
        .byPredicate((n) => n.getSemanticsData().role == SemanticsRole.tab)
        .evaluate()
        .toList();
    expect(tabs, hasLength(3));
    for (final (i, name) in ['Dashboard', 'Wallets', 'Settings'].indexed) {
      expect(tabs[i].label, '$name\nTab ${i + 1} of 3');
      expect(
        tabs[i],
        isSemantics(isButton: true, isSelected: i == 0, hasTapAction: true),
      );
    }
    semantics.dispose();
  });

  testWidgets('Each category is read on its own, next to its delete button', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    tester.view.physicalSize = const Size(402, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final db = await pumpWidgetWithProviders(tester, const CategoriesScreen());
    addTearDown(db.close);

    for (final name in ['Education', 'Groceries', 'Others']) {
      expect(tester.getSemantics(find.text(name)).label, name);
    }
    expect(
      tester.getSemantics(find.byTooltip('Delete Education')),
      isSemantics(isButton: true),
    );
    semantics.dispose();
  });

  testWidgets('The balance eye is its own button and the receipt says where '
      'it goes', (tester) async {
    final semantics = tester.ensureSemantics();
    tester.view.physicalSize = const Size(402, 3000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final db = await createTestDatabase();
    addTearDown(db.close);
    await seedGoldenData(db);
    await pumpWidgetWithProviders(tester, const DashboardScreen(), db: db);

    final eye = tester.getSemantics(find.byTooltip('Hide balance'));
    expect(
      eye,
      isSemantics(isButton: true, tooltip: 'Hide balance', hasTapAction: true),
    );
    // Not the card's text, which is read apart.
    expect(eye.label, isEmpty);

    expect(
      tester.getSemantics(find.textContaining('WALDO')),
      isSemantics(isButton: true, hint: 'Opens all transactions'),
    );
    semantics.dispose();
  });

  Future<void> pumpCashFlow(WidgetTester tester, {bool hidden = false}) async {
    final db = await pumpWidgetWithProviders(
      tester,
      Scaffold(
        body: CashFlowCard(
          monthlyCashFlow: [
            MonthlyCashFlow(month: DateTime(2026, 8), income: 0, expense: 0),
            MonthlyCashFlow(
              month: DateTime(2026, 9),
              income: 50000,
              expense: 0,
            ),
            MonthlyCashFlow(
              month: DateTime(2026, 10),
              income: 0,
              expense: 1250,
            ),
          ],
          currency: Currency.eur,
          isBalanceHidden: hidden,
        ),
      ),
    );
    addTearDown(db.close);
  }

  testWidgets('The cash flow chart reads what it shows and every month', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await pumpCashFlow(tester);

    final chart = tester.getSemantics(find.byType(LineChart));
    expect(chart.label, 'Expenses by month, Aug 2026 to Oct 2026');
    expect(
      chart.value,
      matches(
        RegExp(r'^August: .*0\.00; September: .*0\.00; October: .*12\.50$'),
      ),
    );

    await tester.tap(find.text('Income'));
    await tester.pumpAndSettle();
    expect(
      tester.getSemantics(find.byType(LineChart)).label,
      'Income by month, Aug 2026 to Oct 2026',
    );
    semantics.dispose();
  });

  testWidgets('With the balance hidden the chart keeps its amounts hidden', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await pumpCashFlow(tester, hidden: true);

    expect(tester.getSemantics(find.byType(LineChart)).value, 'Amounts hidden');
    semantics.dispose();
  });
}
