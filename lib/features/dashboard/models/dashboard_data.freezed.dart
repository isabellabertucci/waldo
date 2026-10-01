// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'dashboard_data.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CategorySpending {

 Category get category; int get amount;// null when there was no spending in this category last month, so a
// percentage change can't be computed (would be a divide-by-zero).
 double? get percentChangeFromLastMonth;
/// Create a copy of CategorySpending
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CategorySpendingCopyWith<CategorySpending> get copyWith => _$CategorySpendingCopyWithImpl<CategorySpending>(this as CategorySpending, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CategorySpending&&(identical(other.category, category) || other.category == category)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.percentChangeFromLastMonth, percentChangeFromLastMonth) || other.percentChangeFromLastMonth == percentChangeFromLastMonth));
}


@override
int get hashCode => Object.hash(runtimeType,category,amount,percentChangeFromLastMonth);

@override
String toString() {
  return 'CategorySpending(category: $category, amount: $amount, percentChangeFromLastMonth: $percentChangeFromLastMonth)';
}


}

/// @nodoc
abstract mixin class $CategorySpendingCopyWith<$Res>  {
  factory $CategorySpendingCopyWith(CategorySpending value, $Res Function(CategorySpending) _then) = _$CategorySpendingCopyWithImpl;
@useResult
$Res call({
 Category category, int amount, double? percentChangeFromLastMonth
});


$CategoryCopyWith<$Res> get category;

}
/// @nodoc
class _$CategorySpendingCopyWithImpl<$Res>
    implements $CategorySpendingCopyWith<$Res> {
  _$CategorySpendingCopyWithImpl(this._self, this._then);

  final CategorySpending _self;
  final $Res Function(CategorySpending) _then;

/// Create a copy of CategorySpending
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? category = null,Object? amount = null,Object? percentChangeFromLastMonth = freezed,}) {
  return _then(_self.copyWith(
category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as Category,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as int,percentChangeFromLastMonth: freezed == percentChangeFromLastMonth ? _self.percentChangeFromLastMonth : percentChangeFromLastMonth // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}
/// Create a copy of CategorySpending
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CategoryCopyWith<$Res> get category {
  
  return $CategoryCopyWith<$Res>(_self.category, (value) {
    return _then(_self.copyWith(category: value));
  });
}
}


/// Adds pattern-matching-related methods to [CategorySpending].
extension CategorySpendingPatterns on CategorySpending {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CategorySpending value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CategorySpending() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CategorySpending value)  $default,){
final _that = this;
switch (_that) {
case _CategorySpending():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CategorySpending value)?  $default,){
final _that = this;
switch (_that) {
case _CategorySpending() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Category category,  int amount,  double? percentChangeFromLastMonth)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CategorySpending() when $default != null:
return $default(_that.category,_that.amount,_that.percentChangeFromLastMonth);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Category category,  int amount,  double? percentChangeFromLastMonth)  $default,) {final _that = this;
switch (_that) {
case _CategorySpending():
return $default(_that.category,_that.amount,_that.percentChangeFromLastMonth);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Category category,  int amount,  double? percentChangeFromLastMonth)?  $default,) {final _that = this;
switch (_that) {
case _CategorySpending() when $default != null:
return $default(_that.category,_that.amount,_that.percentChangeFromLastMonth);case _:
  return null;

}
}

}

/// @nodoc


class _CategorySpending implements CategorySpending {
  const _CategorySpending({required this.category, required this.amount, required this.percentChangeFromLastMonth});
  

@override final  Category category;
@override final  int amount;
// null when there was no spending in this category last month, so a
// percentage change can't be computed (would be a divide-by-zero).
@override final  double? percentChangeFromLastMonth;

/// Create a copy of CategorySpending
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CategorySpendingCopyWith<_CategorySpending> get copyWith => __$CategorySpendingCopyWithImpl<_CategorySpending>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CategorySpending&&(identical(other.category, category) || other.category == category)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.percentChangeFromLastMonth, percentChangeFromLastMonth) || other.percentChangeFromLastMonth == percentChangeFromLastMonth));
}


