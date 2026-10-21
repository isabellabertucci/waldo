import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart' hide Transaction;
import 'package:waldo/core/constants/db_constants.dart';
import 'package:waldo/core/constants/enums.dart';
import 'package:waldo/core/theme/app_icons.dart';
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

  Future<void> typeName(WidgetTester tester, String name) async {
    await tester.enterText(find.byKey(const Key('categoryNameField')), name);
    await tester.pump();
  }

  Future<void> tapAdd(WidgetTester tester) async {
    await tester.tap(find.byTooltip('Add category'));
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

  testWidgets('Every category but Others has a named X', (tester) async {
    await pumpCategoriesScreen(tester);

    expect(find.byIcon(AppIcons.close), findsNWidgets(5));
    expect(find.byTooltip('Delete Groceries'), findsOneWidget);
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

  testWidgets('Adding a category lists it and empties the field', (
    tester,
  ) async {
    await pumpCategoriesScreen(tester);

    await typeName(tester, 'Gym');
    await tapAdd(tester);

    expect(find.text('Gym'), findsOneWidget);
    expect(find.byTooltip('Delete Gym'), findsOneWidget);
    expect(
      tester
          .widget<EditableText>(
            find.descendant(
              of: find.byKey(const Key('categoryNameField')),
              matching: find.byType(EditableText),
            ),
          )
          .controller
          .text,
      isEmpty,
    );
  });

  testWidgets('The keyboard done key adds the category too', (tester) async {
    await pumpCategoriesScreen(tester);

    await typeName(tester, 'Gym');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    expect(find.byTooltip('Delete Gym'), findsOneWidget);
  });

  testWidgets('An empty name shows an error and adds nothing', (tester) async {
    await pumpCategoriesScreen(tester);

    await tapAdd(tester);

    expect(find.text('Name is required'), findsOneWidget);
    expect(find.byIcon(AppIcons.close), findsNWidgets(5));
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
    await pumpCategoriesScreen(tester);

    await tester.tap(find.byTooltip('Delete Education'));
    await tester.pumpAndSettle();
    expect(find.text('This will delete "Education".'), findsOneWidget);

    await tester.tap(find.text('Delete'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));

    expect(textOutsideSnackBar('Education'), findsNothing);
    expect(find.text('Category deleted'), findsOneWidget);
    await tester.pump(const Duration(seconds: 6));
  });

  testWidgets('Undo puts the category back', (tester) async {
    await pumpCategoriesScreen(tester);

    await deleteCategory(tester, 'Education');
    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();

    expect(find.text('Education'), findsOneWidget);
    await tester.pump(const Duration(seconds: 6));
  });

  testWidgets('Without Undo, the category is gone after 5 seconds', (
    tester,
  ) async {
    await pumpCategoriesScreen(tester);

    await deleteCategory(tester, 'Education');
    await tester.pump(const Duration(seconds: 6));
    await tester.pumpAndSettle();

    final rows = await currentDb!.query(
      CategoriesTable.table,
      where: '${CategoriesTable.type} = ? AND ${CategoriesTable.isDefault} = 1',
      whereArgs: [CategoryType.education.name],
    );
    expect(rows, isEmpty);
  });

  testWidgets('Deleting a used category says how many transactions move to '
      'Others, and moves them', (tester) async {
    final db = await createTestDatabase();
    final repo = CategoryRepositoryImpl(db);
    final education = (await repo.getAll()).firstWhere(
      (c) => c.type == CategoryType.education,
    );
    final walletId = await db.insert(WalletsTable.table, {
      WalletsTable.name: 'Cash',
      WalletsTable.createdAt: '2026-08-10T12:00:00.000',
    });
    for (var i = 0; i < 2; i++) {
      await db.insert(TransactionsTable.table, {
        TransactionsTable.walletId: walletId,
        TransactionsTable.categoryId: education.id,
        TransactionsTable.amount: 100,
        TransactionsTable.type: TransactionType.expense.name,
        TransactionsTable.date: '2026-08-10T00:00:00.000',
        TransactionsTable.createdAt: '2026-08-10T12:00:00.000',
      });
    }
    await pumpCategoriesScreen(tester, db: db);

    await tester.tap(find.byTooltip('Delete Education'));
    await tester.pumpAndSettle();
    expect(
      find.text(
        '2 transactions use "Education". If you delete it, they move to '
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
