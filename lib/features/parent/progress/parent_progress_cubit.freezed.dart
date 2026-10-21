// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'parent_progress_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ParentProgressState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ParentProgressState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ParentProgressState()';
}


}

/// @nodoc
class $ParentProgressStateCopyWith<$Res>  {
$ParentProgressStateCopyWith(ParentProgressState _, $Res Function(ParentProgressState) __);
}


/// Adds pattern-matching-related methods to [ParentProgressState].
extension ParentProgressStatePatterns on ParentProgressState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( ParentProgressInitial value)?  initial,TResult Function( ParentProgressLoading value)?  loading,TResult Function( ParentProgressError value)?  error,TResult Function( ParentProgressLoaded value)?  loaded,required TResult orElse(),}){
final _that = this;
switch (_that) {
case ParentProgressInitial() when initial != null:
return initial(_that);case ParentProgressLoading() when loading != null:
return loading(_that);case ParentProgressError() when error != null:
return error(_that);case ParentProgressLoaded() when loaded != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( ParentProgressInitial value)  initial,required TResult Function( ParentProgressLoading value)  loading,required TResult Function( ParentProgressError value)  error,required TResult Function( ParentProgressLoaded value)  loaded,}){
final _that = this;
switch (_that) {
case ParentProgressInitial():
return initial(_that);case ParentProgressLoading():
return loading(_that);case ParentProgressError():
return error(_that);case ParentProgressLoaded():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( ParentProgressInitial value)?  initial,TResult? Function( ParentProgressLoading value)?  loading,TResult? Function( ParentProgressError value)?  error,TResult? Function( ParentProgressLoaded value)?  loaded,}){
final _that = this;
switch (_that) {
case ParentProgressInitial() when initial != null:
return initial(_that);case ParentProgressLoading() when loading != null:
return loading(_that);case ParentProgressError() when error != null:
return error(_that);case ParentProgressLoaded() when loaded != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initial,TResult Function()?  loading,TResult Function( String message)?  error,TResult Function( Child child,  List<ChildAttendanceRecord> attendance,  List<ChildAssignment> assignments,  List<FeedbackEntry> feedback,  ProgressPeriod period,  bool partial)?  loaded,required TResult orElse(),}) {final _that = this;
switch (_that) {
case ParentProgressInitial() when initial != null:
return initial();case ParentProgressLoading() when loading != null:
return loading();case ParentProgressError() when error != null:
return error(_that.message);case ParentProgressLoaded() when loaded != null:
return loaded(_that.child,_that.attendance,_that.assignments,_that.feedback,_that.period,_that.partial);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initial,required TResult Function()  loading,required TResult Function( String message)  error,required TResult Function( Child child,  List<ChildAttendanceRecord> attendance,  List<ChildAssignment> assignments,  List<FeedbackEntry> feedback,  ProgressPeriod period,  bool partial)  loaded,}) {final _that = this;
switch (_that) {
case ParentProgressInitial():
return initial();case ParentProgressLoading():
return loading();case ParentProgressError():
return error(_that.message);case ParentProgressLoaded():
return loaded(_that.child,_that.attendance,_that.assignments,_that.feedback,_that.period,_that.partial);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initial,TResult? Function()?  loading,TResult? Function( String message)?  error,TResult? Function( Child child,  List<ChildAttendanceRecord> attendance,  List<ChildAssignment> assignments,  List<FeedbackEntry> feedback,  ProgressPeriod period,  bool partial)?  loaded,}) {final _that = this;
switch (_that) {
case ParentProgressInitial() when initial != null:
return initial();case ParentProgressLoading() when loading != null:
return loading();case ParentProgressError() when error != null:
return error(_that.message);case ParentProgressLoaded() when loaded != null:
return loaded(_that.child,_that.attendance,_that.assignments,_that.feedback,_that.period,_that.partial);case _:
  return null;

}
}

}

/// @nodoc


class ParentProgressInitial implements ParentProgressState {
  const ParentProgressInitial();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ParentProgressInitial);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ParentProgressState.initial()';
}


}




/// @nodoc


class ParentProgressLoading implements ParentProgressState {
  const ParentProgressLoading();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ParentProgressLoading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ParentProgressState.loading()';
}


}




/// @nodoc


class ParentProgressError implements ParentProgressState {
  const ParentProgressError(this.message);
  

 final  String message;

/// Create a copy of ParentProgressState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ParentProgressErrorCopyWith<ParentProgressError> get copyWith => _$ParentProgressErrorCopyWithImpl<ParentProgressError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ParentProgressError&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'ParentProgressState.error(message: $message)';
}


}