@override
int get hashCode => Object.hash(runtimeType,category,amount,percentChangeFromLastMonth);

@override
String toString() {
  return 'CategorySpending(category: $category, amount: $amount, percentChangeFromLastMonth: $percentChangeFromLastMonth)';
}


}

/// @nodoc
abstract mixin class _$CategorySpendingCopyWith<$Res> implements $CategorySpendingCopyWith<$Res> {
  factory _$CategorySpendingCopyWith(_CategorySpending value, $Res Function(_CategorySpending) _then) = __$CategorySpendingCopyWithImpl;
@override @useResult
$Res call({
 Category category, int amount, double? percentChangeFromLastMonth
});


@override $CategoryCopyWith<$Res> get category;

}
/// @nodoc
class __$CategorySpendingCopyWithImpl<$Res>
    implements _$CategorySpendingCopyWith<$Res> {
  __$CategorySpendingCopyWithImpl(this._self, this._then);

  final _CategorySpending _self;
  final $Res Function(_CategorySpending) _then;

/// Create a copy of CategorySpending
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? category = null,Object? amount = null,Object? percentChangeFromLastMonth = freezed,}) {
  return _then(_CategorySpending(
category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as Category,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as int,percentChangeFromLastMonth: freezed == percentChangeFromLastMonth ? _self.percentChangeFromLastMonth : percentChangeFromLastMonth // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}

/// Create a copy of CategorySpending
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CategoryCopyWith<$Res> get category {
  
  return $CategoryCopyWith<$Res>(_self.category, (value) {
    return _then(_self.copyWith(category: value));
  });
}
}

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

/// @nodoc
mixin _$DashboardData {

 int get totalBalance; int get monthlyIncome; int get monthlyExpense; List<CategorySpending> get spendingByCategory; List<MonthlyCashFlow> get monthlyCashFlow; List<Transaction> get recentTransactions;
/// Create a copy of DashboardData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DashboardDataCopyWith<DashboardData> get copyWith => _$DashboardDataCopyWithImpl<DashboardData>(this as DashboardData, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DashboardData&&(identical(other.totalBalance, totalBalance) || other.totalBalance == totalBalance)&&(identical(other.monthlyIncome, monthlyIncome) || other.monthlyIncome == monthlyIncome)&&(identical(other.monthlyExpense, monthlyExpense) || other.monthlyExpense == monthlyExpense)&&const DeepCollectionEquality().equals(other.spendingByCategory, spendingByCategory)&&const DeepCollectionEquality().equals(other.monthlyCashFlow, monthlyCashFlow)&&const DeepCollectionEquality().equals(other.recentTransactions, recentTransactions));
}


@override
int get hashCode => Object.hash(runtimeType,totalBalance,monthlyIncome,monthlyExpense,const DeepCollectionEquality().hash(spendingByCategory),const DeepCollectionEquality().hash(monthlyCashFlow),const DeepCollectionEquality().hash(recentTransactions));

@override
String toString() {
  return 'DashboardData(totalBalance: $totalBalance, monthlyIncome: $monthlyIncome, monthlyExpense: $monthlyExpense, spendingByCategory: $spendingByCategory, monthlyCashFlow: $monthlyCashFlow, recentTransactions: $recentTransactions)';
}


}

/// @nodoc
abstract mixin class $DashboardDataCopyWith<$Res>  {
  factory $DashboardDataCopyWith(DashboardData value, $Res Function(DashboardData) _then) = _$DashboardDataCopyWithImpl;
@useResult
$Res call({
 int totalBalance, int monthlyIncome, int monthlyExpense, List<CategorySpending> spendingByCategory, List<MonthlyCashFlow> monthlyCashFlow, List<Transaction> recentTransactions
});




}
/// @nodoc
class _$DashboardDataCopyWithImpl<$Res>
    implements $DashboardDataCopyWith<$Res> {
  _$DashboardDataCopyWithImpl(this._self, this._then);

  final DashboardData _self;
  final $Res Function(DashboardData) _then;

/// Create a copy of DashboardData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? totalBalance = null,Object? monthlyIncome = null,Object? monthlyExpense = null,Object? spendingByCategory = null,Object? monthlyCashFlow = null,Object? recentTransactions = null,}) {
  return _then(_self.copyWith(
totalBalance: null == totalBalance ? _self.totalBalance : totalBalance // ignore: cast_nullable_to_non_nullable
as int,monthlyIncome: null == monthlyIncome ? _self.monthlyIncome : monthlyIncome // ignore: cast_nullable_to_non_nullable
as int,monthlyExpense: null == monthlyExpense ? _self.monthlyExpense : monthlyExpense // ignore: cast_nullable_to_non_nullable
as int,spendingByCategory: null == spendingByCategory ? _self.spendingByCategory : spendingByCategory // ignore: cast_nullable_to_non_nullable
as List<CategorySpending>,monthlyCashFlow: null == monthlyCashFlow ? _self.monthlyCashFlow : monthlyCashFlow // ignore: cast_nullable_to_non_nullable
as List<MonthlyCashFlow>,recentTransactions: null == recentTransactions ? _self.recentTransactions : recentTransactions // ignore: cast_nullable_to_non_nullable
as List<Transaction>,
  ));
}

}


