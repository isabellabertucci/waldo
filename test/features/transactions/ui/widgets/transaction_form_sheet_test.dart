import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:waldo/core/constants/app_constants.dart';
import 'package:waldo/core/database/db_providers.dart';
import 'package:waldo/core/theme/app_icons.dart';
import 'package:waldo/core/theme/app_theme.dart';
import 'package:waldo/core/utils/localization_delegates.dart';
import 'package:waldo/features/categories/models/category.dart';
import 'package:waldo/features/categories/repositories/category_repository.dart';
import 'package:waldo/features/transactions/ui/widgets/transaction_form_sheet.dart';
import 'package:waldo/features/wallets/models/wallet.dart';
import 'package:waldo/features/wallets/repositories/wallet_repository.dart';
import 'package:waldo/l10n/app_localizations.dart';

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

  testWidgets('The date starts as today, and a missing wallet says so '
      'under the card', (tester) async {
    await openSheet(tester);
    await tester.enterText(
      find.byKey(const Key('transactionAmountField')),
      '10.00',
    );
    final save = find.text('Add expense');
    await tester.ensureVisible(save);
    await tester.pumpAndSettle();
    await tester.tap(save);
    await tester.pumpAndSettle();

    expect(find.textContaining('Date is required'), findsNothing);
    final error = find.text('Wallet is required');
    expect(error, findsOneWidget);
    // Below the card's last row, not between the rows.
    final dateRow = tester.getRect(
      find.byKey(const Key('transactionDateField')),
    );
    expect(tester.getRect(error).top, greaterThanOrEqualTo(dateRow.bottom));
  });

  testWidgets('The category starts as None and is picked from a list', (
    tester,
  ) async {
    await openSheet(tester);
    final row = find.byKey(const Key('transactionCategoryField'));
    expect(
      find.descendant(of: row, matching: find.text('None')),
      findsOneWidget,
    );
    // None has its own icon, not the tag of a category you made.
    expect(
      find.descendant(of: row, matching: find.byIcon(AppIcons.categoryNone)),
      findsOneWidget,
    );

    await tester.tap(row);
    await tester.pumpAndSettle();
    final noneTile = find.ancestor(
      of: find.text('None').last,
      matching: find.byType(InkWell),
    );
    expect(
      find.descendant(
        of: noneTile,
        matching: find.byIcon(AppIcons.categoryNone),
      ),
      findsOneWidget,
    );
    await tester.tap(find.text('Groceries'));
    await tester.pumpAndSettle();

    expect(
      find.descendant(of: row, matching: find.text('Groceries')),
      findsOneWidget,
    );
  });

  testWidgets('A new category made from the picker is picked at once', (
    tester,
  ) async {
    await openSheet(tester);
    final row = find.byKey(const Key('transactionCategoryField'));

    await tester.tap(row);
    await tester.pumpAndSettle();
    await tester.tap(find.text('New category'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('categoryNameField')), 'Gym');
    await tester.tap(find.text('Create category'));
    await tester.pumpAndSettle();

    expect(
      find.descendant(of: row, matching: find.text('Gym')),
      findsOneWidget,
    );
  });

  testWidgets('A second tap on Create while the first saves still picks the '
      'new category', (tester) async {
    final db = await createTestDatabase();
    addTearDown(db.close);
    final repo = _GatedCategoryRepository(db);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWith((ref) async => db),
          categoryRepositoryProvider.overrideWith((ref) async => repo),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          localizationsDelegates: appLocalizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () => showTransactionFormSheet(context),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    final row = find.byKey(const Key('transactionCategoryField'));
    await tester.tap(row);
    await tester.pumpAndSettle();
    await tester.tap(find.text('New category'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('categoryNameField')), 'Gym');

    // The first save waits at the gate while the second tap lands.
    await tester.tap(find.text('Create category'));
    await tester.pump();
    await tester.tap(find.text('Create category'));
    await tester.pump();
    repo.gate.complete();
    await tester.pumpAndSettle();

    expect(
      find.descendant(of: row, matching: find.text('Gym')),
      findsOneWidget,
    );
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
    final walletRow = find.byKey(const Key('transactionWalletField'));
    await tester.ensureVisible(walletRow);
    await tester.tap(walletRow);
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

/// Holds every insert until [gate] opens, so a test can tap twice mid-save.
class _GatedCategoryRepository extends CategoryRepositoryImpl {
  _GatedCategoryRepository(super.db);

  final gate = Completer<void>();

  @override
  Future<int> insert(Category category) async {
    await gate.future;
    return super.insert(category);
  }
}
