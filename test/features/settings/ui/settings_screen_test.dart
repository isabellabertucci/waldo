import 'package:waldo/core/theme/app_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:waldo/core/constants/db_constants.dart';
import 'package:waldo/core/constants/enums.dart';
import 'package:waldo/core/utils/utils.dart';
import 'package:waldo/features/preferences/viewmodels/balance_hidden_view_model.dart';
import 'package:waldo/features/settings/ui/settings_screen.dart';
import 'package:waldo/features/settings/ui/widgets/settings_option_sheet.dart';

import '../../../helpers/test_app.dart';

void main() {
  Database? currentDb;

  tearDown(() async {
    await currentDb?.close();
    currentDb = null;
  });

  Future<void> pumpSettingsScreen(WidgetTester tester, {Database? db}) async {
    currentDb = await pumpWidgetWithProviders(
      tester,
      const SettingsScreen(),
      db: db,
    );
  }

  testWidgets('Renders money and appearance rows', (tester) async {
    await pumpSettingsScreen(tester);

    expect(find.text('USD'), findsOneWidget);
    expect(find.text('System'), findsOneWidget);
  });

  testWidgets('Tapping the theme row opens a sheet with theme options', (
    tester,
  ) async {
    await pumpSettingsScreen(tester);

    await tester.tap(find.text('System').first);
    await tester.pumpAndSettle();

    expect(find.byType(SettingsOptionSheet<bool?>), findsOneWidget);
    expect(find.text('Light'), findsOneWidget);
    expect(find.text('Dark'), findsOneWidget);
  });

  testWidgets(
    'Picking an option only highlights it - Done is what commits it',
    (tester) async {
      await pumpSettingsScreen(tester);

      await tester.tap(find.text('System').first);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Dark'));
      await tester.pumpAndSettle();

      // Still open, and the row behind the sheet hasn't changed yet - its
      // "System" value plus the sheet's own "System" option label.
      expect(find.byType(SettingsOptionSheet<bool?>), findsOneWidget);
      expect(find.text('System'), findsNWidgets(2));
    },
  );

  testWidgets('Confirming with Done closes the sheet and updates the row', (
    tester,
  ) async {
    await pumpSettingsScreen(tester);

    await tester.tap(find.text('System').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Dark'));
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();

    expect(find.byType(SettingsOptionSheet<bool?>), findsNothing);
    expect(find.text('Dark'), findsOneWidget);
  });

  testWidgets('A failed save says nothing was changed', (tester) async {
    await pumpSettingsScreen(tester);
    // No table to write to, so the update throws.
    await currentDb!.execute('DROP TABLE ${PreferencesTable.table}');

    await tester.tap(find.text('System').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Dark'));
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();

    expect(
      find.text("Couldn't save your preference. Nothing was changed."),
      findsOneWidget,
    );
  });

  testWidgets('Closing with the X button discards the pick', (tester) async {
    await pumpSettingsScreen(tester);

    await tester.tap(find.text('System').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Dark'));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(AppIcons.close));
    await tester.pumpAndSettle();

    expect(find.byType(SettingsOptionSheet<bool?>), findsNothing);
    expect(find.text('System'), findsOneWidget);
  });

  testWidgets('Selecting dark theme persists across reloads', (tester) async {
    await pumpSettingsScreen(tester);

    await tester.tap(find.text('System').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Dark'));
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();

    await pumpSettingsScreen(tester, db: currentDb);

    expect(find.text('Dark'), findsOneWidget);
  });

  testWidgets('Tapping the currency row opens a sheet with currency options', (
    tester,
  ) async {
    await pumpSettingsScreen(tester);

    await tester.tap(find.text('USD').first);
    await tester.pumpAndSettle();

    expect(find.byType(SettingsOptionSheet<Currency>), findsOneWidget);
    expect(find.text('US dollar'), findsOneWidget);
    expect(find.text('Euro'), findsOneWidget);
    expect(find.text('British pound'), findsOneWidget);
    expect(
      find.text(
        'This changes the symbol only. Your amounts stay the same and are not converted.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('With the balance hidden, the currency sheet hides the total', (
    tester,
  ) async {
    await pumpSettingsScreen(tester);
    ProviderScope.containerOf(
      tester.element(find.byType(SettingsScreen)),
    ).read(balanceHiddenProvider.notifier).toggle();
    await tester.pumpAndSettle();

    await tester.tap(find.text('USD').first);
    await tester.pumpAndSettle();

    expect(find.text('USD · $hiddenAmount'), findsOneWidget);
    expect(find.textContaining('0.00'), findsNothing);
  });

  testWidgets('The option sheet close button is named for screen readers', (
    tester,
  ) async {
    await pumpSettingsScreen(tester);
    await tester.tap(find.text('System').first);
    await tester.pumpAndSettle();

    expect(find.byTooltip('Close'), findsOneWidget);
  });

  testWidgets('Selecting a currency persists across reloads', (tester) async {
    await pumpSettingsScreen(tester);

    await tester.tap(find.text('USD').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Euro'));
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();

    await pumpSettingsScreen(tester, db: currentDb);

    expect(find.text('EUR'), findsOneWidget);
  });

  testWidgets('Tapping the date format row opens a sheet with format options', (
    tester,
  ) async {
    await pumpSettingsScreen(tester);

    await tester.tap(find.text('Date format'));
    await tester.pumpAndSettle();

    expect(find.byType(SettingsOptionSheet<String>), findsOneWidget);
    // One icon per format option in the sheet.
    expect(
      find.descendant(
        of: find.byType(SettingsOptionSheet<String>),
        matching: find.byIcon(AppIcons.calendar),
      ),
      findsNWidgets(3),
    );
  });
}
