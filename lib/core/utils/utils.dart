import 'package:intl/intl.dart' show NumberFormat;

/// Shown in place of every money figure while the balance-hidden toggle
/// (the eye button) is on.
const hiddenAmount = '••••••';

/// Parses an amount like "10", "10.5" or "10,50" into cents, with no floating
/// point. Accepts '.' and ',' as the decimal separator.
int? parseToCents(String input, {required bool allowNegative}) {
  final value = input.trim();
  if (value.isEmpty) return null;
  final match = RegExp(r'^(-?)(\d+)(?:[.,](\d{1,2}))?$').firstMatch(value);
  if (match == null) return null;
  final isNegative = match.group(1) == '-';
  if (isNegative && !allowNegative) return null;
  final wholePart = match.group(2)!;
  final fractionPart = (match.group(3) ?? '').padRight(2, '0');
  final cents = int.parse('$wholePart$fractionPart');
  return isNegative ? -cents : cents;
}

String formatCentsForInput(int cents) {
  final formatter = NumberFormat('0.00', 'en_US');
  return formatter.format(cents / 100);
}

String formatCents(
  int cents, {
  String locale = 'en_US',
  String currencyCode = 'USD',
}) {
  final formatter = NumberFormat.simpleCurrency(
    locale: locale,
    name: currencyCode,
  );
  return formatter.format(cents / 100);
}
