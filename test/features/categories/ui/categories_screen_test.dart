import 'package:flutter/material.dart';
import 'package:waldo/core/theme/app_icons.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:waldo/features/categories/ui/categories_screen.dart';

import '../../../helpers/test_app.dart';

void main() {
  Database? currentDb;

  tearDown(() async {
    await currentDb?.close();
    currentDb = null;
  });

  Future<void> pumpCategoriesScreen(WidgetTester tester, {Database? db}) async {
    // A portrait phone size, so the whole category sheet fits on screen and
    // every button is reachable by a direct tap, like on a real device.
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

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
    await tester.tap(find.byTooltip('New Category'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('categoryNameField')), name);
    await tester.tap(find.text('Create category'));
    await tester.pumpAndSettle();
  }

  /// Opens the custom category's "⋯" menu and picks [action].
  Future<void> chooseFromMenu(WidgetTester tester, String action) async {
    await tester.tap(find.byIcon(AppIcons.more).last);
    await tester.pumpAndSettle();
    await tester.tap(find.text(action));
    await tester.pumpAndSettle();
  }

  /// Menu "Delete", then the confirmation dialog's own "Delete".
  Future<void> deleteFromMenu(WidgetTester tester) async {
    await chooseFromMenu(tester, 'Delete');
    await tester.tap(find.text('Delete'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));
  }

  testWidgets('Shows the 5 default categories on first launch', (tester) async {
    await pumpCategoriesScreen(tester);

    expect(find.text('Groceries'), findsOneWidget);
    expect(find.text('Transportation'), findsOneWidget);
    expect(find.text('Subscriptions'), findsOneWidget);
    expect(find.text('Education'), findsOneWidget);
    expect(find.text('Investments'), findsOneWidget);
  });

  testWidgets('Built-in and custom categories sit in their own sections', (
    tester,
  ) async {
    await pumpCategoriesScreen(tester);

    expect(find.text('BUILT-IN'), findsOneWidget);
    expect(find.text('CUSTOM'), findsNothing);

    await createCategory(tester, testCategoryName);

    expect(find.text('BUILT-IN'), findsOneWidget);
    expect(find.text('CUSTOM'), findsOneWidget);
  });

  testWidgets('Built-in categories have no edit/delete menu', (tester) async {
    await pumpCategoriesScreen(tester);

    expect(find.byIcon(AppIcons.more), findsNothing);
  });

  testWidgets('The header buttons have accessible names', (tester) async {
    await pumpCategoriesScreen(tester);

    expect(find.byTooltip('Back'), findsOneWidget);
    expect(find.byTooltip('New Category'), findsOneWidget);
  });

  testWidgets('Creating a category adds it to the list', (tester) async {
    await pumpCategoriesScreen(tester);
    await createCategory(tester, testCategoryName);

    expect(find.text(testCategoryName), findsOneWidget);
  });

  testWidgets('Editing from the menu renames the category', (tester) async {
    await pumpCategoriesScreen(tester);
    await createCategory(tester, testCategoryName);

    await chooseFromMenu(tester, 'Edit');
    expect(find.text('Edit Category'), findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('categoryNameField')),
      'ZZZ Renamed',
    );
    await tester.tap(find.text('Save changes'));
    await tester.pumpAndSettle();

    expect(find.text('ZZZ Renamed'), findsOneWidget);
    expect(find.text(testCategoryName), findsNothing);
  });

  testWidgets('Shows validation error when name is empty', (tester) async {
    await pumpCategoriesScreen(tester);

    await tester.tap(find.byTooltip('New Category'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Create category'));
    await tester.pumpAndSettle();

    expect(find.text('Name is required'), findsOneWidget);
  });

  testWidgets('Deleting a category shows a confirmation dialog first', (
    tester,
  ) async {
    await pumpCategoriesScreen(tester);
    await createCategory(tester, testCategoryName);

    await chooseFromMenu(tester, 'Delete');

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

      await deleteFromMenu(tester);

      expect(find.text(testCategoryName), findsNothing);
      expect(find.text('Category deleted'), findsOneWidget);
      expect(find.text('Undo'), findsOneWidget);

      await tester.pump(const Duration(seconds: 6));
    },
  );

  testWidgets('Tapping Undo restores the category to the list', (tester) async {
    await pumpCategoriesScreen(tester);
    await createCategory(tester, testCategoryName);

    await deleteFromMenu(tester);
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

      await deleteFromMenu(tester);
      expect(find.text(testCategoryName), findsNothing);

      await tester.pump(const Duration(seconds: 6));
      await pumpCategoriesScreen(tester, db: currentDb);
      expect(find.text(testCategoryName), findsNothing);
    },
  );
}
