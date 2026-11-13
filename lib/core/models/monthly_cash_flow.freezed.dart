// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'monthly_cash_flow.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$MonthlyCashFlow {

 DateTime get month; int get income; int get expense;
/// Create a copy of MonthlyCashFlow
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MonthlyCashFlowCopyWith<MonthlyCashFlow> get copyWith => _$MonthlyCashFlowCopyWithImpl<MonthlyCashFlow>(this as MonthlyCashFlow, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MonthlyCashFlow&&(identical(other.month, month) || other.month == month)&&(identical(other.income, income) || other.income == income)&&(identical(other.expense, expense) || other.expense == expense));
}


@override
int get hashCode => Object.hash(runtimeType,month,income,expense);

@override
String toString() {
  return 'MonthlyCashFlow(month: $month, income: $income, expense: $expense)';
}


}

/// @nodoc
abstract mixin class $MonthlyCashFlowCopyWith<$Res>  {
  factory $MonthlyCashFlowCopyWith(MonthlyCashFlow value, $Res Function(MonthlyCashFlow) _then) = _$MonthlyCashFlowCopyWithImpl;
@useResult
$Res call({
 DateTime month, int income, int expense
});




}
/// @nodoc
class _$MonthlyCashFlowCopyWithImpl<$Res>
    implements $MonthlyCashFlowCopyWith<$Res> {
  _$MonthlyCashFlowCopyWithImpl(this._self, this._then);

  final MonthlyCashFlow _self;
  final $Res Function(MonthlyCashFlow) _then;

/// Create a copy of MonthlyCashFlow
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? month = null,Object? income = null,Object? expense = null,}) {
  return _then(_self.copyWith(
month: null == month ? _self.month : month // ignore: cast_nullable_to_non_nullable
as DateTime,income: null == income ? _self.income : income // ignore: cast_nullable_to_non_nullable
as int,expense: null == expense ? _self.expense : expense // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [MonthlyCashFlow].
extension MonthlyCashFlowPatterns on MonthlyCashFlow {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MonthlyCashFlow value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MonthlyCashFlow() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MonthlyCashFlow value)  $default,){
final _that = this;
switch (_that) {
case _MonthlyCashFlow():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MonthlyCashFlow value)?  $default,){
final _that = this;
switch (_that) {
case _MonthlyCashFlow() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DateTime month,  int income,  int expense)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MonthlyCashFlow() when $default != null:
return $default(_that.month,_that.income,_that.expense);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DateTime month,  int income,  int expense)  $default,) {final _that = this;
switch (_that) {
case _MonthlyCashFlow():
return $default(_that.month,_that.income,_that.expense);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DateTime month,  int income,  int expense)?  $default,) {final _that = this;
switch (_that) {
case _MonthlyCashFlow() when $default != null:
return $default(_that.month,_that.income,_that.expense);case _:
  return null;

}
}

}

/// @nodoc


class _MonthlyCashFlow implements MonthlyCashFlow {
  const _MonthlyCashFlow({required this.month, required this.income, required this.expense});
  

@override final  DateTime month;
@override final  int income;
@override final  int expense;

/// Create a copy of MonthlyCashFlow
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MonthlyCashFlowCopyWith<_MonthlyCashFlow> get copyWith => __$MonthlyCashFlowCopyWithImpl<_MonthlyCashFlow>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MonthlyCashFlow&&(identical(other.month, month) || other.month == month)&&(identical(other.income, income) || other.income == income)&&(identical(other.expense, expense) || other.expense == expense));
}


@override
int get hashCode => Object.hash(runtimeType,month,income,expense);

@override
String toString() {
  return 'MonthlyCashFlow(month: $month, income: $income, expense: $expense)';
}


}

/// @nodoc
abstract mixin class _$MonthlyCashFlowCopyWith<$Res> implements $MonthlyCashFlowCopyWith<$Res> {
  factory _$MonthlyCashFlowCopyWith(_MonthlyCashFlow value, $Res Function(_MonthlyCashFlow) _then) = __$MonthlyCashFlowCopyWithImpl;
@override @useResult
$Res call({
 DateTime month, int income, int expense
});




}
/// @nodoc
class __$MonthlyCashFlowCopyWithImpl<$Res>
    implements _$MonthlyCashFlowCopyWith<$Res> {
  __$MonthlyCashFlowCopyWithImpl(this._self, this._then);

  final _MonthlyCashFlow _self;
  final $Res Function(_MonthlyCashFlow) _then;

/// Create a copy of MonthlyCashFlow
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? month = null,Object? income = null,Object? expense = null,}) {
  return _then(_MonthlyCashFlow(
month: null == month ? _self.month : month // ignore: cast_nullable_to_non_nullable
as DateTime,income: null == income ? _self.income : income // ignore: cast_nullable_to_non_nullable
as int,expense: null == expense ? _self.expense : expense // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