/// @nodoc
abstract mixin class $ParentProgressErrorCopyWith<$Res> implements $ParentProgressStateCopyWith<$Res> {
  factory $ParentProgressErrorCopyWith(ParentProgressError value, $Res Function(ParentProgressError) _then) = _$ParentProgressErrorCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class _$ParentProgressErrorCopyWithImpl<$Res>
    implements $ParentProgressErrorCopyWith<$Res> {
  _$ParentProgressErrorCopyWithImpl(this._self, this._then);

  final ParentProgressError _self;
  final $Res Function(ParentProgressError) _then;

/// Create a copy of ParentProgressState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(ParentProgressError(
null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class ParentProgressLoaded implements ParentProgressState {
  const ParentProgressLoaded({required this.child, required final  List<ChildAttendanceRecord> attendance, required final  List<ChildAssignment> assignments, required final  List<FeedbackEntry> feedback, this.period = ProgressPeriod.month, this.partial = false}): _attendance = attendance,_assignments = assignments,_feedback = feedback;
  

 final  Child child;
 final  List<ChildAttendanceRecord> _attendance;
 List<ChildAttendanceRecord> get attendance {
  if (_attendance is EqualUnmodifiableListView) return _attendance;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_attendance);
}

 final  List<ChildAssignment> _assignments;
 List<ChildAssignment> get assignments {
  if (_assignments is EqualUnmodifiableListView) return _assignments;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_assignments);
}

 final  List<FeedbackEntry> _feedback;
 List<FeedbackEntry> get feedback {
  if (_feedback is EqualUnmodifiableListView) return _feedback;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_feedback);
}

@JsonKey() final  ProgressPeriod period;
/// Some sources could not be loaded; what is shown may be incomplete.
@JsonKey() final  bool partial;

/// Create a copy of ParentProgressState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ParentProgressLoadedCopyWith<ParentProgressLoaded> get copyWith => _$ParentProgressLoadedCopyWithImpl<ParentProgressLoaded>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ParentProgressLoaded&&(identical(other.child, child) || other.child == child)&&const DeepCollectionEquality().equals(other._attendance, _attendance)&&const DeepCollectionEquality().equals(other._assignments, _assignments)&&const DeepCollectionEquality().equals(other._feedback, _feedback)&&(identical(other.period, period) || other.period == period)&&(identical(other.partial, partial) || other.partial == partial));
}


@override
int get hashCode => Object.hash(runtimeType,child,const DeepCollectionEquality().hash(_attendance),const DeepCollectionEquality().hash(_assignments),const DeepCollectionEquality().hash(_feedback),period,partial);

@override
String toString() {
  return 'ParentProgressState.loaded(child: $child, attendance: $attendance, assignments: $assignments, feedback: $feedback, period: $period, partial: $partial)';
}


}

/// @nodoc
abstract mixin class $ParentProgressLoadedCopyWith<$Res> implements $ParentProgressStateCopyWith<$Res> {
  factory $ParentProgressLoadedCopyWith(ParentProgressLoaded value, $Res Function(ParentProgressLoaded) _then) = _$ParentProgressLoadedCopyWithImpl;
@useResult
$Res call({
 Child child, List<ChildAttendanceRecord> attendance, List<ChildAssignment> assignments, List<FeedbackEntry> feedback, ProgressPeriod period, bool partial
});


$ChildCopyWith<$Res> get child;

}
/// @nodoc
class _$ParentProgressLoadedCopyWithImpl<$Res>
    implements $ParentProgressLoadedCopyWith<$Res> {
  _$ParentProgressLoadedCopyWithImpl(this._self, this._then);

  final ParentProgressLoaded _self;
  final $Res Function(ParentProgressLoaded) _then;

/// Create a copy of ParentProgressState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? child = null,Object? attendance = null,Object? assignments = null,Object? feedback = null,Object? period = null,Object? partial = null,}) {
  return _then(ParentProgressLoaded(
child: null == child ? _self.child : child // ignore: cast_nullable_to_non_nullable
as Child,attendance: null == attendance ? _self._attendance : attendance // ignore: cast_nullable_to_non_nullable
as List<ChildAttendanceRecord>,assignments: null == assignments ? _self._assignments : assignments // ignore: cast_nullable_to_non_nullable
as List<ChildAssignment>,feedback: null == feedback ? _self._feedback : feedback // ignore: cast_nullable_to_non_nullable
as List<FeedbackEntry>,period: null == period ? _self.period : period // ignore: cast_nullable_to_non_nullable
as ProgressPeriod,partial: null == partial ? _self.partial : partial // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of ParentProgressState
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
