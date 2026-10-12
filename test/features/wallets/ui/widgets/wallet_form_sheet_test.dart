import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:waldo/features/wallets/ui/widgets/wallet_form_sheet.dart';

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
}
