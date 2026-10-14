import 'package:flutter/services.dart';
import 'package:waldo/core/constants/app_constants.dart';

/// Lets an amount field accept only what [parseToCents] can read: an optional
/// "-", up to [maxAmountWholeDigits] digits, and up to two decimals after "."
/// or ",". Any other keystroke is ignored, so a too-big amount can't be typed.
class AmountInputFormatter extends TextInputFormatter {
  const AmountInputFormatter({this.allowNegative = false});

  final bool allowNegative;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final sign = allowNegative ? '-?' : '';
    final shape = RegExp(
      '^$sign\\d{0,$maxAmountWholeDigits}(?:[.,]\\d{0,2})?\$',
    );
    return shape.hasMatch(newValue.text) ? newValue : oldValue;
  }
}
