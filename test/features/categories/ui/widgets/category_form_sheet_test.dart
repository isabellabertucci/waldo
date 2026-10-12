import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:waldo/features/categories/ui/widgets/category_form_sheet.dart';

import '../../../../helpers/sheet_keyboard.dart';
import '../../../../helpers/test_app.dart';

void main() {
  testWidgets('With the keyboard open the sheet scrolls instead of '
      'overflowing', (tester) async {
    useSmallAndroidPhone(tester);
    final db = await pumpWidgetWithProviders(
      tester,
      Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () => showModalBottomSheet<void>(
              context: context,
              useRootNavigator: true,
              isScrollControlled: true,
              useSafeArea: true,
              builder: (_) => const CategoryFormSheet(),
            ),
            child: const Text('open'),
          ),
        ),
      ),
    );
    addTearDown(db.close);
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    await expectSheetScrollsWithKeyboard(
      tester,
      field: find.byKey(const Key('categoryNameField')),
      sheet: find.byType(CategoryFormSheet),
      lastButton: find.text('Create category'),
    );
  });
}
