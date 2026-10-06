// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'dashboard_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$DashboardState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DashboardState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'DashboardState()';
}


}

/// @nodoc
class $DashboardStateCopyWith<$Res>  {
$DashboardStateCopyWith(DashboardState _, $Res Function(DashboardState) __);
}


/// Adds pattern-matching-related methods to [DashboardState].
extension DashboardStatePatterns on DashboardState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( DashboardInitial value)?  initial,TResult Function( DashboardLoading value)?  loading,TResult Function( DashboardLoaded value)?  loaded,TResult Function( DashboardError value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case DashboardInitial() when initial != null:
return initial(_that);case DashboardLoading() when loading != null:
return loading(_that);case DashboardLoaded() when loaded != null:
return loaded(_that);case DashboardError() when error != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( DashboardInitial value)  initial,required TResult Function( DashboardLoading value)  loading,required TResult Function( DashboardLoaded value)  loaded,required TResult Function( DashboardError value)  error,}){
final _that = this;
switch (_that) {
case DashboardInitial():
return initial(_that);case DashboardLoading():
return loading(_that);case DashboardLoaded():
return loaded(_that);case DashboardError():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( DashboardInitial value)?  initial,TResult? Function( DashboardLoading value)?  loading,TResult? Function( DashboardLoaded value)?  loaded,TResult? Function( DashboardError value)?  error,}){
final _that = this;
switch (_that) {
case DashboardInitial() when initial != null:
return initial(_that);case DashboardLoading() when loading != null:
return loading(_that);case DashboardLoaded() when loaded != null:
return loaded(_that);case DashboardError() when error != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initial,TResult Function()?  loading,TResult Function( InstituteInfo institute,  UserModel user,  Session? liveSession,  List<Session> sessions,  List<ClassGroup> classes,  List<Subject> subjects,  DateTime focusDate,  DateTime? selectedDate,  String query,  String dayFilter,  Set<String> classFilterIds,  Set<String> subjectFilterIds,  DashboardView view)?  loaded,TResult Function( String message)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case DashboardInitial() when initial != null:
return initial();case DashboardLoading() when loading != null:
return loading();case DashboardLoaded() when loaded != null:
return loaded(_that.institute,_that.user,_that.liveSession,_that.sessions,_that.classes,_that.subjects,_that.focusDate,_that.selectedDate,_that.query,_that.dayFilter,_that.classFilterIds,_that.subjectFilterIds,_that.view);case DashboardError() when error != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initial,required TResult Function()  loading,required TResult Function( InstituteInfo institute,  UserModel user,  Session? liveSession,  List<Session> sessions,  List<ClassGroup> classes,  List<Subject> subjects,  DateTime focusDate,  DateTime? selectedDate,  String query,  String dayFilter,  Set<String> classFilterIds,  Set<String> subjectFilterIds,  DashboardView view)  loaded,required TResult Function( String message)  error,}) {final _that = this;
switch (_that) {
case DashboardInitial():
return initial();case DashboardLoading():
return loading();case DashboardLoaded():
return loaded(_that.institute,_that.user,_that.liveSession,_that.sessions,_that.classes,_that.subjects,_that.focusDate,_that.selectedDate,_that.query,_that.dayFilter,_that.classFilterIds,_that.subjectFilterIds,_that.view);case DashboardError():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initial,TResult? Function()?  loading,TResult? Function( InstituteInfo institute,  UserModel user,  Session? liveSession,  List<Session> sessions,  List<ClassGroup> classes,  List<Subject> subjects,  DateTime focusDate,  DateTime? selectedDate,  String query,  String dayFilter,  Set<String> classFilterIds,  Set<String> subjectFilterIds,  DashboardView view)?  loaded,TResult? Function( String message)?  error,}) {final _that = this;
switch (_that) {
case DashboardInitial() when initial != null:
return initial();case DashboardLoading() when loading != null:
return loading();case DashboardLoaded() when loaded != null:
return loaded(_that.institute,_that.user,_that.liveSession,_that.sessions,_that.classes,_that.subjects,_that.focusDate,_that.selectedDate,_that.query,_that.dayFilter,_that.classFilterIds,_that.subjectFilterIds,_that.view);case DashboardError() when error != null:
return error(_that.message);case _:
  return null;

}
}

}

