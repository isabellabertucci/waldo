import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:waldo/core/constants/db_constants.dart';
import 'package:waldo/core/constants/enums.dart';

part 'preferences.freezed.dart';

@freezed
abstract class Preferences with _$Preferences {
  const Preferences._();

  const factory Preferences({
    @Default(Currency.usd) Currency currency,
    // null = no explicit choice yet, follow the system theme.
    // true/false = user has explicitly chosen dark or light.
    bool? isDarkMode,
    @Default('yyyy-MM-dd') String dateFormat,
    // The eye toggle: amounts masked app-wide, kept across launches.
    @Default(false) bool isBalanceHidden,
  }) = _Preferences;

  Map<String, Object?> toMap() {
    return {
      PreferencesTable.preferredCurrency: currency.name,
      PreferencesTable.themeDark: isDarkMode == null
          ? null
          : (isDarkMode! ? 1 : 0),
      PreferencesTable.dateFormat: dateFormat,
      PreferencesTable.balanceHidden: isBalanceHidden ? 1 : 0,
    };
  }

  factory Preferences.fromMap(Map<String, Object?> map) {
    final themeDark = map[PreferencesTable.themeDark] as int?;
    return Preferences(
      currency: Currency.values.byName(
        map[PreferencesTable.preferredCurrency] as String,
      ),
      isDarkMode: themeDark == null ? null : themeDark == 1,
      dateFormat: map[PreferencesTable.dateFormat] as String,
      isBalanceHidden: (map[PreferencesTable.balanceHidden] as int?) == 1,
    );
  }
}
