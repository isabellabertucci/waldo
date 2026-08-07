import 'package:intl/intl.dart' show NumberFormat;
import 'package:waldo/core/constants/enums.dart';
import 'package:waldo/l10n/app_localizations.dart';

/// Parses a plain amount such as "10", "10.5", or "10.50"
/// into cents without using floating-point arithmetic.
int? parseToCents(String input, {required bool allowNegative}) {
  final value = input.trim();
  if (value.isEmpty) return null;
  final match = RegExp(r'^(-?)(\d+)(?:\.(\d{1,2}))?$').firstMatch(value);
  if (match == null) return null;
  final isNegative = match.group(1) == '-';
  if (isNegative && !allowNegative) return null;
  final wholePart = match.group(2)!;
  final fractionPart = (match.group(3) ?? '').padRight(2, '0');
  final cents = int.parse('$wholePart$fractionPart');
  return isNegative ? -cents : cents;
}

/// Formats cents for input fields, ensuring two decimal places.
String formatCentsForInput(int cents) {
  final formatter = NumberFormat('0.00', 'en_US');
  return formatter.format(cents / 100);
}

/// Formats cents for display using the specified locale.
String formatCents(
  int cents, {
  String locale = 'en_US',
  String currencyCode = 'USD',
}) {
  final formatter = NumberFormat.currency(
    locale: locale,
    name: currencyCode,
    symbol: '\$',
    decimalDigits: 2,
  );
  return formatter.format(cents / 100);
}

/// Returns the translated display label for a wallet type.
String walletTypeLabel(AppLocalizations l10n, WalletType type) {
  return switch (type) {
    WalletType.checking => l10n.walletTypeChecking,
    WalletType.savings => l10n.walletTypeSavings,
    WalletType.cash => l10n.walletTypeCash,
    WalletType.credit => l10n.walletTypeCredit,
    WalletType.investment => l10n.walletTypeInvestment,
  };
}
