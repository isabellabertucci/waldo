import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:waldo/features/settings/ui/settings_screen.dart';

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

  testWidgets('Renders dark mode, currency, and date format rows', (
    tester,
  ) async {
    await pumpSettingsScreen(tester);

    expect(find.text('System'), findsOneWidget);
    expect(find.text('USD'), findsOneWidget);
  });

  testWidgets('Tapping the theme row opens a sheet with theme options', (
    tester,
  ) async {
    await pumpSettingsScreen(tester);

    await tester.tap(find.text('System').first);
    await tester.pumpAndSettle();

    expect(find.text('Light'), findsOneWidget);
    expect(find.text('Dark'), findsOneWidget);
  });

  testWidgets('Selecting dark theme closes the sheet and updates the row', (
    tester,
  ) async {
    await pumpSettingsScreen(tester);

    await tester.tap(find.text('System').first);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Dark'));
    await tester.pumpAndSettle();

    expect(find.text('Dark'), findsOneWidget);
  });

  testWidgets('Selecting dark theme persists across reloads', (tester) async {
    await pumpSettingsScreen(tester);

    await tester.tap(find.text('System').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Dark'));
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

    expect(find.text('USD (\$)'), findsOneWidget);
    expect(find.text('EUR (€)'), findsOneWidget);
    expect(find.text('GBP (£)'), findsOneWidget);
  });

  testWidgets('Selecting a currency persists across reloads', (tester) async {
    await pumpSettingsScreen(tester);

    await tester.tap(find.text('USD').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('EUR (€)'));
    await tester.pumpAndSettle();

    await pumpSettingsScreen(tester, db: currentDb);

    expect(find.text('EUR'), findsOneWidget);
  });

  testWidgets('Tapping the date format row opens a sheet with format options', (
    tester,
  ) async {
    await pumpSettingsScreen(tester);

    await tester.tap(find.byIcon(Icons.calendar_today_outlined));
    await tester.pumpAndSettle();

    expect(find.byType(RadioListTile<String>), findsNWidgets(3));
  });
}
