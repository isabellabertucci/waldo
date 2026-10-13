import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:waldo/core/constants/enums.dart';
import 'package:waldo/core/theme/app_theme.dart';
import 'package:waldo/features/transactions/models/transaction.dart';
import 'package:waldo/features/transactions/ui/widgets/day_grouped_transaction_list.dart';
import 'package:waldo/l10n/app_localizations.dart';

Transaction _expense(int id, String date) => Transaction(
  id: id,
  walletId: 1,
  amount: 123450,
  type: TransactionType.expense,
  date: date,
  description: 'Expense $id',
  createdAt: date,
);

void main() {
  testWidgets('A Portuguese phone gets Portuguese day headers and euros', (
    tester,
  ) async {
    tester.platformDispatcher.localeTestValue = const Locale('pt', 'PT');
    addTearDown(tester.platformDispatcher.clearLocaleTestValue);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        locale: const Locale('pt'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: DayGroupedTransactionList(
            transactions: [
              _expense(1, '2026-10-08T09:00:00.000'),
              _expense(2, '2026-10-07T09:00:00.000'),
              _expense(3, '2026-10-05T09:00:00.000'),
            ],
            categoriesById: const {},
            currency: Currency.eur,
            now: DateTime(2026, 10, 8, 12),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('HOJE'), findsOneWidget);
    expect(find.text('ONTEM'), findsOneWidget);
    expect(find.text('SEG. 5 OUT.'), findsOneWidget);
    expect(find.text('-1 234,50 €'), findsNWidgets(3));
  });
}
