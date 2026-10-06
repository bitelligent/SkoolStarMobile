// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'schedule_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ScheduleState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ScheduleState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ScheduleState()';
}


}

/// @nodoc
class $ScheduleStateCopyWith<$Res>  {
$ScheduleStateCopyWith(ScheduleState _, $Res Function(ScheduleState) __);
}


/// Adds pattern-matching-related methods to [ScheduleState].
extension ScheduleStatePatterns on ScheduleState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( ScheduleInitial value)?  initial,TResult Function( ScheduleLoading value)?  loading,TResult Function( ScheduleLoaded value)?  loaded,TResult Function( ScheduleError value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case ScheduleInitial() when initial != null:
return initial(_that);case ScheduleLoading() when loading != null:
return loading(_that);case ScheduleLoaded() when loaded != null:
return loaded(_that);case ScheduleError() when error != null:
return error(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( ScheduleInitial value)  initial,required TResult Function( ScheduleLoading value)  loading,required TResult Function( ScheduleLoaded value)  loaded,required TResult Function( ScheduleError value)  error,}){
final _that = this;
switch (_that) {
case ScheduleInitial():
return initial(_that);case ScheduleLoading():
return loading(_that);case ScheduleLoaded():
return loaded(_that);case ScheduleError():
return error(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( ScheduleInitial value)?  initial,TResult? Function( ScheduleLoading value)?  loading,TResult? Function( ScheduleLoaded value)?  loaded,TResult? Function( ScheduleError value)?  error,}){
final _that = this;
switch (_that) {
case ScheduleInitial() when initial != null:
return initial(_that);case ScheduleLoading() when loading != null:
return loading(_that);case ScheduleLoaded() when loaded != null:
return loaded(_that);case ScheduleError() when error != null:
return error(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initial,TResult Function()?  loading,TResult Function( List<Session> sessions,  List<ClassGroup> classes,  List<Subject> subjects,  DateTime? dateFilter,  Set<String> classFilterIds,  Set<String> subjectFilterIds)?  loaded,TResult Function( String message)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case ScheduleInitial() when initial != null:
return initial();case ScheduleLoading() when loading != null:
return loading();case ScheduleLoaded() when loaded != null:
return loaded(_that.sessions,_that.classes,_that.subjects,_that.dateFilter,_that.classFilterIds,_that.subjectFilterIds);case ScheduleError() when error != null:
return error(_that.message);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initial,required TResult Function()  loading,required TResult Function( List<Session> sessions,  List<ClassGroup> classes,  List<Subject> subjects,  DateTime? dateFilter,  Set<String> classFilterIds,  Set<String> subjectFilterIds)  loaded,required TResult Function( String message)  error,}) {final _that = this;
switch (_that) {
case ScheduleInitial():
return initial();case ScheduleLoading():
return loading();case ScheduleLoaded():
return loaded(_that.sessions,_that.classes,_that.subjects,_that.dateFilter,_that.classFilterIds,_that.subjectFilterIds);case ScheduleError():
return error(_that.message);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initial,TResult? Function()?  loading,TResult? Function( List<Session> sessions,  List<ClassGroup> classes,  List<Subject> subjects,  DateTime? dateFilter,  Set<String> classFilterIds,  Set<String> subjectFilterIds)?  loaded,TResult? Function( String message)?  error,}) {final _that = this;
switch (_that) {
case ScheduleInitial() when initial != null:
return initial();case ScheduleLoading() when loading != null:
return loading();case ScheduleLoaded() when loaded != null:
return loaded(_that.sessions,_that.classes,_that.subjects,_that.dateFilter,_that.classFilterIds,_that.subjectFilterIds);case ScheduleError() when error != null:
return error(_that.message);case _:
  return null;

}
}

}

/// @nodoc


class ScheduleInitial implements ScheduleState {
  const ScheduleInitial();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ScheduleInitial);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ScheduleState.initial()';
}


}




/// @nodoc


class ScheduleLoading implements ScheduleState {
  const ScheduleLoading();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ScheduleLoading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ScheduleState.loading()';
}


}




/// @nodoc


class ScheduleLoaded implements ScheduleState {
  const ScheduleLoaded({required final  List<Session> sessions, required final  List<ClassGroup> classes, required final  List<Subject> subjects, this.dateFilter, final  Set<String> classFilterIds = const <String>{}, final  Set<String> subjectFilterIds = const <String>{}}): _sessions = sessions,_classes = classes,_subjects = subjects,_classFilterIds = classFilterIds,_subjectFilterIds = subjectFilterIds;
  

