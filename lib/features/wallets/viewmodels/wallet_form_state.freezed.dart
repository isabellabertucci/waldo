// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'wallet_form_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$WalletFormState {

 String get name; WalletType get type; String get startingBalance; WalletFormError? get nameError; WalletFormError? get balanceError;
/// Create a copy of WalletFormState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WalletFormStateCopyWith<WalletFormState> get copyWith => _$WalletFormStateCopyWithImpl<WalletFormState>(this as WalletFormState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WalletFormState&&(identical(other.name, name) || other.name == name)&&(identical(other.type, type) || other.type == type)&&(identical(other.startingBalance, startingBalance) || other.startingBalance == startingBalance)&&(identical(other.nameError, nameError) || other.nameError == nameError)&&(identical(other.balanceError, balanceError) || other.balanceError == balanceError));
}


@override
int get hashCode => Object.hash(runtimeType,name,type,startingBalance,nameError,balanceError);

@override
String toString() {
  return 'WalletFormState(name: $name, type: $type, startingBalance: $startingBalance, nameError: $nameError, balanceError: $balanceError)';
}


}

/// @nodoc
abstract mixin class $WalletFormStateCopyWith<$Res>  {
  factory $WalletFormStateCopyWith(WalletFormState value, $Res Function(WalletFormState) _then) = _$WalletFormStateCopyWithImpl;
@useResult
$Res call({
 String name, WalletType type, String startingBalance, WalletFormError? nameError, WalletFormError? balanceError
});




}
/// @nodoc
class _$WalletFormStateCopyWithImpl<$Res>
    implements $WalletFormStateCopyWith<$Res> {
  _$WalletFormStateCopyWithImpl(this._self, this._then);

  final WalletFormState _self;
  final $Res Function(WalletFormState) _then;

/// Create a copy of WalletFormState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? type = null,Object? startingBalance = null,Object? nameError = freezed,Object? balanceError = freezed,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as WalletType,startingBalance: null == startingBalance ? _self.startingBalance : startingBalance // ignore: cast_nullable_to_non_nullable
as String,nameError: freezed == nameError ? _self.nameError : nameError // ignore: cast_nullable_to_non_nullable
as WalletFormError?,balanceError: freezed == balanceError ? _self.balanceError : balanceError // ignore: cast_nullable_to_non_nullable
as WalletFormError?,
  ));
}

}


/// Adds pattern-matching-related methods to [WalletFormState].
extension WalletFormStatePatterns on WalletFormState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WalletFormState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WalletFormState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WalletFormState value)  $default,){
final _that = this;
switch (_that) {
case _WalletFormState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WalletFormState value)?  $default,){
final _that = this;
switch (_that) {
case _WalletFormState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  WalletType type,  String startingBalance,  WalletFormError? nameError,  WalletFormError? balanceError)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WalletFormState() when $default != null:
return $default(_that.name,_that.type,_that.startingBalance,_that.nameError,_that.balanceError);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  WalletType type,  String startingBalance,  WalletFormError? nameError,  WalletFormError? balanceError)  $default,) {final _that = this;
switch (_that) {
case _WalletFormState():
return $default(_that.name,_that.type,_that.startingBalance,_that.nameError,_that.balanceError);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  WalletType type,  String startingBalance,  WalletFormError? nameError,  WalletFormError? balanceError)?  $default,) {final _that = this;
switch (_that) {
case _WalletFormState() when $default != null:
return $default(_that.name,_that.type,_that.startingBalance,_that.nameError,_that.balanceError);case _:
  return null;

}
}

}

/// @nodoc


class _WalletFormState implements WalletFormState {
  const _WalletFormState({this.name = '', this.type = WalletType.cash, this.startingBalance = '', this.nameError, this.balanceError});
  

@override@JsonKey() final  String name;
@override@JsonKey() final  WalletType type;
@override@JsonKey() final  String startingBalance;
@override final  WalletFormError? nameError;
@override final  WalletFormError? balanceError;

/// Create a copy of WalletFormState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WalletFormStateCopyWith<_WalletFormState> get copyWith => __$WalletFormStateCopyWithImpl<_WalletFormState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WalletFormState&&(identical(other.name, name) || other.name == name)&&(identical(other.type, type) || other.type == type)&&(identical(other.startingBalance, startingBalance) || other.startingBalance == startingBalance)&&(identical(other.nameError, nameError) || other.nameError == nameError)&&(identical(other.balanceError, balanceError) || other.balanceError == balanceError));
}


@override
int get hashCode => Object.hash(runtimeType,name,type,startingBalance,nameError,balanceError);

@override
String toString() {
  return 'WalletFormState(name: $name, type: $type, startingBalance: $startingBalance, nameError: $nameError, balanceError: $balanceError)';
}


}

/// @nodoc
abstract mixin class _$WalletFormStateCopyWith<$Res> implements $WalletFormStateCopyWith<$Res> {
  factory _$WalletFormStateCopyWith(_WalletFormState value, $Res Function(_WalletFormState) _then) = __$WalletFormStateCopyWithImpl;
@override @useResult
$Res call({
 String name, WalletType type, String startingBalance, WalletFormError? nameError, WalletFormError? balanceError
});




}
/// @nodoc
class __$WalletFormStateCopyWithImpl<$Res>
    implements _$WalletFormStateCopyWith<$Res> {
  __$WalletFormStateCopyWithImpl(this._self, this._then);

  final _WalletFormState _self;
  final $Res Function(_WalletFormState) _then;

/// Create a copy of WalletFormState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? type = null,Object? startingBalance = null,Object? nameError = freezed,Object? balanceError = freezed,}) {
  return _then(_WalletFormState(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as WalletType,startingBalance: null == startingBalance ? _self.startingBalance : startingBalance // ignore: cast_nullable_to_non_nullable
as String,nameError: freezed == nameError ? _self.nameError : nameError // ignore: cast_nullable_to_non_nullable
as WalletFormError?,balanceError: freezed == balanceError ? _self.balanceError : balanceError // ignore: cast_nullable_to_non_nullable
as WalletFormError?,
  ));
}


}

// dart format on