/// @nodoc


class DashboardInitial implements DashboardState {
  const DashboardInitial();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DashboardInitial);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'DashboardState.initial()';
}


}




/// @nodoc


class DashboardLoading implements DashboardState {
  const DashboardLoading();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DashboardLoading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'DashboardState.loading()';
}


}




/// @nodoc


class DashboardLoaded implements DashboardState {
  const DashboardLoaded({required this.institute, required this.user, required this.liveSession, required final  List<Session> sessions, required final  List<ClassGroup> classes, required final  List<Subject> subjects, required this.focusDate, this.selectedDate, this.query = '', this.dayFilter = '', final  Set<String> classFilterIds = const <String>{}, final  Set<String> subjectFilterIds = const <String>{}, this.view = DashboardView.month}): _sessions = sessions,_classes = classes,_subjects = subjects,_classFilterIds = classFilterIds,_subjectFilterIds = subjectFilterIds;
  

 final  InstituteInfo institute;
 final  UserModel user;
 final  Session? liveSession;
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

 final  DateTime focusDate;
 final  DateTime? selectedDate;
@JsonKey() final  String query;
@JsonKey() final  String dayFilter;
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

@JsonKey() final  DashboardView view;

/// Create a copy of DashboardState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DashboardLoadedCopyWith<DashboardLoaded> get copyWith => _$DashboardLoadedCopyWithImpl<DashboardLoaded>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DashboardLoaded&&(identical(other.institute, institute) || other.institute == institute)&&(identical(other.user, user) || other.user == user)&&(identical(other.liveSession, liveSession) || other.liveSession == liveSession)&&const DeepCollectionEquality().equals(other._sessions, _sessions)&&const DeepCollectionEquality().equals(other._classes, _classes)&&const DeepCollectionEquality().equals(other._subjects, _subjects)&&(identical(other.focusDate, focusDate) || other.focusDate == focusDate)&&(identical(other.selectedDate, selectedDate) || other.selectedDate == selectedDate)&&(identical(other.query, query) || other.query == query)&&(identical(other.dayFilter, dayFilter) || other.dayFilter == dayFilter)&&const DeepCollectionEquality().equals(other._classFilterIds, _classFilterIds)&&const DeepCollectionEquality().equals(other._subjectFilterIds, _subjectFilterIds)&&(identical(other.view, view) || other.view == view));
}


@override
int get hashCode => Object.hash(runtimeType,institute,user,liveSession,const DeepCollectionEquality().hash(_sessions),const DeepCollectionEquality().hash(_classes),const DeepCollectionEquality().hash(_subjects),focusDate,selectedDate,query,dayFilter,const DeepCollectionEquality().hash(_classFilterIds),const DeepCollectionEquality().hash(_subjectFilterIds),view);

@override
String toString() {
  return 'DashboardState.loaded(institute: $institute, user: $user, liveSession: $liveSession, sessions: $sessions, classes: $classes, subjects: $subjects, focusDate: $focusDate, selectedDate: $selectedDate, query: $query, dayFilter: $dayFilter, classFilterIds: $classFilterIds, subjectFilterIds: $subjectFilterIds, view: $view)';
}


}

