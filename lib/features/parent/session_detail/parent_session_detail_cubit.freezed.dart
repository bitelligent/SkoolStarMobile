// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'parent_session_detail_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ParentSessionDetailState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ParentSessionDetailState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ParentSessionDetailState()';
}


}

/// @nodoc
class $ParentSessionDetailStateCopyWith<$Res>  {
$ParentSessionDetailStateCopyWith(ParentSessionDetailState _, $Res Function(ParentSessionDetailState) __);
}


/// Adds pattern-matching-related methods to [ParentSessionDetailState].
extension ParentSessionDetailStatePatterns on ParentSessionDetailState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( ParentSessionLoading value)?  loading,TResult Function( ParentSessionNotFound value)?  notFound,TResult Function( ParentSessionError value)?  error,TResult Function( ParentSessionLoaded value)?  loaded,required TResult orElse(),}){
final _that = this;
switch (_that) {
case ParentSessionLoading() when loading != null:
return loading(_that);case ParentSessionNotFound() when notFound != null:
return notFound(_that);case ParentSessionError() when error != null:
return error(_that);case ParentSessionLoaded() when loaded != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( ParentSessionLoading value)  loading,required TResult Function( ParentSessionNotFound value)  notFound,required TResult Function( ParentSessionError value)  error,required TResult Function( ParentSessionLoaded value)  loaded,}){
final _that = this;
switch (_that) {
case ParentSessionLoading():
return loading(_that);case ParentSessionNotFound():
return notFound(_that);case ParentSessionError():
return error(_that);case ParentSessionLoaded():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( ParentSessionLoading value)?  loading,TResult? Function( ParentSessionNotFound value)?  notFound,TResult? Function( ParentSessionError value)?  error,TResult? Function( ParentSessionLoaded value)?  loaded,}){
final _that = this;
switch (_that) {
case ParentSessionLoading() when loading != null:
return loading(_that);case ParentSessionNotFound() when notFound != null:
return notFound(_that);case ParentSessionError() when error != null:
return error(_that);case ParentSessionLoaded() when loaded != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  loading,TResult Function()?  notFound,TResult Function( String message)?  error,TResult Function( Child child,  Session session,  List<Subject> subjects,  List<ClassGroup> classes,  ChildAttendanceRecord? attendance,  List<ChildAssignment> assignments)?  loaded,required TResult orElse(),}) {final _that = this;
switch (_that) {
case ParentSessionLoading() when loading != null:
return loading();case ParentSessionNotFound() when notFound != null:
return notFound();case ParentSessionError() when error != null:
return error(_that.message);case ParentSessionLoaded() when loaded != null:
return loaded(_that.child,_that.session,_that.subjects,_that.classes,_that.attendance,_that.assignments);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  loading,required TResult Function()  notFound,required TResult Function( String message)  error,required TResult Function( Child child,  Session session,  List<Subject> subjects,  List<ClassGroup> classes,  ChildAttendanceRecord? attendance,  List<ChildAssignment> assignments)  loaded,}) {final _that = this;
switch (_that) {
case ParentSessionLoading():
return loading();case ParentSessionNotFound():
return notFound();case ParentSessionError():
return error(_that.message);case ParentSessionLoaded():
return loaded(_that.child,_that.session,_that.subjects,_that.classes,_that.attendance,_that.assignments);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  loading,TResult? Function()?  notFound,TResult? Function( String message)?  error,TResult? Function( Child child,  Session session,  List<Subject> subjects,  List<ClassGroup> classes,  ChildAttendanceRecord? attendance,  List<ChildAssignment> assignments)?  loaded,}) {final _that = this;
switch (_that) {
case ParentSessionLoading() when loading != null:
return loading();case ParentSessionNotFound() when notFound != null:
return notFound();case ParentSessionError() when error != null:
return error(_that.message);case ParentSessionLoaded() when loaded != null:
return loaded(_that.child,_that.session,_that.subjects,_that.classes,_that.attendance,_that.assignments);case _:
  return null;

}
}

}

/// @nodoc


class ParentSessionLoading implements ParentSessionDetailState {
  const ParentSessionLoading();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ParentSessionLoading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ParentSessionDetailState.loading()';
}


}




/// @nodoc


class ParentSessionNotFound implements ParentSessionDetailState {
  const ParentSessionNotFound();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ParentSessionNotFound);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ParentSessionDetailState.notFound()';
}


}




/// @nodoc


class ParentSessionError implements ParentSessionDetailState {
  const ParentSessionError(this.message);
  

 final  String message;

/// Create a copy of ParentSessionDetailState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ParentSessionErrorCopyWith<ParentSessionError> get copyWith => _$ParentSessionErrorCopyWithImpl<ParentSessionError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ParentSessionError&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'ParentSessionDetailState.error(message: $message)';
}


}