/// Adds pattern-matching-related methods to [DashboardData].
extension DashboardDataPatterns on DashboardData {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DashboardData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DashboardData() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DashboardData value)  $default,){
final _that = this;
switch (_that) {
case _DashboardData():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DashboardData value)?  $default,){
final _that = this;
switch (_that) {
case _DashboardData() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int totalBalance,  int monthlyIncome,  int monthlyExpense,  List<CategorySpending> spendingByCategory,  List<MonthlyCashFlow> monthlyCashFlow,  List<Transaction> recentTransactions)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DashboardData() when $default != null:
return $default(_that.totalBalance,_that.monthlyIncome,_that.monthlyExpense,_that.spendingByCategory,_that.monthlyCashFlow,_that.recentTransactions);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int totalBalance,  int monthlyIncome,  int monthlyExpense,  List<CategorySpending> spendingByCategory,  List<MonthlyCashFlow> monthlyCashFlow,  List<Transaction> recentTransactions)  $default,) {final _that = this;
switch (_that) {
case _DashboardData():
return $default(_that.totalBalance,_that.monthlyIncome,_that.monthlyExpense,_that.spendingByCategory,_that.monthlyCashFlow,_that.recentTransactions);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int totalBalance,  int monthlyIncome,  int monthlyExpense,  List<CategorySpending> spendingByCategory,  List<MonthlyCashFlow> monthlyCashFlow,  List<Transaction> recentTransactions)?  $default,) {final _that = this;
switch (_that) {
case _DashboardData() when $default != null:
return $default(_that.totalBalance,_that.monthlyIncome,_that.monthlyExpense,_that.spendingByCategory,_that.monthlyCashFlow,_that.recentTransactions);case _:
  return null;

}
}

}

/// @nodoc


class _DashboardData implements DashboardData {
  const _DashboardData({required this.totalBalance, required this.monthlyIncome, required this.monthlyExpense, required final  List<CategorySpending> spendingByCategory, required final  List<MonthlyCashFlow> monthlyCashFlow, required final  List<Transaction> recentTransactions}): _spendingByCategory = spendingByCategory,_monthlyCashFlow = monthlyCashFlow,_recentTransactions = recentTransactions;
  

@override final  int totalBalance;
@override final  int monthlyIncome;
@override final  int monthlyExpense;
 final  List<CategorySpending> _spendingByCategory;
@override List<CategorySpending> get spendingByCategory {
  if (_spendingByCategory is EqualUnmodifiableListView) return _spendingByCategory;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_spendingByCategory);
}

 final  List<MonthlyCashFlow> _monthlyCashFlow;
