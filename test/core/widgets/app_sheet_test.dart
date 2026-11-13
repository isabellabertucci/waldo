import 'package:flutter_test/flutter_test.dart';
import 'package:waldo/core/theme/rounded.dart';
import 'package:waldo/core/widgets/app_sheet.dart';

void main() {
  test("A sheet's corners run parallel to the screen's, 12px in", () {
    expect(FloatingSheet.radius(55), 43);
  });

  test('On a square screen, or one that says nothing, a card\'s corners', () {
    expect(FloatingSheet.radius(0), Rounded.lg);
  });
}
