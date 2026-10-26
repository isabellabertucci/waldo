import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:waldo/core/constants/app_constants.dart';
import 'package:waldo/features/transactions/ui/widgets/transaction_form_sheet.dart';
import 'package:waldo/features/wallets/models/wallet.dart';
import 'package:waldo/features/wallets/repositories/wallet_repository.dart';

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

  testWidgets('The wallet picker scrolls when there are many wallets', (
    tester,
  ) async {
    final db = await createTestDatabase();
    addTearDown(db.close);
    final wallets = WalletRepositoryImpl(db);
    for (var i = 0; i < 12; i++) {
      await wallets.insert(
        Wallet(name: 'Wallet $i', createdAt: '2026-08-10T12:00:00.000'),
      );
    }
    await pumpWidgetWithProviders(
      tester,
      Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () => showTransactionFormSheet(context),
            child: const Text('open'),
          ),
        ),
      ),
      db: db,
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('None'));
    await tester.tap(find.text('None'));
    await tester.pumpAndSettle();

    // No overflow, and the last wallet can be reached and picked.
    expect(tester.takeException(), isNull);
    final last = find.text('Wallet 0');
    await tester.scrollUntilVisible(
      last,
      100,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.tap(last);
    await tester.pumpAndSettle();
    expect(find.text('Wallet 0'), findsOneWidget);
  });
}
