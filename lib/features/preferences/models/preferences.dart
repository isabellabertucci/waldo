import 'package:freezed_annotation/freezed_annotation.dart';

part 'preferences.freezed.dart';

@freezed
abstract class Preferences with _$Preferences {
  const Preferences._();

  const factory Preferences({
    @Default('USD') String currency,
    // null = no explicit choice yet, follow the system theme.
    // true/false = user has explicitly chosen dark or light.
    bool? isDarkMode,
    @Default('yyyy-MM-dd') String dateFormat,
  }) = _Preferences;

  Map<String, Object?> toMap() {
    return {
      'preferred_currency': currency,
      'theme_dark': isDarkMode == null ? null : (isDarkMode! ? 1 : 0),
      'date_format': dateFormat,
    };
  }

  factory Preferences.fromMap(Map<String, Object?> map) {
    final themeDark = map['theme_dark'] as int?;
    return Preferences(
      currency: map['preferred_currency'] as String,
      isDarkMode: themeDark == null ? null : themeDark == 1,
      dateFormat: map['date_format'] as String,
    );
  }
}
