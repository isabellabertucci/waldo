import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:waldo/l10n/app_localizations.dart';

/// The app's delegates, with Flutter's own strings in European Portuguese:
/// plain `pt` reads as Brazilian ("Guia 1 de 3"), and a pt_PT locale would
/// also change the dates. The first delegate of a type wins.
const appLocalizationsDelegates = <LocalizationsDelegate<dynamic>>[
  _EuropeanPortuguese<MaterialLocalizations>(
    GlobalMaterialLocalizations.delegate,
  ),
  _EuropeanPortuguese<CupertinoLocalizations>(
    GlobalCupertinoLocalizations.delegate,
  ),
  _EuropeanPortuguese<WidgetsLocalizations>(
    GlobalWidgetsLocalizations.delegate,
  ),
  ...AppLocalizations.localizationsDelegates,
];

class _EuropeanPortuguese<T> extends LocalizationsDelegate<T> {
  const _EuropeanPortuguese(this._delegate);

  final LocalizationsDelegate<T> _delegate;

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'pt';

  @override
  Future<T> load(Locale locale) => _delegate.load(const Locale('pt', 'PT'));

  @override
  bool shouldReload(_EuropeanPortuguese<T> old) => false;
}
