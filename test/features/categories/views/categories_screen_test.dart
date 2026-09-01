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

  // Named so it always sorts last alphabetically (after the 5 seeded
  // categories), keeping `.last` finders reliable across tests.
  const testCategoryName = 'ZZZ Test Category';

  Future<void> createCategory(WidgetTester tester, String name) async {
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    await tester.enterText(find.widgetWithText(TextFormField, 'Name'), name);
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
  }

  testWidgets('Shows the 5 default categories on first launch', (tester) async {
    await pumpCategoriesScreen(tester);

    expect(find.text('Groceries'), findsOneWidget);
    expect(find.text('Transportation'), findsOneWidget);
    expect(find.text('Subscriptions'), findsOneWidget);
    expect(find.text('Education'), findsOneWidget);
    expect(find.text('Investments'), findsOneWidget);
  });

  testWidgets('Creating a category adds it to the list', (tester) async {
    await pumpCategoriesScreen(tester);
    await createCategory(tester, testCategoryName);

    expect(find.text(testCategoryName), findsOneWidget);
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
    await createCategory(tester, testCategoryName);

    await tester.tap(find.byIcon(Icons.delete).last);
    await tester.pumpAndSettle();

    expect(find.text('Delete category?'), findsOneWidget);
    expect(find.text(testCategoryName), findsOneWidget);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(find.text(testCategoryName), findsOneWidget);
  });

  testWidgets(
    'Confirming delete hides the category immediately and shows a snackbar',
    (tester) async {
      await pumpCategoriesScreen(tester);
      await createCategory(tester, testCategoryName);

      await tester.tap(find.byIcon(Icons.delete).last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 250));

      expect(find.text(testCategoryName), findsNothing);
      expect(find.text('Category deleted'), findsOneWidget);
      expect(find.text('Undo'), findsOneWidget);

      await tester.pump(const Duration(seconds: 6));
    },
  );

  testWidgets('Tapping Undo restores the category to the list', (tester) async {
    await pumpCategoriesScreen(tester);
    await createCategory(tester, testCategoryName);

    await tester.tap(find.byIcon(Icons.delete).last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));

    expect(find.text(testCategoryName), findsNothing);

    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();

    expect(find.text(testCategoryName), findsOneWidget);

    await tester.pump(const Duration(seconds: 6));
    expect(find.text(testCategoryName), findsOneWidget);
  });

  testWidgets(
    'Not tapping Undo permanently deletes the category after 5 seconds',
    (tester) async {
      await pumpCategoriesScreen(tester);
      await createCategory(tester, testCategoryName);
      await tester.tap(find.byIcon(Icons.delete).last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 250));
      expect(find.text(testCategoryName), findsNothing);
      await tester.pump(const Duration(seconds: 6));
      await pumpCategoriesScreen(tester, db: currentDb);
      expect(find.text(testCategoryName), findsNothing);
    },
  );
}
