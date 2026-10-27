import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waldo/core/constants/enums.dart';
import 'package:waldo/core/theme/app_theme.dart';
import 'package:waldo/features/transactions/ui/widgets/transaction_type_toggle.dart';
import 'package:waldo/l10n/app_localizations.dart';

void main() {
  testWidgets('Each type is a touch at least 48px tall', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: TransactionTypeToggle(
            selected: TransactionType.expense,
            onChanged: (_) {},
          ),
        ),
      ),
    );

    // Measured directly: the guideline skips a node at a scroll edge.
    for (final label in const ['Expense', 'Income']) {
      final segment = find.ancestor(
        of: find.text(label),
        matching: find.byType(GestureDetector),
      );
      expect(tester.getSize(segment.first).height, greaterThanOrEqualTo(48));
    }
  });
}
