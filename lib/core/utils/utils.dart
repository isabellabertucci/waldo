class CurrencyUtils {
  /// Parses a currency string like "10.50" or "-5" into a whole number
  /// of cents, using only string/integer math, never floating point.
  /// Returns null if the input isn't a valid amount, or if it's negative
  /// and [allowNegative] is false.
  static int? parseToCents(String input, {required bool allowNegative}) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) return 0;

    final pattern = RegExp(r'^(-?)(\d+)(?:\.(\d{1,2}))?$');
    final match = pattern.firstMatch(trimmed);
    if (match == null) return null;

    final isNegative = match.group(1) == '-';
    if (isNegative && !allowNegative) return null;

    final wholePart = match.group(2)!;
    final fractionPart = (match.group(3) ?? '').padRight(2, '0');

    final cents = int.parse('$wholePart$fractionPart');
    return isNegative ? -cents : cents;
  }

  /// Formats a whole number of cents back into a display string like
  /// "10.50", using only integer math.
  static String formatCents(int cents) {
    final isNegative = cents < 0;
    final absCents = cents.abs();
    final whole = absCents ~/ 100;
    final fraction = (absCents % 100).toString().padLeft(2, '0');
    return '${isNegative ? '-' : ''}$whole.$fraction';
  }
}
