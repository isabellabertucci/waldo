import 'package:waldo/core/constants/enums.dart';
import 'package:waldo/l10n/app_localizations.dart';

extension CurrencyLabel on Currency {
  /// The currency's full name, e.g. "US dollar" - used in the currency
  /// picker sheet, where [code] (already shown alongside it) covers the
  /// short "USD" form.
  String fullName(AppLocalizations l10n) {
    return switch (this) {
      Currency.usd => l10n.currencyNameUsd,
      Currency.eur => l10n.currencyNameEur,
      Currency.gbp => l10n.currencyNameGbp,
    };
  }

  /// The currency's symbol alone, e.g. "$" - distinct from [Currency.code]
  /// (the 3-letter ISO code), used for the picker's icon badge.
  String get symbol {
    return switch (this) {
      Currency.usd => r'$',
      Currency.eur => '€',
      Currency.gbp => '£',
    };
  }
}
