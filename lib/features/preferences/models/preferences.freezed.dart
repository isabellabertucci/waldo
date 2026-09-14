// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'preferences.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Preferences {

 String get currency;// null = no explicit choice yet, follow the system theme.
// true/false = user has explicitly chosen dark or light.
 bool? get isDarkMode; String get dateFormat;
/// Create a copy of Preferences
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PreferencesCopyWith<Preferences> get copyWith => _$PreferencesCopyWithImpl<Preferences>(this as Preferences, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Preferences&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.isDarkMode, isDarkMode) || other.isDarkMode == isDarkMode)&&(identical(other.dateFormat, dateFormat) || other.dateFormat == dateFormat));
}


@override
int get hashCode => Object.hash(runtimeType,currency,isDarkMode,dateFormat);

@override
String toString() {
  return 'Preferences(currency: $currency, isDarkMode: $isDarkMode, dateFormat: $dateFormat)';
}


}

/// @nodoc
abstract mixin class $PreferencesCopyWith<$Res>  {
  factory $PreferencesCopyWith(Preferences value, $Res Function(Preferences) _then) = _$PreferencesCopyWithImpl;
@useResult
$Res call({
 String currency, bool? isDarkMode, String dateFormat
});




}
/// @nodoc
class _$PreferencesCopyWithImpl<$Res>
    implements $PreferencesCopyWith<$Res> {
  _$PreferencesCopyWithImpl(this._self, this._then);

  final Preferences _self;
  final $Res Function(Preferences) _then;

/// Create a copy of Preferences
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? currency = null,Object? isDarkMode = freezed,Object? dateFormat = null,}) {
  return _then(_self.copyWith(
currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,isDarkMode: freezed == isDarkMode ? _self.isDarkMode : isDarkMode // ignore: cast_nullable_to_non_nullable
as bool?,dateFormat: null == dateFormat ? _self.dateFormat : dateFormat // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [Preferences].
extension PreferencesPatterns on Preferences {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Preferences value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Preferences() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Preferences value)  $default,){
final _that = this;
switch (_that) {
case _Preferences():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Preferences value)?  $default,){
final _that = this;
switch (_that) {
case _Preferences() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String currency,  bool? isDarkMode,  String dateFormat)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Preferences() when $default != null:
return $default(_that.currency,_that.isDarkMode,_that.dateFormat);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String currency,  bool? isDarkMode,  String dateFormat)  $default,) {final _that = this;
switch (_that) {
case _Preferences():
return $default(_that.currency,_that.isDarkMode,_that.dateFormat);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String currency,  bool? isDarkMode,  String dateFormat)?  $default,) {final _that = this;
switch (_that) {
case _Preferences() when $default != null:
return $default(_that.currency,_that.isDarkMode,_that.dateFormat);case _:
  return null;

}
}

}

/// @nodoc


class _Preferences extends Preferences {
  const _Preferences({this.currency = 'USD', this.isDarkMode, this.dateFormat = 'yyyy-MM-dd'}): super._();
  

@override@JsonKey() final  String currency;
// null = no explicit choice yet, follow the system theme.
// true/false = user has explicitly chosen dark or light.
@override final  bool? isDarkMode;
@override@JsonKey() final  String dateFormat;

/// Create a copy of Preferences
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PreferencesCopyWith<_Preferences> get copyWith => __$PreferencesCopyWithImpl<_Preferences>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Preferences&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.isDarkMode, isDarkMode) || other.isDarkMode == isDarkMode)&&(identical(other.dateFormat, dateFormat) || other.dateFormat == dateFormat));
}


@override
int get hashCode => Object.hash(runtimeType,currency,isDarkMode,dateFormat);

@override
String toString() {
  return 'Preferences(currency: $currency, isDarkMode: $isDarkMode, dateFormat: $dateFormat)';
}


}

/// @nodoc
abstract mixin class _$PreferencesCopyWith<$Res> implements $PreferencesCopyWith<$Res> {
  factory _$PreferencesCopyWith(_Preferences value, $Res Function(_Preferences) _then) = __$PreferencesCopyWithImpl;
@override @useResult
$Res call({
 String currency, bool? isDarkMode, String dateFormat
});




}
/// @nodoc
class __$PreferencesCopyWithImpl<$Res>
    implements _$PreferencesCopyWith<$Res> {
  __$PreferencesCopyWithImpl(this._self, this._then);

  final _Preferences _self;
  final $Res Function(_Preferences) _then;

/// Create a copy of Preferences
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? currency = null,Object? isDarkMode = freezed,Object? dateFormat = null,}) {
  return _then(_Preferences(
currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,isDarkMode: freezed == isDarkMode ? _self.isDarkMode : isDarkMode // ignore: cast_nullable_to_non_nullable
as bool?,dateFormat: null == dateFormat ? _self.dateFormat : dateFormat // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