@override List<MonthlyCashFlow> get monthlyCashFlow {
  if (_monthlyCashFlow is EqualUnmodifiableListView) return _monthlyCashFlow;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_monthlyCashFlow);
}

 final  List<Transaction> _recentTransactions;
@override List<Transaction> get recentTransactions {
  if (_recentTransactions is EqualUnmodifiableListView) return _recentTransactions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_recentTransactions);
}


/// Create a copy of DashboardData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DashboardDataCopyWith<_DashboardData> get copyWith => __$DashboardDataCopyWithImpl<_DashboardData>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DashboardData&&(identical(other.totalBalance, totalBalance) || other.totalBalance == totalBalance)&&(identical(other.monthlyIncome, monthlyIncome) || other.monthlyIncome == monthlyIncome)&&(identical(other.monthlyExpense, monthlyExpense) || other.monthlyExpense == monthlyExpense)&&const DeepCollectionEquality().equals(other._spendingByCategory, _spendingByCategory)&&const DeepCollectionEquality().equals(other._monthlyCashFlow, _monthlyCashFlow)&&const DeepCollectionEquality().equals(other._recentTransactions, _recentTransactions));
}


@override
int get hashCode => Object.hash(runtimeType,totalBalance,monthlyIncome,monthlyExpense,const DeepCollectionEquality().hash(_spendingByCategory),const DeepCollectionEquality().hash(_monthlyCashFlow),const DeepCollectionEquality().hash(_recentTransactions));

@override
String toString() {
  return 'DashboardData(totalBalance: $totalBalance, monthlyIncome: $monthlyIncome, monthlyExpense: $monthlyExpense, spendingByCategory: $spendingByCategory, monthlyCashFlow: $monthlyCashFlow, recentTransactions: $recentTransactions)';
}


}

/// @nodoc
abstract mixin class _$DashboardDataCopyWith<$Res> implements $DashboardDataCopyWith<$Res> {
  factory _$DashboardDataCopyWith(_DashboardData value, $Res Function(_DashboardData) _then) = __$DashboardDataCopyWithImpl;
@override @useResult
$Res call({
 int totalBalance, int monthlyIncome, int monthlyExpense, List<CategorySpending> spendingByCategory, List<MonthlyCashFlow> monthlyCashFlow, List<Transaction> recentTransactions
});




}
/// @nodoc
class __$DashboardDataCopyWithImpl<$Res>
    implements _$DashboardDataCopyWith<$Res> {
  __$DashboardDataCopyWithImpl(this._self, this._then);

  final _DashboardData _self;
  final $Res Function(_DashboardData) _then;

/// Create a copy of DashboardData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? totalBalance = null,Object? monthlyIncome = null,Object? monthlyExpense = null,Object? spendingByCategory = null,Object? monthlyCashFlow = null,Object? recentTransactions = null,}) {
  return _then(_DashboardData(
totalBalance: null == totalBalance ? _self.totalBalance : totalBalance // ignore: cast_nullable_to_non_nullable
as int,monthlyIncome: null == monthlyIncome ? _self.monthlyIncome : monthlyIncome // ignore: cast_nullable_to_non_nullable
as int,monthlyExpense: null == monthlyExpense ? _self.monthlyExpense : monthlyExpense // ignore: cast_nullable_to_non_nullable
as int,spendingByCategory: null == spendingByCategory ? _self._spendingByCategory : spendingByCategory // ignore: cast_nullable_to_non_nullable
as List<CategorySpending>,monthlyCashFlow: null == monthlyCashFlow ? _self._monthlyCashFlow : monthlyCashFlow // ignore: cast_nullable_to_non_nullable
as List<MonthlyCashFlow>,recentTransactions: null == recentTransactions ? _self._recentTransactions : recentTransactions // ignore: cast_nullable_to_non_nullable
as List<Transaction>,
  ));
}


}

// dart format on
