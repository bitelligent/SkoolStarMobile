// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'parent_home_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ParentHomeState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ParentHomeState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ParentHomeState()';
}


}

/// @nodoc
class $ParentHomeStateCopyWith<$Res>  {
$ParentHomeStateCopyWith(ParentHomeState _, $Res Function(ParentHomeState) __);
}


/// Adds pattern-matching-related methods to [ParentHomeState].
extension ParentHomeStatePatterns on ParentHomeState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( ParentHomeInitial value)?  initial,TResult Function( ParentHomeLoading value)?  loading,TResult Function( ParentHomeError value)?  error,TResult Function( ParentHomeLoaded value)?  loaded,required TResult orElse(),}){
final _that = this;
switch (_that) {
case ParentHomeInitial() when initial != null:
return initial(_that);case ParentHomeLoading() when loading != null:
return loading(_that);case ParentHomeError() when error != null:
return error(_that);case ParentHomeLoaded() when loaded != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( ParentHomeInitial value)  initial,required TResult Function( ParentHomeLoading value)  loading,required TResult Function( ParentHomeError value)  error,required TResult Function( ParentHomeLoaded value)  loaded,}){
final _that = this;
switch (_that) {
case ParentHomeInitial():
return initial(_that);case ParentHomeLoading():
return loading(_that);case ParentHomeError():
return error(_that);case ParentHomeLoaded():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( ParentHomeInitial value)?  initial,TResult? Function( ParentHomeLoading value)?  loading,TResult? Function( ParentHomeError value)?  error,TResult? Function( ParentHomeLoaded value)?  loaded,}){
final _that = this;
switch (_that) {
case ParentHomeInitial() when initial != null:
return initial(_that);case ParentHomeLoading() when loading != null:
return loading(_that);case ParentHomeError() when error != null:
return error(_that);case ParentHomeLoaded() when loaded != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initial,TResult Function()?  loading,TResult Function( String message)?  error,TResult Function( Child child,  List<Session> sessions,  List<Subject> subjects,  List<ClassGroup> classes,  DateTime focusDate,  int? pendingAssignments,  int? presentCount,  int? attendanceTotal,  DateTime? selectedDate,  String query,  String dayFilter,  Set<String> subjectFilterIds,  Set<String> teacherFilterIds,  ParentHomeView view)?  loaded,required TResult orElse(),}) {final _that = this;
switch (_that) {
case ParentHomeInitial() when initial != null:
return initial();case ParentHomeLoading() when loading != null:
return loading();case ParentHomeError() when error != null:
return error(_that.message);case ParentHomeLoaded() when loaded != null:
return loaded(_that.child,_that.sessions,_that.subjects,_that.classes,_that.focusDate,_that.pendingAssignments,_that.presentCount,_that.attendanceTotal,_that.selectedDate,_that.query,_that.dayFilter,_that.subjectFilterIds,_that.teacherFilterIds,_that.view);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initial,required TResult Function()  loading,required TResult Function( String message)  error,required TResult Function( Child child,  List<Session> sessions,  List<Subject> subjects,  List<ClassGroup> classes,  DateTime focusDate,  int? pendingAssignments,  int? presentCount,  int? attendanceTotal,  DateTime? selectedDate,  String query,  String dayFilter,  Set<String> subjectFilterIds,  Set<String> teacherFilterIds,  ParentHomeView view)  loaded,}) {final _that = this;
switch (_that) {
case ParentHomeInitial():
return initial();case ParentHomeLoading():
return loading();case ParentHomeError():
return error(_that.message);case ParentHomeLoaded():
return loaded(_that.child,_that.sessions,_that.subjects,_that.classes,_that.focusDate,_that.pendingAssignments,_that.presentCount,_that.attendanceTotal,_that.selectedDate,_that.query,_that.dayFilter,_that.subjectFilterIds,_that.teacherFilterIds,_that.view);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initial,TResult? Function()?  loading,TResult? Function( String message)?  error,TResult? Function( Child child,  List<Session> sessions,  List<Subject> subjects,  List<ClassGroup> classes,  DateTime focusDate,  int? pendingAssignments,  int? presentCount,  int? attendanceTotal,  DateTime? selectedDate,  String query,  String dayFilter,  Set<String> subjectFilterIds,  Set<String> teacherFilterIds,  ParentHomeView view)?  loaded,}) {final _that = this;
switch (_that) {
case ParentHomeInitial() when initial != null:
return initial();case ParentHomeLoading() when loading != null:
return loading();case ParentHomeError() when error != null:
return error(_that.message);case ParentHomeLoaded() when loaded != null:
return loaded(_that.child,_that.sessions,_that.subjects,_that.classes,_that.focusDate,_that.pendingAssignments,_that.presentCount,_that.attendanceTotal,_that.selectedDate,_that.query,_that.dayFilter,_that.subjectFilterIds,_that.teacherFilterIds,_that.view);case _:
  return null;

}
}

}

