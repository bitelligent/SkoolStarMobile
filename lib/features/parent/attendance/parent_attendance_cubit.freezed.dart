// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'parent_attendance_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ParentAttendanceState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ParentAttendanceState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ParentAttendanceState()';
}


}

/// @nodoc
class $ParentAttendanceStateCopyWith<$Res>  {
$ParentAttendanceStateCopyWith(ParentAttendanceState _, $Res Function(ParentAttendanceState) __);
}


/// Adds pattern-matching-related methods to [ParentAttendanceState].
extension ParentAttendanceStatePatterns on ParentAttendanceState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( ParentAttendanceInitial value)?  initial,TResult Function( ParentAttendanceLoading value)?  loading,TResult Function( ParentAttendanceError value)?  error,TResult Function( ParentAttendanceLoaded value)?  loaded,required TResult orElse(),}){
final _that = this;
switch (_that) {
case ParentAttendanceInitial() when initial != null:
return initial(_that);case ParentAttendanceLoading() when loading != null:
return loading(_that);case ParentAttendanceError() when error != null:
return error(_that);case ParentAttendanceLoaded() when loaded != null:
return loaded(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( ParentAttendanceInitial value)  initial,required TResult Function( ParentAttendanceLoading value)  loading,required TResult Function( ParentAttendanceError value)  error,required TResult Function( ParentAttendanceLoaded value)  loaded,}){
final _that = this;
switch (_that) {
case ParentAttendanceInitial():
return initial(_that);case ParentAttendanceLoading():
return loading(_that);case ParentAttendanceError():
return error(_that);case ParentAttendanceLoaded():
return loaded(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( ParentAttendanceInitial value)?  initial,TResult? Function( ParentAttendanceLoading value)?  loading,TResult? Function( ParentAttendanceError value)?  error,TResult? Function( ParentAttendanceLoaded value)?  loaded,}){
final _that = this;
switch (_that) {
case ParentAttendanceInitial() when initial != null:
return initial(_that);case ParentAttendanceLoading() when loading != null:
return loading(_that);case ParentAttendanceError() when error != null:
return error(_that);case ParentAttendanceLoaded() when loaded != null:
return loaded(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initial,TResult Function()?  loading,TResult Function( String message)?  error,TResult Function( Child child,  List<ChildAttendanceRecord> records,  String filter)?  loaded,required TResult orElse(),}) {final _that = this;
switch (_that) {
case ParentAttendanceInitial() when initial != null:
return initial();case ParentAttendanceLoading() when loading != null:
return loading();case ParentAttendanceError() when error != null:
return error(_that.message);case ParentAttendanceLoaded() when loaded != null:
return loaded(_that.child,_that.records,_that.filter);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initial,required TResult Function()  loading,required TResult Function( String message)  error,required TResult Function( Child child,  List<ChildAttendanceRecord> records,  String filter)  loaded,}) {final _that = this;
switch (_that) {
case ParentAttendanceInitial():
return initial();case ParentAttendanceLoading():
return loading();case ParentAttendanceError():
return error(_that.message);case ParentAttendanceLoaded():
return loaded(_that.child,_that.records,_that.filter);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initial,TResult? Function()?  loading,TResult? Function( String message)?  error,TResult? Function( Child child,  List<ChildAttendanceRecord> records,  String filter)?  loaded,}) {final _that = this;
switch (_that) {
case ParentAttendanceInitial() when initial != null:
return initial();case ParentAttendanceLoading() when loading != null:
return loading();case ParentAttendanceError() when error != null:
return error(_that.message);case ParentAttendanceLoaded() when loaded != null:
return loaded(_that.child,_that.records,_that.filter);case _:
  return null;

}
}

}

/// @nodoc


class ParentAttendanceInitial extends ParentAttendanceState {
  const ParentAttendanceInitial(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ParentAttendanceInitial);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ParentAttendanceState.initial()';
}


}




/// @nodoc


class ParentAttendanceLoading extends ParentAttendanceState {
  const ParentAttendanceLoading(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ParentAttendanceLoading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ParentAttendanceState.loading()';
}


}




/// @nodoc


class ParentAttendanceError extends ParentAttendanceState {
  const ParentAttendanceError(this.message): super._();
  

