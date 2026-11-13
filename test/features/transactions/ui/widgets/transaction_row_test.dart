import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waldo/core/constants/enums.dart';
import 'package:waldo/core/theme/app_theme.dart';
import 'package:waldo/core/theme/spacing.dart';
import 'package:waldo/features/transactions/models/transaction.dart';
import 'package:waldo/features/transactions/ui/widgets/transaction_row.dart';
import 'package:waldo/l10n/app_localizations.dart';

void main() {
  testWidgets('A cut title keeps a gap before the amount', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    const title = 'Weekly groceries for the whole family with fruit';

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const Scaffold(
          body: TransactionRow(
            transaction: Transaction(
              id: 1,
              walletId: 1,
              amount: 8735,
              type: TransactionType.expense,
              date: '2026-10-03',
              description: title,
              createdAt: '2026-10-03',
            ),
            category: null,
            currency: Currency.eur,
          ),
        ),
      ),
    );

    final titleRect = tester.getRect(find.textContaining('Weekly'));
    final amountRect = tester.getRect(find.textContaining('87'));
    expect(amountRect.left - titleRect.right, greaterThanOrEqualTo(Spacing.sm));
  });
}
