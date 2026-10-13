import 'package:flutter/material.dart';
import 'package:waldo/core/theme/app_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:waldo/core/utils/utils.dart';
import 'package:waldo/features/preferences/viewmodels/balance_hidden_view_model.dart';
import 'package:waldo/features/transactions/ui/transactions_screen.dart';
import 'package:waldo/features/wallets/models/wallet.dart';
import 'package:waldo/features/wallets/repositories/wallet_repository.dart';

import '../../../helpers/test_app.dart';

void main() {
  Database? currentDb;

  tearDown(() async {
    await currentDb?.close();
    currentDb = null;
  });

  Future<int> pumpTransactionsScreen(WidgetTester tester) async {
    // A portrait phone size, so the whole amount sheet fits.
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final db = await createTestDatabase();
    final walletRepo = WalletRepositoryImpl(db);
    final walletId = await walletRepo.insert(
      const Wallet(name: 'Test Wallet', createdAt: '2026-08-10T12:00:00.000'),
    );

    currentDb = await pumpWidgetWithProviders(
      tester,
      TransactionsScreen(walletId: walletId),
      db: db,
    );
    return walletId;
  }

  // The add form's date field only opens a date picker (the app doesn't
  // track a time of day), so this only ever taps one "OK".
  Future<void> setDate(WidgetTester tester) async {
    final dateField = find.byKey(const Key('transactionDateField'));
    await tester.ensureVisible(dateField);
    await tester.pumpAndSettle();
    await tester.tap(dateField);
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
  }

  Future<void> tapAddExpense(WidgetTester tester) async {
    final button = find.text('Add expense');
    await tester.ensureVisible(button);
    await tester.pumpAndSettle();
    await tester.tap(button);
    await tester.pumpAndSettle();
  }

  Future<void> createTransaction(
    WidgetTester tester, {
    String amount = '10.00',
    String description = '',
  }) async {
    await tester.tap(find.byIcon(AppIcons.add));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('transactionAmountField')),
      amount,
    );

    if (description.isNotEmpty) {
      await tester.enterText(
        find.byKey(const Key('transactionDescriptionField')),
        description,
      );
    }

    await setDate(tester);

    await tapAddExpense(tester);
  }

  testWidgets('Amount accepts a comma as the decimal separator', (
    tester,
  ) async {
    await pumpTransactionsScreen(tester);
    // The decimal key on a Portuguese numeric keyboard types ','.
    await createTransaction(tester, amount: '12,50');

    expect(find.text(r'-$12.50'), findsOneWidget);
  });

  testWidgets('A row shows its category, not a time of day', (tester) async {
    await pumpTransactionsScreen(tester);
    await createTransaction(tester, amount: '5.00', description: 'Coffee');

    // No category picked lands in Others.
    expect(find.text('Others'), findsOneWidget);
    expect(find.textContaining('00:00'), findsNothing);
  });

  testWidgets('Hiding the balance masks every amount in the list', (
    tester,
  ) async {
    await pumpTransactionsScreen(tester);
    await createTransaction(tester, amount: '25.00', description: 'Coffee');
    expect(find.textContaining(r'$'), findsWidgets);

    ProviderScope.containerOf(
      tester.element(find.byType(TransactionsScreen)),
    ).read(balanceHiddenProvider.notifier).toggle();
    await tester.pumpAndSettle();

    expect(find.textContaining(r'$'), findsNothing);
    expect(find.text(hiddenAmount), findsWidgets);
  });

  testWidgets('The header buttons have accessible names', (tester) async {
    await pumpTransactionsScreen(tester);

    expect(find.byTooltip('Back'), findsOneWidget);
    expect(find.byTooltip('New Transaction'), findsOneWidget);
    expect(find.byTooltip('Hide balance'), findsOneWidget);
  });

  testWidgets('Shows empty state when there are no transactions', (
    tester,
  ) async {
    await pumpTransactionsScreen(tester);

    expect(find.text('No transactions yet'), findsOneWidget);
  });

  testWidgets('Creating a transaction adds it to the list', (tester) async {
    await pumpTransactionsScreen(tester);
    await createTransaction(tester, amount: '25.00', description: 'Groceries');

    expect(find.text('Groceries'), findsOneWidget);
    expect(find.text('No transactions yet'), findsNothing);
  });

  testWidgets('Shows the default description when none is given', (
    tester,
  ) async {
    await pumpTransactionsScreen(tester);
    await createTransaction(tester, amount: '15.00');

    expect(find.text('Transaction'), findsOneWidget);
  });

  testWidgets('Shows validation error when amount is empty', (tester) async {
    await pumpTransactionsScreen(tester);

    await tester.tap(find.byIcon(AppIcons.add));
    await tester.pumpAndSettle();

    await setDate(tester);

    await tapAddExpense(tester);

    expect(find.text('Amount is required'), findsOneWidget);
  });

  testWidgets('Shows validation error when date is not selected', (
    tester,
  ) async {
    await pumpTransactionsScreen(tester);

    await tester.tap(find.byIcon(AppIcons.add));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('transactionAmountField')),
      '10.00',
    );

    await tapAddExpense(tester);

    expect(find.text('Date is required'), findsOneWidget);
  });

  testWidgets(
    'Tapping a transaction opens a read-only view with no edit affordances',
    (tester) async {
      await pumpTransactionsScreen(tester);
      await createTransaction(
        tester,
        amount: '25.00',
        description: 'Groceries',
      );

      await tester.tap(find.text('Groceries'));
      await tester.pumpAndSettle();

      expect(find.byIcon(AppIcons.chevronRight), findsNothing);
    },
  );

  testWidgets(
    'Choosing Edit from the row menu opens the edit screen and stages '
    'changes until Save',
    (tester) async {
      await pumpTransactionsScreen(tester);
      await createTransaction(
        tester,
        amount: '25.00',
        description: 'Groceries',
      );

      await tester.tap(find.byIcon(AppIcons.more));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Edit'));
      await tester.pumpAndSettle();

      // Category and Date still drill into their own pickers (chevron);
      // Name is directly editable in place on this same screen.
      expect(find.byIcon(AppIcons.chevronRight), findsWidgets);
      expect(find.text('Save changes'), findsOneWidget);

      await tester.enterText(find.byKey(const Key('txNameField')), 'Rent');
      await tester.tap(find.text('Save changes'));
      await tester.pumpAndSettle();

      expect(find.text('Rent'), findsWidgets);
    },
  );

  Future<void> openEditFromRowMenu(WidgetTester tester) async {
    await tester.tap(find.byIcon(AppIcons.more));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();
  }

  String nameFieldText(WidgetTester tester) => tester
      .widget<EditableText>(
        find.descendant(
          of: find.byKey(const Key('txNameField')),
          matching: find.byType(EditableText),
        ),
      )
      .controller
      .text;

  testWidgets('The amount keypad can keep typing after an existing amount', (
    tester,
  ) async {
    await pumpTransactionsScreen(tester);
    await createTransaction(tester, amount: '10.00', description: 'Coffee');

    await openEditFromRowMenu(tester);
    await tester.tap(find.byKey(const Key('txAmountField')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('5'));
    await tester.pumpAndSettle();

    expect(find.text(r'-$105.00'), findsOneWidget);
  });

  testWidgets('Cancel puts the typed name back to what it was', (tester) async {
    await pumpTransactionsScreen(tester);
    await createTransaction(tester, amount: '25.00', description: 'Groceries');

    await openEditFromRowMenu(tester);
    await tester.enterText(find.byKey(const Key('txNameField')), 'Lunch');
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Edit transaction'));
    await tester.pumpAndSettle();
    expect(nameFieldText(tester), 'Groceries');
  });

  testWidgets('Cancel after a save goes back to the saved values', (
    tester,
  ) async {
    await pumpTransactionsScreen(tester);
    await createTransaction(tester, amount: '25.00', description: 'Groceries');

    await openEditFromRowMenu(tester);
    await tester.enterText(find.byKey(const Key('txNameField')), 'Lunch');
    await tester.tap(find.text('Save changes'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Edit transaction'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(find.text('Lunch'), findsWidgets);
    expect(find.text('Groceries'), findsNothing);
  });

  Future<void> deleteFromRowMenu(WidgetTester tester) async {
    await tester.tap(find.byIcon(AppIcons.more));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    // The confirmation dialog's own Delete button.
    await tester.tap(find.text('Delete'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));
  }

  testWidgets(
    'Choosing Delete hides the transaction and shows an Undo snackbar',
    (tester) async {
      await pumpTransactionsScreen(tester);
      await createTransaction(
        tester,
        amount: '25.00',
        description: 'Groceries',
      );

      await deleteFromRowMenu(tester);

      expect(find.text('Groceries'), findsNothing);
      expect(find.text('Transaction deleted'), findsOneWidget);
      expect(find.text('Undo'), findsOneWidget);

      await tester.pump(const Duration(seconds: 6));
    },
  );

  testWidgets('Tapping Undo restores the transaction', (tester) async {
    await pumpTransactionsScreen(tester);
    await createTransaction(tester, amount: '25.00', description: 'Groceries');

    await deleteFromRowMenu(tester);
    expect(find.text('Groceries'), findsNothing);

    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();
    expect(find.text('Groceries'), findsOneWidget);

    await tester.pump(const Duration(seconds: 6));
    expect(find.text('Groceries'), findsOneWidget);
  });

  testWidgets(
    'Not tapping Undo permanently deletes the transaction after 5 seconds',
    (tester) async {
      await pumpTransactionsScreen(tester);
      await createTransaction(
        tester,
        amount: '25.00',
        description: 'Groceries',
      );

      await deleteFromRowMenu(tester);
      await tester.pump(const Duration(seconds: 6));
      await tester.pumpAndSettle();

      expect(find.text('Groceries'), findsNothing);
      expect(find.text('No transactions yet'), findsOneWidget);
    },
  );
}
