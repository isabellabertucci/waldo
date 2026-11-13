import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quick_actions/quick_actions.dart';
import 'package:waldo/core/database/db_providers.dart';
import 'package:waldo/core/theme/app_theme.dart';
import 'package:waldo/core/utils/localization_delegates.dart';
import 'package:waldo/features/transactions/ui/transaction_shortcuts.dart';
import 'package:waldo/features/transactions/ui/widgets/transaction_form_sheet.dart';
import 'package:waldo/l10n/app_localizations.dart';

import '../../../helpers/test_app.dart';

/// Stands in for the home screen: keeps the shortcuts set and the handler.
class _FakeQuickActions extends Fake implements QuickActions {
  QuickActionHandler? handler;
  List<ShortcutItem> items = [];

  @override
  Future<void> initialize(QuickActionHandler handler) async =>
      this.handler = handler;

  @override
  Future<void> setShortcutItems(List<ShortcutItem> items) async =>
      this.items = items;
}

void main() {
  Future<_FakeQuickActions> pumpApp(WidgetTester tester) async {
    final quickActions = _FakeQuickActions();
    final db = await createTestDatabase();
    addTearDown(db.close);
    final router = createTestRouter(initialLocation: '/settings');
    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWith((ref) async => db)],
        child: MaterialApp.router(
          routerConfig: router,
          theme: AppTheme.light,
          locale: const Locale('en'),
          localizationsDelegates: appLocalizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          builder: (context, child) => TransactionShortcuts(
            router: router,
            quickActions: quickActions,
            child: child!,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return quickActions;
  }

  testWidgets('The app icon offers New expense and New income', (tester) async {
    final quickActions = await pumpApp(tester);

    expect(
      [for (final item in quickActions.items) item.localizedTitle],
      ['New expense', 'New income'],
    );
  });

  testWidgets('New income opens the new-transaction sheet as an income', (
    tester,
  ) async {
    final quickActions = await pumpApp(tester);

    quickActions.handler!('new_income');
    await tester.pumpAndSettle();

    expect(find.byType(TransactionFormSheet), findsOneWidget);
    expect(find.text('Add income'), findsOneWidget);
  });
}
