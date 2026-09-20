import 'package:waldo/core/constants/enums.dart';
import 'package:waldo/l10n/app_localizations.dart';

extension CurrencyLabel on Currency {
  String label(AppLocalizations l10n) {
    return switch (this) {
      Currency.usd => l10n.currencyOptionUsd,
      Currency.eur => l10n.currencyOptionEur,
      Currency.gbp => l10n.currencyOptionGbp,
    };
  }
}
