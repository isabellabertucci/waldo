import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:waldo/features/categories/views/categories_screen.dart';

import '../../../helpers/test_app.dart';

void main() {
  Database? currentDb;

  tearDown(() async {
    await currentDb?.close();
    currentDb = null;
  });

  Future<void> pumpCategoriesScreen(WidgetTester tester, {Database? db}) async {
    currentDb = await pumpWidgetWithProviders(
      tester,
      const CategoriesScreen(),
      db: db,
    );
  }

  Future<void> createCategory(WidgetTester tester, String name) async {
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    await tester.enterText(find.widgetWithText(TextFormField, 'Name'), name);
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
  }

  testWidgets('Shows empty state when there are no categories', (tester) async {
    await pumpCategoriesScreen(tester);

    expect(find.text('No categories yet'), findsOneWidget);
  });

  testWidgets('Creating a category adds it to the list', (tester) async {
    await pumpCategoriesScreen(tester);
    await createCategory(tester, 'Test Category');

    expect(find.text('Test Category'), findsOneWidget);
    expect(find.text('No categories yet'), findsNothing);
  });

  testWidgets('Shows validation error when name is empty', (tester) async {
    await pumpCategoriesScreen(tester);

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Name is required'), findsOneWidget);
  });

  testWidgets('Deleting a category shows a confirmation dialog first', (
    tester,
  ) async {
    await pumpCategoriesScreen(tester);
    await createCategory(tester, 'Test Category');

    await tester.tap(find.byIcon(Icons.delete));
    await tester.pumpAndSettle();

    expect(find.text('Delete category?'), findsOneWidget);
    expect(find.text('Test Category'), findsOneWidget);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(find.text('Test Category'), findsOneWidget);
  });

  testWidgets(
    'Confirming delete hides the category immediately and shows a snackbar',
    (tester) async {
      await pumpCategoriesScreen(tester);
      await createCategory(tester, 'Test Category');

      await tester.tap(find.byIcon(Icons.delete));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 250));

      expect(find.text('Test Category'), findsNothing);
      expect(find.text('Category deleted'), findsOneWidget);
      expect(find.text('Undo'), findsOneWidget);

      await tester.pump(const Duration(seconds: 6));
    },
  );

  testWidgets('Tapping Undo restores the category to the list', (tester) async {
    await pumpCategoriesScreen(tester);
    await createCategory(tester, 'Test Category');

    await tester.tap(find.byIcon(Icons.delete));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));

    expect(find.text('Test Category'), findsNothing);

    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();

    expect(find.text('Test Category'), findsOneWidget);

    await tester.pump(const Duration(seconds: 6));
    expect(find.text('Test Category'), findsOneWidget);
  });

  testWidgets(
    'Not tapping Undo permanently deletes the category after 5 seconds',
    (tester) async {
      await pumpCategoriesScreen(tester);
      await createCategory(tester, 'Test Category');
      await tester.tap(find.byIcon(Icons.delete));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 250));
      expect(find.text('Test Category'), findsNothing);
      await tester.pump(const Duration(seconds: 6));
      await pumpCategoriesScreen(tester, db: currentDb);
      expect(find.text('Test Category'), findsNothing);
      expect(find.text('No categories yet'), findsOneWidget);
    },
  );
}
