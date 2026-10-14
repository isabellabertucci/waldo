// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'transaction_form_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$TransactionFormState {

 String get amount; TransactionType get type; DateTime? get date; int? get walletId; int? get categoryId; String get description;
/// Create a copy of TransactionFormState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TransactionFormStateCopyWith<TransactionFormState> get copyWith => _$TransactionFormStateCopyWithImpl<TransactionFormState>(this as TransactionFormState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TransactionFormState&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.type, type) || other.type == type)&&(identical(other.date, date) || other.date == date)&&(identical(other.walletId, walletId) || other.walletId == walletId)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.description, description) || other.description == description));
}


@override
int get hashCode => Object.hash(runtimeType,amount,type,date,walletId,categoryId,description);

@override
String toString() {
  return 'TransactionFormState(amount: $amount, type: $type, date: $date, walletId: $walletId, categoryId: $categoryId, description: $description)';
}


}

/// @nodoc
abstract mixin class $TransactionFormStateCopyWith<$Res>  {
  factory $TransactionFormStateCopyWith(TransactionFormState value, $Res Function(TransactionFormState) _then) = _$TransactionFormStateCopyWithImpl;
@useResult
$Res call({
 String amount, TransactionType type, DateTime? date, int? walletId, int? categoryId, String description
});




}
/// @nodoc
class _$TransactionFormStateCopyWithImpl<$Res>
    implements $TransactionFormStateCopyWith<$Res> {
  _$TransactionFormStateCopyWithImpl(this._self, this._then);

  final TransactionFormState _self;
  final $Res Function(TransactionFormState) _then;

/// Create a copy of TransactionFormState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? amount = null,Object? type = null,Object? date = freezed,Object? walletId = freezed,Object? categoryId = freezed,Object? description = null,}) {
  return _then(_self.copyWith(
amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as TransactionType,date: freezed == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime?,walletId: freezed == walletId ? _self.walletId : walletId // ignore: cast_nullable_to_non_nullable
as int?,categoryId: freezed == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as int?,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [TransactionFormState].
extension TransactionFormStatePatterns on TransactionFormState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TransactionFormState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TransactionFormState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TransactionFormState value)  $default,){
final _that = this;
switch (_that) {
case _TransactionFormState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TransactionFormState value)?  $default,){
final _that = this;
switch (_that) {
case _TransactionFormState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String amount,  TransactionType type,  DateTime? date,  int? walletId,  int? categoryId,  String description)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TransactionFormState() when $default != null:
return $default(_that.amount,_that.type,_that.date,_that.walletId,_that.categoryId,_that.description);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String amount,  TransactionType type,  DateTime? date,  int? walletId,  int? categoryId,  String description)  $default,) {final _that = this;
switch (_that) {
case _TransactionFormState():
return $default(_that.amount,_that.type,_that.date,_that.walletId,_that.categoryId,_that.description);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String amount,  TransactionType type,  DateTime? date,  int? walletId,  int? categoryId,  String description)?  $default,) {final _that = this;
switch (_that) {
case _TransactionFormState() when $default != null:
return $default(_that.amount,_that.type,_that.date,_that.walletId,_that.categoryId,_that.description);case _:
  return null;

}
}

}

/// @nodoc


class _TransactionFormState implements TransactionFormState {
  const _TransactionFormState({this.amount = '', this.type = TransactionType.expense, this.date, this.walletId, this.categoryId, this.description = ''});
  

@override@JsonKey() final  String amount;
@override@JsonKey() final  TransactionType type;
@override final  DateTime? date;
@override final  int? walletId;
@override final  int? categoryId;
@override@JsonKey() final  String description;

/// Create a copy of TransactionFormState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TransactionFormStateCopyWith<_TransactionFormState> get copyWith => __$TransactionFormStateCopyWithImpl<_TransactionFormState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TransactionFormState&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.type, type) || other.type == type)&&(identical(other.date, date) || other.date == date)&&(identical(other.walletId, walletId) || other.walletId == walletId)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.description, description) || other.description == description));
}


@override
int get hashCode => Object.hash(runtimeType,amount,type,date,walletId,categoryId,description);

@override
String toString() {
  return 'TransactionFormState(amount: $amount, type: $type, date: $date, walletId: $walletId, categoryId: $categoryId, description: $description)';
}


}

/// @nodoc
abstract mixin class _$TransactionFormStateCopyWith<$Res> implements $TransactionFormStateCopyWith<$Res> {
  factory _$TransactionFormStateCopyWith(_TransactionFormState value, $Res Function(_TransactionFormState) _then) = __$TransactionFormStateCopyWithImpl;
@override @useResult
$Res call({
 String amount, TransactionType type, DateTime? date, int? walletId, int? categoryId, String description
});




}
/// @nodoc
class __$TransactionFormStateCopyWithImpl<$Res>
    implements _$TransactionFormStateCopyWith<$Res> {
  __$TransactionFormStateCopyWithImpl(this._self, this._then);

  final _TransactionFormState _self;
  final $Res Function(_TransactionFormState) _then;

/// Create a copy of TransactionFormState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? amount = null,Object? type = null,Object? date = freezed,Object? walletId = freezed,Object? categoryId = freezed,Object? description = null,}) {
  return _then(_TransactionFormState(
amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as TransactionType,date: freezed == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime?,walletId: freezed == walletId ? _self.walletId : walletId // ignore: cast_nullable_to_non_nullable
as int?,categoryId: freezed == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as int?,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
