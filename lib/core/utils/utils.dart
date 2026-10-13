import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart' show Intl, NumberFormat;

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
  // tryParse: a number too big for an int is unreadable, not a crash.
  final cents = int.tryParse('$wholePart$fractionPart');
  if (cents == null) return null;
  return isNegative ? -cents : cents;
}

String formatCentsForInput(int cents) {
  final formatter = NumberFormat('0.00', 'en_US');
  return formatter.format(cents / 100);
}

/// The device's region (pt_PT, en_GB) for money, so a Portuguese phone
/// shows "1,00 €" and an American one "€1.00". Unknown regions fall back.
String moneyLocale(BuildContext context) => Intl.verifiedLocale(
  View.of(context).platformDispatcher.locale.toString(),
  NumberFormat.localeExists,
  onFailure: (_) => 'en_US',
)!;

/// An empty amount field's "0.00" hint, with [locale]'s decimal separator
/// ("0,00" in pt_PT). Both are accepted when typing.
String zeroAmountHint(String locale) => NumberFormat.decimalPatternDigits(
  locale: locale,
  decimalDigits: 2,
).format(0);

String formatCents(
  int cents, {
  required String locale,
  String currencyCode = 'USD',
}) {
  final formatter = NumberFormat.simpleCurrency(
    locale: locale,
    name: currencyCode,
  );
  return formatter.format(cents / 100);
}
