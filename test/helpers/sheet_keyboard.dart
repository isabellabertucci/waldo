import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// A 360x640 Android phone with a status bar and a three-button nav bar.
void useSmallAndroidPhone(WidgetTester tester) {
  tester.view.physicalSize = const Size(360, 640);
  tester.view.devicePixelRatio = 1.0;
  tester.view.padding = const FakeViewPadding(top: 24, bottom: 48);
  addTearDown(tester.view.reset);
}

const _keyboardHeight = 300.0;

/// Focuses [field], opens a keyboard, then drags [sheet] up from its top (the
/// part the keyboard never covers): the sheet must not overflow and
/// [lastButton] must end up tappable above the keyboard.
Future<void> expectSheetScrollsWithKeyboard(
  WidgetTester tester, {
  required Finder field,
  required Finder sheet,
  required Finder lastButton,
}) async {
  await tester.showKeyboard(field);
  tester.view.viewInsets = const FakeViewPadding(bottom: _keyboardHeight);
  await tester.pumpAndSettle();
  expect(tester.takeException(), isNull);

  final top = tester.getRect(sheet);
  await tester.dragFrom(
    Offset(top.center.dx, top.top + 60),
    const Offset(0, -600),
  );
  await tester.pumpAndSettle();
  expect(tester.takeException(), isNull);
  expect(lastButton.hitTestable(), findsOneWidget);
  final screenHeight = tester.view.physicalSize.height;
  expect(
    tester.getBottomLeft(lastButton).dy,
    lessThanOrEqualTo(screenHeight - _keyboardHeight),
  );
}
