import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:waldo/features/wallets/ui/widgets/wallet_form_sheet.dart';

import '../../../../helpers/sheet_keyboard.dart';
import '../../../../helpers/test_app.dart';

void main() {
  Database? currentDb;

  tearDown(() async {
    await currentDb?.close();
    currentDb = null;
  });

  testWidgets(
    'On a small phone the sheet stays below the status bar and scrolls',
    (tester) async {
      // iPhone SE: 375x667 with a 20pt status bar.
      tester.view.physicalSize = const Size(375, 667);
      tester.view.devicePixelRatio = 1.0;
      tester.view.padding = const FakeViewPadding(top: 20);
      addTearDown(tester.view.reset);

      currentDb = await pumpWidgetWithProviders(
        tester,
        Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => showWalletFormSheet(context),
              child: const Text('open'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(
        tester.getTopLeft(find.byType(WalletFormSheet)).dy,
        greaterThanOrEqualTo(20),
      );

      await tester.ensureVisible(find.text('Create wallet'));
      await tester.pumpAndSettle();
      expect(find.text('Create wallet').hitTestable(), findsOneWidget);
    },
  );

  testWidgets('On a small Android phone with large text, dragging the sheet '
      'reveals the button above the navigation bar', (tester) async {
    // 360x640 with a 24dp status bar and a 48dp three-button nav bar.
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1.0;
    tester.view.padding = const FakeViewPadding(top: 24, bottom: 48);
    tester.platformDispatcher.textScaleFactorTestValue = 1.3;
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    currentDb = await pumpWidgetWithProviders(
      tester,
      Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () => showWalletFormSheet(context),
            child: const Text('open'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    await tester.drag(find.text('TYPE'), const Offset(0, -400));
    await tester.pumpAndSettle();

    // The content really overflowed, so the drag scrolled it.
    final scrollable = tester.state<ScrollableState>(
      find
          .descendant(
            of: find.byType(WalletFormSheet),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    expect(scrollable.position.pixels, greaterThan(0));

    final button = find.text('Create wallet');
    expect(button.hitTestable(), findsOneWidget);
    expect(tester.getBottomLeft(button).dy, lessThanOrEqualTo(640 - 48));
  });

  testWidgets('With the keyboard open the sheet scrolls instead of '
      'overflowing', (tester) async {
    useSmallAndroidPhone(tester);
    currentDb = await pumpWidgetWithProviders(
      tester,
      Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () => showWalletFormSheet(context),
            child: const Text('open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    await expectSheetScrollsWithKeyboard(
      tester,
      field: find.byKey(const Key('walletNameField')),
      sheet: find.byType(WalletFormSheet),
      lastButton: find.text('Create wallet'),
    );
  });
}
