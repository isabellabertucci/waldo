import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waldo/l10n/app_localizations.dart';

void main() {
  // Portuguese counts 0 as "one" (CLDR), so a bare "one{1 ...}" reads
  // "1 carteira" for none; every count needs its own "=0".
  for (final locale in AppLocalizations.supportedLocales) {
    test('Counts of 0 say 0 in ${locale.languageCode}', () {
      final l10n = lookupAppLocalizations(locale);

      expect(l10n.walletsCountLabel(0), startsWith('0 '));
      expect(l10n.transactionsCountLabel(0), startsWith('0 '));
      expect(l10n.walletsCountLabel(1), startsWith('1 '));
      expect(l10n.transactionsCountLabel(2), startsWith('2 '));
    });
  }

  test('Portuguese counts read as Portuguese', () {
    final l10n = lookupAppLocalizations(const Locale('pt'));

    expect(l10n.transactionsCountLabel(0), '0 transações');
    expect(l10n.transactionsCountLabel(1), '1 transação');
    expect(l10n.walletsCountLabel(0), '0 carteiras');
  });
}
