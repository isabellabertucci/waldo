import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart' hide Transaction;
import 'package:waldo/core/constants/db_constants.dart';
import 'package:waldo/core/constants/enums.dart';
import 'package:waldo/core/theme/app_icons.dart';
import 'package:waldo/core/widgets/surface_card.dart';
import 'package:waldo/features/categories/models/category.dart';
import 'package:waldo/features/categories/repositories/category_repository.dart';
import 'package:waldo/features/categories/ui/categories_screen.dart';

import '../../../helpers/test_app.dart';

void main() {
  Database? currentDb;

  tearDown(() async {
    await currentDb?.close();
    currentDb = null;
  });

  Future<void> pumpCategoriesScreen(WidgetTester tester, {Database? db}) async {
    // A portrait phone, so the whole list fits and every X is tappable.
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    currentDb = await pumpWidgetWithProviders(
      tester,
      const CategoriesScreen(),
      db: db,
    );
  }

  /// A database with one category of the user's own, "Gym": the only kind
  /// that can be deleted.
  Future<(Database, int)> dbWithGym() async {
    final db = await createTestDatabase();
    final id = await CategoryRepositoryImpl(
      db,
    ).insert(const Category(name: 'Gym', createdAt: '2026-08-10T12:00:00.000'));
    return (db, id);
  }

  /// The header's "+", which opens the new-category sheet.
  Future<void> openNewCategory(WidgetTester tester) async {
    await tester.tap(find.byTooltip('New category'));
    await tester.pumpAndSettle();
  }

  /// Opens the sheet and types [name] into it.
  Future<void> typeName(WidgetTester tester, String name) async {
    await openNewCategory(tester);
    await tester.enterText(find.byKey(const Key('categoryNameField')), name);
    await tester.pump();
  }

  Future<void> tapAdd(WidgetTester tester) async {
    await tester.tap(find.text('Create category'));
    await tester.pumpAndSettle();
  }

  /// The row's X, then the dialog's "Delete"; leaves the Undo window open.
  Future<void> deleteCategory(WidgetTester tester, String name) async {
    await tester.tap(find.byTooltip('Delete $name'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));
  }

  testWidgets('Lists every category, with Others last', (tester) async {
    await pumpCategoriesScreen(tester);

    for (final name in [
      'Education',
      'Groceries',
      'Investments',
      'Subscriptions',
      'Transportation',
      'Others',
    ]) {
      expect(find.text(name), findsOneWidget);
    }
    expect(
      tester.getTopLeft(find.text('Others')).dy,
      greaterThan(tester.getTopLeft(find.text('Transportation')).dy),
    );
  });

  testWidgets('The categories you made get their own card, below the '
      'built-ins', (tester) async {
    final (db, _) = await dbWithGym();
    await pumpCategoriesScreen(tester, db: db);

    expect(find.byType(SurfaceCard), findsNWidgets(2));
    Finder inCard(int i, String name) => find.descendant(
      of: find.byType(SurfaceCard).at(i),
      matching: find.text(name),
    );
    expect(inCard(0, 'Others'), findsOneWidget);
    expect(inCard(0, 'Gym'), findsNothing);
    expect(inCard(1, 'Gym'), findsOneWidget);
  });

  testWidgets('With none of your own, there is only the built-ins\' card', (
    tester,
  ) async {
    await pumpCategoriesScreen(tester);

    expect(find.byType(SurfaceCard), findsOneWidget);
  });

  testWidgets('Only the categories you made have a named X', (tester) async {
    final (db, _) = await dbWithGym();
    await pumpCategoriesScreen(tester, db: db);

    expect(find.byIcon(AppIcons.close), findsOneWidget);
    expect(find.byTooltip('Delete Gym'), findsOneWidget);
    expect(find.byTooltip('Delete Groceries'), findsNothing);
    expect(find.byTooltip('Delete Others'), findsNothing);
    expect(find.byTooltip('Back'), findsOneWidget);
  });

  testWidgets('A failed add says nothing was changed', (tester) async {
    await pumpCategoriesScreen(tester);
    // No table to write to, so the insert throws.
    await currentDb!.execute('DROP TABLE ${CategoriesTable.table}');

    await typeName(tester, 'Gym');
    await tapAdd(tester);

    expect(
      find.text("Couldn't save the category. Nothing was changed."),
      findsOneWidget,
    );
  });

  testWidgets('Adding a category closes the sheet and lists it', (
    tester,
  ) async {
    await pumpCategoriesScreen(tester);

    await typeName(tester, 'Gym');
    await tapAdd(tester);

    expect(find.text('Create category'), findsNothing, reason: 'sheet closed');
    expect(find.text('Gym'), findsOneWidget);
    expect(find.byTooltip('Delete Gym'), findsOneWidget);
  });

  testWidgets('The keyboard done key adds the category too', (tester) async {
    await pumpCategoriesScreen(tester);

    await typeName(tester, 'Gym');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    expect(find.byTooltip('Delete Gym'), findsOneWidget);
  });

  testWidgets('Tapping your own category renames it', (tester) async {
    await pumpCategoriesScreen(tester);
    await typeName(tester, 'Gym');
    await tapAdd(tester);

    await tester.tap(find.text('Gym'));
    await tester.pumpAndSettle();
    expect(find.text('Edit category'), findsOneWidget);
    await tester.enterText(find.byKey(const Key('categoryNameField')), 'Sport');
    await tester.tap(find.text('Save changes'));
    await tester.pumpAndSettle();

    expect(find.text('Sport'), findsOneWidget);
    expect(find.text('Gym'), findsNothing);
  });

  testWidgets('Keeping the same name in another case is allowed', (
    tester,
  ) async {
    await pumpCategoriesScreen(tester);
    await typeName(tester, 'Gym');
    await tapAdd(tester);

    await tester.tap(find.text('Gym'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('categoryNameField')), 'GYM');
    await tester.tap(find.text('Save changes'));
    await tester.pumpAndSettle();

    expect(find.text('GYM'), findsOneWidget);
  });

  testWidgets('A built-in category, named by the app, opens nothing', (
    tester,
  ) async {
    await pumpCategoriesScreen(tester);

    await tester.tap(find.text('Groceries'));
    await tester.pumpAndSettle();

    expect(find.text('Edit category'), findsNothing);
  });

  testWidgets('An empty name shows an error and adds nothing', (tester) async {
    await pumpCategoriesScreen(tester);
    Future<int> count() async =>
        (await currentDb!.query(CategoriesTable.table)).length;
    final before = await count();

    await openNewCategory(tester);
    await tapAdd(tester);

    expect(find.text('Name is required'), findsOneWidget);
    expect(find.text('Create category'), findsOneWidget, reason: 'still open');
    expect(await count(), before);
  });

  testWidgets('A name matching a listed category warns, ignoring case', (
    tester,
  ) async {
    await pumpCategoriesScreen(tester);

    await typeName(tester, 'groceries');
    await tapAdd(tester);

    expect(find.text('A category with this name already exists'), findsOne);
  });

  testWidgets('A built-in name in another language warns too', (tester) async {
    await pumpCategoriesScreen(tester);

    // "Groceries" in Portuguese, typed while the app is in English.
    await typeName(tester, 'supermercado');
    await tapAdd(tester);

    expect(find.text('A category with this name already exists'), findsOne);
  });

  testWidgets('The name stops at 30 characters and shows a counter', (
    tester,
  ) async {
    await pumpCategoriesScreen(tester);

    await typeName(tester, 'a' * 40);

    expect(find.text('30/30'), findsOneWidget);
  });

  testWidgets('Deleting an unused category asks first, then offers Undo', (
    tester,
  ) async {
    final (db, _) = await dbWithGym();
    await pumpCategoriesScreen(tester, db: db);

    await tester.tap(find.byTooltip('Delete Gym'));
    await tester.pumpAndSettle();
    expect(find.text('This will delete "Gym".'), findsOneWidget);

    await tester.tap(find.text('Delete'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));

    expect(textOutsideSnackBar('Gym'), findsNothing);
    expect(find.text('Category deleted'), findsOneWidget);
    await tester.pump(const Duration(seconds: 6));
  });

  testWidgets('Undo puts the category back', (tester) async {
    final (db, _) = await dbWithGym();
    await pumpCategoriesScreen(tester, db: db);

    await deleteCategory(tester, 'Gym');
    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();

    expect(find.text('Gym'), findsOneWidget);
    await tester.pump(const Duration(seconds: 6));
  });

  testWidgets('Without Undo, the category is gone after 5 seconds', (
    tester,
  ) async {
    final (db, _) = await dbWithGym();
    await pumpCategoriesScreen(tester, db: db);

    await deleteCategory(tester, 'Gym');
    await tester.pump(const Duration(seconds: 6));
    await tester.pumpAndSettle();

    final rows = await currentDb!.query(
      CategoriesTable.table,
      where: '${CategoriesTable.name} = ?',
      whereArgs: ['Gym'],
    );
    expect(rows, isEmpty);
  });

  testWidgets('When the count before deleting fails, the tap still gets an '
      'answer', (tester) async {
    final (db, _) = await dbWithGym();
    await pumpCategoriesScreen(tester, db: db);
    // The X first counts the category's transactions; with no table, it fails.
    await currentDb!.execute('DROP TABLE ${TransactionsTable.table}');

    await tester.tap(find.byTooltip('Delete Gym'));
    await tester.pumpAndSettle();

    expect(
      find.text("Couldn't delete the category. Nothing was changed."),
      findsOneWidget,
    );
    expect(find.text('Delete category?'), findsNothing);
  });

  testWidgets('A failed delete brings the category back and says nothing '
      'was changed', (tester) async {
    final (db, _) = await dbWithGym();
    await pumpCategoriesScreen(tester, db: db);
    await deleteCategory(tester, 'Gym');
    // Deleting moves the category's transactions first; with no table, that
    // fails once the Undo window ends.
    await currentDb!.execute('DROP TABLE ${TransactionsTable.table}');
    await tester.pump(const Duration(seconds: 6));
    await tester.pumpAndSettle();

    expect(
      find.text("Couldn't delete the category. Nothing was changed."),
      findsOneWidget,
    );
    expect(find.text('Gym'), findsOneWidget);
  });

  testWidgets('Deleting a used category says how many transactions move to '
      'Others, and moves them', (tester) async {
    final (db, gymId) = await dbWithGym();
    final repo = CategoryRepositoryImpl(db);
    final walletId = await db.insert(WalletsTable.table, {
      WalletsTable.name: 'Cash',
      WalletsTable.nameKey: 'cash',
      WalletsTable.createdAt: '2026-08-10T12:00:00.000',
    });
    for (var i = 0; i < 2; i++) {
      await db.insert(TransactionsTable.table, {
        TransactionsTable.walletId: walletId,
        TransactionsTable.categoryId: gymId,
        TransactionsTable.amount: 100,
        TransactionsTable.type: TransactionType.expense.name,
        TransactionsTable.date: '2026-08-10T00:00:00.000',
        TransactionsTable.createdAt: '2026-08-10T12:00:00.000',
      });
    }
    await pumpCategoriesScreen(tester, db: db);

    await tester.tap(find.byTooltip('Delete Gym'));
    await tester.pumpAndSettle();
    expect(
      find.text(
        '2 transactions use "Gym". If you delete it, they move to '
        'Others.',
      ),
      findsOneWidget,
    );

    await tester.tap(find.text('Delete'));
    await tester.pump(const Duration(seconds: 6));
    await tester.pumpAndSettle();

    final others = await repo.getOthers();
    expect(await repo.countTransactions(others.id!), 2);
  });
}