/// @nodoc


class ParentHomeInitial implements ParentHomeState {
  const ParentHomeInitial();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ParentHomeInitial);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ParentHomeState.initial()';
}


}




/// @nodoc


class ParentHomeLoading implements ParentHomeState {
  const ParentHomeLoading();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ParentHomeLoading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ParentHomeState.loading()';
}


}




/// @nodoc


class ParentHomeError implements ParentHomeState {
  const ParentHomeError(this.message);
  

 final  String message;

/// Create a copy of ParentHomeState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ParentHomeErrorCopyWith<ParentHomeError> get copyWith => _$ParentHomeErrorCopyWithImpl<ParentHomeError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ParentHomeError&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'ParentHomeState.error(message: $message)';
}


}

/// @nodoc
abstract mixin class $ParentHomeErrorCopyWith<$Res> implements $ParentHomeStateCopyWith<$Res> {
  factory $ParentHomeErrorCopyWith(ParentHomeError value, $Res Function(ParentHomeError) _then) = _$ParentHomeErrorCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class _$ParentHomeErrorCopyWithImpl<$Res>
    implements $ParentHomeErrorCopyWith<$Res> {
  _$ParentHomeErrorCopyWithImpl(this._self, this._then);

  final ParentHomeError _self;
  final $Res Function(ParentHomeError) _then;

/// Create a copy of ParentHomeState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(ParentHomeError(
null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class ParentHomeLoaded implements ParentHomeState {
  const ParentHomeLoaded({required this.child, required final  List<Session> sessions, required final  List<Subject> subjects, required final  List<ClassGroup> classes, required this.focusDate, this.pendingAssignments, this.presentCount, this.attendanceTotal, this.selectedDate, this.query = '', this.dayFilter = defaultDayFilter, final  Set<String> subjectFilterIds = const <String>{}, final  Set<String> teacherFilterIds = const <String>{}, this.view = ParentHomeView.agenda}): _sessions = sessions,_subjects = subjects,_classes = classes,_subjectFilterIds = subjectFilterIds,_teacherFilterIds = teacherFilterIds;
  

 final  Child child;
 final  List<Session> _sessions;
 List<Session> get sessions {
  if (_sessions is EqualUnmodifiableListView) return _sessions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_sessions);
}

 final  List<Subject> _subjects;
 List<Subject> get subjects {
  if (_subjects is EqualUnmodifiableListView) return _subjects;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_subjects);
}

 final  List<ClassGroup> _classes;
 List<ClassGroup> get classes {
  if (_classes is EqualUnmodifiableListView) return _classes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_classes);
}

 final  DateTime focusDate;
/// Assignments not completed / attendance counts for the stat tiles.
/// `null` when that part failed to load (the tile is hidden).
 final  int? pendingAssignments;
 final  int? presentCount;
 final  int? attendanceTotal;
 final  DateTime? selectedDate;
@JsonKey() final  String query;
@JsonKey() final  String dayFilter;
 final  Set<String> _subjectFilterIds;
@JsonKey() Set<String> get subjectFilterIds {
  if (_subjectFilterIds is EqualUnmodifiableSetView) return _subjectFilterIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_subjectFilterIds);
}

 final  Set<String> _teacherFilterIds;
@JsonKey() Set<String> get teacherFilterIds {
  if (_teacherFilterIds is EqualUnmodifiableSetView) return _teacherFilterIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_teacherFilterIds);
}

@JsonKey() final  ParentHomeView view;

/// Create a copy of ParentHomeState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ParentHomeLoadedCopyWith<ParentHomeLoaded> get copyWith => _$ParentHomeLoadedCopyWithImpl<ParentHomeLoaded>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ParentHomeLoaded&&(identical(other.child, child) || other.child == child)&&const DeepCollectionEquality().equals(other._sessions, _sessions)&&const DeepCollectionEquality().equals(other._subjects, _subjects)&&const DeepCollectionEquality().equals(other._classes, _classes)&&(identical(other.focusDate, focusDate) || other.focusDate == focusDate)&&(identical(other.pendingAssignments, pendingAssignments) || other.pendingAssignments == pendingAssignments)&&(identical(other.presentCount, presentCount) || other.presentCount == presentCount)&&(identical(other.attendanceTotal, attendanceTotal) || other.attendanceTotal == attendanceTotal)&&(identical(other.selectedDate, selectedDate) || other.selectedDate == selectedDate)&&(identical(other.query, query) || other.query == query)&&(identical(other.dayFilter, dayFilter) || other.dayFilter == dayFilter)&&const DeepCollectionEquality().equals(other._subjectFilterIds, _subjectFilterIds)&&const DeepCollectionEquality().equals(other._teacherFilterIds, _teacherFilterIds)&&(identical(other.view, view) || other.view == view));
}


