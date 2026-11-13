import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waldo/core/theme/app_theme.dart';
import 'package:waldo/core/widgets/load_error.dart';
import 'package:waldo/l10n/app_localizations.dart';

void main() {
  testWidgets('A failed load says so and Try again loads it again', (
    tester,
  ) async {
    var retries = 0;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: LoadError(
            message: 'There was a problem loading your wallets.',
            onRetry: () => retries++,
          ),
        ),
      ),
    );

    expect(
      find.text('There was a problem loading your wallets.'),
      findsOneWidget,
    );
    await tester.tap(find.text('Try again'));
    expect(retries, 1);
  });
}