 final  List<Session> _sessions;
 List<Session> get sessions {
  if (_sessions is EqualUnmodifiableListView) return _sessions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_sessions);
}

 final  List<ClassGroup> _classes;
 List<ClassGroup> get classes {
  if (_classes is EqualUnmodifiableListView) return _classes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_classes);
}

 final  List<Subject> _subjects;
 List<Subject> get subjects {
  if (_subjects is EqualUnmodifiableListView) return _subjects;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_subjects);
}

 final  DateTime? dateFilter;
 final  Set<String> _classFilterIds;
@JsonKey() Set<String> get classFilterIds {
  if (_classFilterIds is EqualUnmodifiableSetView) return _classFilterIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_classFilterIds);
}

 final  Set<String> _subjectFilterIds;
@JsonKey() Set<String> get subjectFilterIds {
  if (_subjectFilterIds is EqualUnmodifiableSetView) return _subjectFilterIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_subjectFilterIds);
}


/// Create a copy of ScheduleState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ScheduleLoadedCopyWith<ScheduleLoaded> get copyWith => _$ScheduleLoadedCopyWithImpl<ScheduleLoaded>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ScheduleLoaded&&const DeepCollectionEquality().equals(other._sessions, _sessions)&&const DeepCollectionEquality().equals(other._classes, _classes)&&const DeepCollectionEquality().equals(other._subjects, _subjects)&&(identical(other.dateFilter, dateFilter) || other.dateFilter == dateFilter)&&const DeepCollectionEquality().equals(other._classFilterIds, _classFilterIds)&&const DeepCollectionEquality().equals(other._subjectFilterIds, _subjectFilterIds));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_sessions),const DeepCollectionEquality().hash(_classes),const DeepCollectionEquality().hash(_subjects),dateFilter,const DeepCollectionEquality().hash(_classFilterIds),const DeepCollectionEquality().hash(_subjectFilterIds));

@override
String toString() {
  return 'ScheduleState.loaded(sessions: $sessions, classes: $classes, subjects: $subjects, dateFilter: $dateFilter, classFilterIds: $classFilterIds, subjectFilterIds: $subjectFilterIds)';
}


}

/// @nodoc
abstract mixin class $ScheduleLoadedCopyWith<$Res> implements $ScheduleStateCopyWith<$Res> {
  factory $ScheduleLoadedCopyWith(ScheduleLoaded value, $Res Function(ScheduleLoaded) _then) = _$ScheduleLoadedCopyWithImpl;
@useResult
$Res call({
 List<Session> sessions, List<ClassGroup> classes, List<Subject> subjects, DateTime? dateFilter, Set<String> classFilterIds, Set<String> subjectFilterIds
});




}
/// @nodoc
class _$ScheduleLoadedCopyWithImpl<$Res>
    implements $ScheduleLoadedCopyWith<$Res> {
  _$ScheduleLoadedCopyWithImpl(this._self, this._then);

  final ScheduleLoaded _self;
  final $Res Function(ScheduleLoaded) _then;

/// Create a copy of ScheduleState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? sessions = null,Object? classes = null,Object? subjects = null,Object? dateFilter = freezed,Object? classFilterIds = null,Object? subjectFilterIds = null,}) {
  return _then(ScheduleLoaded(
sessions: null == sessions ? _self._sessions : sessions // ignore: cast_nullable_to_non_nullable
as List<Session>,classes: null == classes ? _self._classes : classes // ignore: cast_nullable_to_non_nullable
as List<ClassGroup>,subjects: null == subjects ? _self._subjects : subjects // ignore: cast_nullable_to_non_nullable
as List<Subject>,dateFilter: freezed == dateFilter ? _self.dateFilter : dateFilter // ignore: cast_nullable_to_non_nullable
as DateTime?,classFilterIds: null == classFilterIds ? _self._classFilterIds : classFilterIds // ignore: cast_nullable_to_non_nullable
as Set<String>,subjectFilterIds: null == subjectFilterIds ? _self._subjectFilterIds : subjectFilterIds // ignore: cast_nullable_to_non_nullable
as Set<String>,
  ));
}


}

/// @nodoc


class ScheduleError implements ScheduleState {
  const ScheduleError(this.message);
  

 final  String message;

/// Create a copy of ScheduleState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ScheduleErrorCopyWith<ScheduleError> get copyWith => _$ScheduleErrorCopyWithImpl<ScheduleError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ScheduleError&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'ScheduleState.error(message: $message)';
}


}

/// @nodoc
abstract mixin class $ScheduleErrorCopyWith<$Res> implements $ScheduleStateCopyWith<$Res> {
  factory $ScheduleErrorCopyWith(ScheduleError value, $Res Function(ScheduleError) _then) = _$ScheduleErrorCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class _$ScheduleErrorCopyWithImpl<$Res>
    implements $ScheduleErrorCopyWith<$Res> {
  _$ScheduleErrorCopyWithImpl(this._self, this._then);

  final ScheduleError _self;
  final $Res Function(ScheduleError) _then;

/// Create a copy of ScheduleState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(ScheduleError(
null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