@override
int get hashCode => Object.hash(runtimeType,child,const DeepCollectionEquality().hash(_sessions),const DeepCollectionEquality().hash(_subjects),const DeepCollectionEquality().hash(_classes),focusDate,pendingAssignments,presentCount,attendanceTotal,selectedDate,query,dayFilter,const DeepCollectionEquality().hash(_subjectFilterIds),const DeepCollectionEquality().hash(_teacherFilterIds),view);

@override
String toString() {
  return 'ParentHomeState.loaded(child: $child, sessions: $sessions, subjects: $subjects, classes: $classes, focusDate: $focusDate, pendingAssignments: $pendingAssignments, presentCount: $presentCount, attendanceTotal: $attendanceTotal, selectedDate: $selectedDate, query: $query, dayFilter: $dayFilter, subjectFilterIds: $subjectFilterIds, teacherFilterIds: $teacherFilterIds, view: $view)';
}


}

/// @nodoc
abstract mixin class $ParentHomeLoadedCopyWith<$Res> implements $ParentHomeStateCopyWith<$Res> {
  factory $ParentHomeLoadedCopyWith(ParentHomeLoaded value, $Res Function(ParentHomeLoaded) _then) = _$ParentHomeLoadedCopyWithImpl;
@useResult
$Res call({
 Child child, List<Session> sessions, List<Subject> subjects, List<ClassGroup> classes, DateTime focusDate, int? pendingAssignments, int? presentCount, int? attendanceTotal, DateTime? selectedDate, String query, String dayFilter, Set<String> subjectFilterIds, Set<String> teacherFilterIds, ParentHomeView view
});


$ChildCopyWith<$Res> get child;

}
/// @nodoc
class _$ParentHomeLoadedCopyWithImpl<$Res>
    implements $ParentHomeLoadedCopyWith<$Res> {
  _$ParentHomeLoadedCopyWithImpl(this._self, this._then);

  final ParentHomeLoaded _self;
  final $Res Function(ParentHomeLoaded) _then;

/// Create a copy of ParentHomeState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? child = null,Object? sessions = null,Object? subjects = null,Object? classes = null,Object? focusDate = null,Object? pendingAssignments = freezed,Object? presentCount = freezed,Object? attendanceTotal = freezed,Object? selectedDate = freezed,Object? query = null,Object? dayFilter = null,Object? subjectFilterIds = null,Object? teacherFilterIds = null,Object? view = null,}) {
  return _then(ParentHomeLoaded(
child: null == child ? _self.child : child // ignore: cast_nullable_to_non_nullable
as Child,sessions: null == sessions ? _self._sessions : sessions // ignore: cast_nullable_to_non_nullable
as List<Session>,subjects: null == subjects ? _self._subjects : subjects // ignore: cast_nullable_to_non_nullable
as List<Subject>,classes: null == classes ? _self._classes : classes // ignore: cast_nullable_to_non_nullable
as List<ClassGroup>,focusDate: null == focusDate ? _self.focusDate : focusDate // ignore: cast_nullable_to_non_nullable
as DateTime,pendingAssignments: freezed == pendingAssignments ? _self.pendingAssignments : pendingAssignments // ignore: cast_nullable_to_non_nullable
as int?,presentCount: freezed == presentCount ? _self.presentCount : presentCount // ignore: cast_nullable_to_non_nullable
as int?,attendanceTotal: freezed == attendanceTotal ? _self.attendanceTotal : attendanceTotal // ignore: cast_nullable_to_non_nullable
as int?,selectedDate: freezed == selectedDate ? _self.selectedDate : selectedDate // ignore: cast_nullable_to_non_nullable
as DateTime?,query: null == query ? _self.query : query // ignore: cast_nullable_to_non_nullable
as String,dayFilter: null == dayFilter ? _self.dayFilter : dayFilter // ignore: cast_nullable_to_non_nullable
as String,subjectFilterIds: null == subjectFilterIds ? _self._subjectFilterIds : subjectFilterIds // ignore: cast_nullable_to_non_nullable
as Set<String>,teacherFilterIds: null == teacherFilterIds ? _self._teacherFilterIds : teacherFilterIds // ignore: cast_nullable_to_non_nullable
as Set<String>,view: null == view ? _self.view : view // ignore: cast_nullable_to_non_nullable
as ParentHomeView,
  ));
}

/// Create a copy of ParentHomeState
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