/// @nodoc
abstract mixin class $DashboardLoadedCopyWith<$Res> implements $DashboardStateCopyWith<$Res> {
  factory $DashboardLoadedCopyWith(DashboardLoaded value, $Res Function(DashboardLoaded) _then) = _$DashboardLoadedCopyWithImpl;
@useResult
$Res call({
 InstituteInfo institute, UserModel user, Session? liveSession, List<Session> sessions, List<ClassGroup> classes, List<Subject> subjects, DateTime focusDate, DateTime? selectedDate, String query, String dayFilter, Set<String> classFilterIds, Set<String> subjectFilterIds, DashboardView view
});


$InstituteInfoCopyWith<$Res> get institute;$UserModelCopyWith<$Res> get user;$SessionCopyWith<$Res>? get liveSession;

}
/// @nodoc
class _$DashboardLoadedCopyWithImpl<$Res>
    implements $DashboardLoadedCopyWith<$Res> {
  _$DashboardLoadedCopyWithImpl(this._self, this._then);

  final DashboardLoaded _self;
  final $Res Function(DashboardLoaded) _then;

/// Create a copy of DashboardState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? institute = null,Object? user = null,Object? liveSession = freezed,Object? sessions = null,Object? classes = null,Object? subjects = null,Object? focusDate = null,Object? selectedDate = freezed,Object? query = null,Object? dayFilter = null,Object? classFilterIds = null,Object? subjectFilterIds = null,Object? view = null,}) {
  return _then(DashboardLoaded(
institute: null == institute ? _self.institute : institute // ignore: cast_nullable_to_non_nullable
as InstituteInfo,user: null == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as UserModel,liveSession: freezed == liveSession ? _self.liveSession : liveSession // ignore: cast_nullable_to_non_nullable
as Session?,sessions: null == sessions ? _self._sessions : sessions // ignore: cast_nullable_to_non_nullable
as List<Session>,classes: null == classes ? _self._classes : classes // ignore: cast_nullable_to_non_nullable
as List<ClassGroup>,subjects: null == subjects ? _self._subjects : subjects // ignore: cast_nullable_to_non_nullable
as List<Subject>,focusDate: null == focusDate ? _self.focusDate : focusDate // ignore: cast_nullable_to_non_nullable
as DateTime,selectedDate: freezed == selectedDate ? _self.selectedDate : selectedDate // ignore: cast_nullable_to_non_nullable
as DateTime?,query: null == query ? _self.query : query // ignore: cast_nullable_to_non_nullable
as String,dayFilter: null == dayFilter ? _self.dayFilter : dayFilter // ignore: cast_nullable_to_non_nullable
as String,classFilterIds: null == classFilterIds ? _self._classFilterIds : classFilterIds // ignore: cast_nullable_to_non_nullable
as Set<String>,subjectFilterIds: null == subjectFilterIds ? _self._subjectFilterIds : subjectFilterIds // ignore: cast_nullable_to_non_nullable
as Set<String>,view: null == view ? _self.view : view // ignore: cast_nullable_to_non_nullable
as DashboardView,
  ));
}

/// Create a copy of DashboardState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$InstituteInfoCopyWith<$Res> get institute {
  
  return $InstituteInfoCopyWith<$Res>(_self.institute, (value) {
    return _then(_self.copyWith(institute: value));
  });
}/// Create a copy of DashboardState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserModelCopyWith<$Res> get user {
  
  return $UserModelCopyWith<$Res>(_self.user, (value) {
    return _then(_self.copyWith(user: value));
  });
}/// Create a copy of DashboardState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SessionCopyWith<$Res>? get liveSession {
    if (_self.liveSession == null) {
    return null;
  }

  return $SessionCopyWith<$Res>(_self.liveSession!, (value) {
    return _then(_self.copyWith(liveSession: value));
  });
}
}

/// @nodoc


class DashboardError implements DashboardState {
  const DashboardError(this.message);
  

 final  String message;

/// Create a copy of DashboardState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DashboardErrorCopyWith<DashboardError> get copyWith => _$DashboardErrorCopyWithImpl<DashboardError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DashboardError&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'DashboardState.error(message: $message)';
}


}

/// @nodoc
abstract mixin class $DashboardErrorCopyWith<$Res> implements $DashboardStateCopyWith<$Res> {
  factory $DashboardErrorCopyWith(DashboardError value, $Res Function(DashboardError) _then) = _$DashboardErrorCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class _$DashboardErrorCopyWithImpl<$Res>
    implements $DashboardErrorCopyWith<$Res> {
  _$DashboardErrorCopyWithImpl(this._self, this._then);

  final DashboardError _self;
  final $Res Function(DashboardError) _then;

/// Create a copy of DashboardState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(DashboardError(
null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