 final  String message;

/// Create a copy of ParentAttendanceState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ParentAttendanceErrorCopyWith<ParentAttendanceError> get copyWith => _$ParentAttendanceErrorCopyWithImpl<ParentAttendanceError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ParentAttendanceError&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'ParentAttendanceState.error(message: $message)';
}


}

/// @nodoc
abstract mixin class $ParentAttendanceErrorCopyWith<$Res> implements $ParentAttendanceStateCopyWith<$Res> {
  factory $ParentAttendanceErrorCopyWith(ParentAttendanceError value, $Res Function(ParentAttendanceError) _then) = _$ParentAttendanceErrorCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class _$ParentAttendanceErrorCopyWithImpl<$Res>
    implements $ParentAttendanceErrorCopyWith<$Res> {
  _$ParentAttendanceErrorCopyWithImpl(this._self, this._then);

  final ParentAttendanceError _self;
  final $Res Function(ParentAttendanceError) _then;

/// Create a copy of ParentAttendanceState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(ParentAttendanceError(
null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class ParentAttendanceLoaded extends ParentAttendanceState {
  const ParentAttendanceLoaded({required this.child, required final  List<ChildAttendanceRecord> records, this.filter = ''}): _records = records,super._();
  

 final  Child child;
 final  List<ChildAttendanceRecord> _records;
 List<ChildAttendanceRecord> get records {
  if (_records is EqualUnmodifiableListView) return _records;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_records);
}

@JsonKey() final  String filter;

/// Create a copy of ParentAttendanceState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ParentAttendanceLoadedCopyWith<ParentAttendanceLoaded> get copyWith => _$ParentAttendanceLoadedCopyWithImpl<ParentAttendanceLoaded>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ParentAttendanceLoaded&&(identical(other.child, child) || other.child == child)&&const DeepCollectionEquality().equals(other._records, _records)&&(identical(other.filter, filter) || other.filter == filter));
}


@override
int get hashCode => Object.hash(runtimeType,child,const DeepCollectionEquality().hash(_records),filter);

@override
String toString() {
  return 'ParentAttendanceState.loaded(child: $child, records: $records, filter: $filter)';
}


}

/// @nodoc
abstract mixin class $ParentAttendanceLoadedCopyWith<$Res> implements $ParentAttendanceStateCopyWith<$Res> {
  factory $ParentAttendanceLoadedCopyWith(ParentAttendanceLoaded value, $Res Function(ParentAttendanceLoaded) _then) = _$ParentAttendanceLoadedCopyWithImpl;
@useResult
$Res call({
 Child child, List<ChildAttendanceRecord> records, String filter
});


$ChildCopyWith<$Res> get child;

}
/// @nodoc
class _$ParentAttendanceLoadedCopyWithImpl<$Res>
    implements $ParentAttendanceLoadedCopyWith<$Res> {
  _$ParentAttendanceLoadedCopyWithImpl(this._self, this._then);

  final ParentAttendanceLoaded _self;
  final $Res Function(ParentAttendanceLoaded) _then;

/// Create a copy of ParentAttendanceState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? child = null,Object? records = null,Object? filter = null,}) {
  return _then(ParentAttendanceLoaded(
child: null == child ? _self.child : child // ignore: cast_nullable_to_non_nullable
as Child,records: null == records ? _self._records : records // ignore: cast_nullable_to_non_nullable
as List<ChildAttendanceRecord>,filter: null == filter ? _self.filter : filter // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

/// Create a copy of ParentAttendanceState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ChildCopyWith<$Res> get child {
  
  return $ChildCopyWith<$Res>(_self.child, (value) {
    return _then(_self.copyWith(child: value));
  });
}
}

// dart format on