/// @nodoc
abstract mixin class $ParentSessionErrorCopyWith<$Res> implements $ParentSessionDetailStateCopyWith<$Res> {
  factory $ParentSessionErrorCopyWith(ParentSessionError value, $Res Function(ParentSessionError) _then) = _$ParentSessionErrorCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class _$ParentSessionErrorCopyWithImpl<$Res>
    implements $ParentSessionErrorCopyWith<$Res> {
  _$ParentSessionErrorCopyWithImpl(this._self, this._then);

  final ParentSessionError _self;
  final $Res Function(ParentSessionError) _then;

/// Create a copy of ParentSessionDetailState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(ParentSessionError(
null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class ParentSessionLoaded implements ParentSessionDetailState {
  const ParentSessionLoaded({required this.child, required this.session, required final  List<Subject> subjects, required final  List<ClassGroup> classes, this.attendance, final  List<ChildAssignment> assignments = const <ChildAssignment>[]}): _subjects = subjects,_classes = classes,_assignments = assignments;
  

 final  Child child;
 final  Session session;
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

/// Attendance mark for this session, `null` when not marked yet.
 final  ChildAttendanceRecord? attendance;
 final  List<ChildAssignment> _assignments;
@JsonKey() List<ChildAssignment> get assignments {
  if (_assignments is EqualUnmodifiableListView) return _assignments;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_assignments);
}


/// Create a copy of ParentSessionDetailState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ParentSessionLoadedCopyWith<ParentSessionLoaded> get copyWith => _$ParentSessionLoadedCopyWithImpl<ParentSessionLoaded>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ParentSessionLoaded&&(identical(other.child, child) || other.child == child)&&(identical(other.session, session) || other.session == session)&&const DeepCollectionEquality().equals(other._subjects, _subjects)&&const DeepCollectionEquality().equals(other._classes, _classes)&&(identical(other.attendance, attendance) || other.attendance == attendance)&&const DeepCollectionEquality().equals(other._assignments, _assignments));
}


@override
int get hashCode => Object.hash(runtimeType,child,session,const DeepCollectionEquality().hash(_subjects),const DeepCollectionEquality().hash(_classes),attendance,const DeepCollectionEquality().hash(_assignments));

@override
String toString() {
  return 'ParentSessionDetailState.loaded(child: $child, session: $session, subjects: $subjects, classes: $classes, attendance: $attendance, assignments: $assignments)';
}


}

/// @nodoc
abstract mixin class $ParentSessionLoadedCopyWith<$Res> implements $ParentSessionDetailStateCopyWith<$Res> {
  factory $ParentSessionLoadedCopyWith(ParentSessionLoaded value, $Res Function(ParentSessionLoaded) _then) = _$ParentSessionLoadedCopyWithImpl;
@useResult
$Res call({
 Child child, Session session, List<Subject> subjects, List<ClassGroup> classes, ChildAttendanceRecord? attendance, List<ChildAssignment> assignments
});


$ChildCopyWith<$Res> get child;$SessionCopyWith<$Res> get session;$ChildAttendanceRecordCopyWith<$Res>? get attendance;

}
/// @nodoc
class _$ParentSessionLoadedCopyWithImpl<$Res>
    implements $ParentSessionLoadedCopyWith<$Res> {
  _$ParentSessionLoadedCopyWithImpl(this._self, this._then);

  final ParentSessionLoaded _self;
  final $Res Function(ParentSessionLoaded) _then;

/// Create a copy of ParentSessionDetailState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? child = null,Object? session = null,Object? subjects = null,Object? classes = null,Object? attendance = freezed,Object? assignments = null,}) {
  return _then(ParentSessionLoaded(
child: null == child ? _self.child : child // ignore: cast_nullable_to_non_nullable
as Child,session: null == session ? _self.session : session // ignore: cast_nullable_to_non_nullable
as Session,subjects: null == subjects ? _self._subjects : subjects // ignore: cast_nullable_to_non_nullable
as List<Subject>,classes: null == classes ? _self._classes : classes // ignore: cast_nullable_to_non_nullable
as List<ClassGroup>,attendance: freezed == attendance ? _self.attendance : attendance // ignore: cast_nullable_to_non_nullable
as ChildAttendanceRecord?,assignments: null == assignments ? _self._assignments : assignments // ignore: cast_nullable_to_non_nullable
as List<ChildAssignment>,
  ));
}

/// Create a copy of ParentSessionDetailState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ChildCopyWith<$Res> get child {
  
  return $ChildCopyWith<$Res>(_self.child, (value) {
    return _then(_self.copyWith(child: value));
  });
}/// Create a copy of ParentSessionDetailState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SessionCopyWith<$Res> get session {
  
  return $SessionCopyWith<$Res>(_self.session, (value) {
    return _then(_self.copyWith(session: value));
  });
}/// Create a copy of ParentSessionDetailState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ChildAttendanceRecordCopyWith<$Res>? get attendance {
    if (_self.attendance == null) {
    return null;
  }

  return $ChildAttendanceRecordCopyWith<$Res>(_self.attendance!, (value) {
    return _then(_self.copyWith(attendance: value));
  });
}
}

// dart format on
