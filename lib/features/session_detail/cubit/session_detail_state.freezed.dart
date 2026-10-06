// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'session_detail_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SessionDetailState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SessionDetailState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'SessionDetailState()';
}


}

/// @nodoc
class $SessionDetailStateCopyWith<$Res>  {
$SessionDetailStateCopyWith(SessionDetailState _, $Res Function(SessionDetailState) __);
}


/// Adds pattern-matching-related methods to [SessionDetailState].
extension SessionDetailStatePatterns on SessionDetailState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( SessionDetailInitial value)?  initial,TResult Function( SessionDetailLoading value)?  loading,TResult Function( SessionDetailLoaded value)?  loaded,TResult Function( SessionDetailError value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case SessionDetailInitial() when initial != null:
return initial(_that);case SessionDetailLoading() when loading != null:
return loading(_that);case SessionDetailLoaded() when loaded != null:
return loaded(_that);case SessionDetailError() when error != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( SessionDetailInitial value)  initial,required TResult Function( SessionDetailLoading value)  loading,required TResult Function( SessionDetailLoaded value)  loaded,required TResult Function( SessionDetailError value)  error,}){
final _that = this;
switch (_that) {
case SessionDetailInitial():
return initial(_that);case SessionDetailLoading():
return loading(_that);case SessionDetailLoaded():
return loaded(_that);case SessionDetailError():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( SessionDetailInitial value)?  initial,TResult? Function( SessionDetailLoading value)?  loading,TResult? Function( SessionDetailLoaded value)?  loaded,TResult? Function( SessionDetailError value)?  error,}){
final _that = this;
switch (_that) {
case SessionDetailInitial() when initial != null:
return initial(_that);case SessionDetailLoading() when loading != null:
return loading(_that);case SessionDetailLoaded() when loaded != null:
return loaded(_that);case SessionDetailError() when error != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initial,TResult Function()?  loading,TResult Function( Session session,  List<ClassGroup> classes,  List<Subject> subjects,  List<Student> students,  Map<String, String> attendance,  List<Homework> homeworks,  List<FeedbackMessage> feedbackMessages,  List<AssignmentReview> assignmentReviews,  String studentSearch,  String activeClassFilter,  bool attendanceSubmitting)?  loaded,TResult Function( String message)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case SessionDetailInitial() when initial != null:
return initial();case SessionDetailLoading() when loading != null:
return loading();case SessionDetailLoaded() when loaded != null:
return loaded(_that.session,_that.classes,_that.subjects,_that.students,_that.attendance,_that.homeworks,_that.feedbackMessages,_that.assignmentReviews,_that.studentSearch,_that.activeClassFilter,_that.attendanceSubmitting);case SessionDetailError() when error != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initial,required TResult Function()  loading,required TResult Function( Session session,  List<ClassGroup> classes,  List<Subject> subjects,  List<Student> students,  Map<String, String> attendance,  List<Homework> homeworks,  List<FeedbackMessage> feedbackMessages,  List<AssignmentReview> assignmentReviews,  String studentSearch,  String activeClassFilter,  bool attendanceSubmitting)  loaded,required TResult Function( String message)  error,}) {final _that = this;
switch (_that) {
case SessionDetailInitial():
return initial();case SessionDetailLoading():
return loading();case SessionDetailLoaded():
return loaded(_that.session,_that.classes,_that.subjects,_that.students,_that.attendance,_that.homeworks,_that.feedbackMessages,_that.assignmentReviews,_that.studentSearch,_that.activeClassFilter,_that.attendanceSubmitting);case SessionDetailError():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initial,TResult? Function()?  loading,TResult? Function( Session session,  List<ClassGroup> classes,  List<Subject> subjects,  List<Student> students,  Map<String, String> attendance,  List<Homework> homeworks,  List<FeedbackMessage> feedbackMessages,  List<AssignmentReview> assignmentReviews,  String studentSearch,  String activeClassFilter,  bool attendanceSubmitting)?  loaded,TResult? Function( String message)?  error,}) {final _that = this;
switch (_that) {
case SessionDetailInitial() when initial != null:
return initial();case SessionDetailLoading() when loading != null:
return loading();case SessionDetailLoaded() when loaded != null:
return loaded(_that.session,_that.classes,_that.subjects,_that.students,_that.attendance,_that.homeworks,_that.feedbackMessages,_that.assignmentReviews,_that.studentSearch,_that.activeClassFilter,_that.attendanceSubmitting);case SessionDetailError() when error != null:
return error(_that.message);case _:
  return null;

}
}

}

/// @nodoc


class SessionDetailInitial implements SessionDetailState {
  const SessionDetailInitial();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SessionDetailInitial);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'SessionDetailState.initial()';
}


}




/// @nodoc


class SessionDetailLoading implements SessionDetailState {
  const SessionDetailLoading();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SessionDetailLoading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'SessionDetailState.loading()';
}


}




/// @nodoc


class SessionDetailLoaded implements SessionDetailState {
  const SessionDetailLoaded({required this.session, required final  List<ClassGroup> classes, required final  List<Subject> subjects, required final  List<Student> students, required final  Map<String, String> attendance, required final  List<Homework> homeworks, required final  List<FeedbackMessage> feedbackMessages, required final  List<AssignmentReview> assignmentReviews, this.studentSearch = '', this.activeClassFilter = '', this.attendanceSubmitting = false}): _classes = classes,_subjects = subjects,_students = students,_attendance = attendance,_homeworks = homeworks,_feedbackMessages = feedbackMessages,_assignmentReviews = assignmentReviews;
  

 final  Session session;
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

 final  List<Student> _students;
 List<Student> get students {
  if (_students is EqualUnmodifiableListView) return _students;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_students);
}

 final  Map<String, String> _attendance;
 Map<String, String> get attendance {
  if (_attendance is EqualUnmodifiableMapView) return _attendance;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_attendance);
}

 final  List<Homework> _homeworks;
 List<Homework> get homeworks {
  if (_homeworks is EqualUnmodifiableListView) return _homeworks;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_homeworks);
}

 final  List<FeedbackMessage> _feedbackMessages;
 List<FeedbackMessage> get feedbackMessages {
  if (_feedbackMessages is EqualUnmodifiableListView) return _feedbackMessages;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_feedbackMessages);
}

 final  List<AssignmentReview> _assignmentReviews;
 List<AssignmentReview> get assignmentReviews {
  if (_assignmentReviews is EqualUnmodifiableListView) return _assignmentReviews;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_assignmentReviews);
}

@JsonKey() final  String studentSearch;
@JsonKey() final  String activeClassFilter;
@JsonKey() final  bool attendanceSubmitting;

/// Create a copy of SessionDetailState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SessionDetailLoadedCopyWith<SessionDetailLoaded> get copyWith => _$SessionDetailLoadedCopyWithImpl<SessionDetailLoaded>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SessionDetailLoaded&&(identical(other.session, session) || other.session == session)&&const DeepCollectionEquality().equals(other._classes, _classes)&&const DeepCollectionEquality().equals(other._subjects, _subjects)&&const DeepCollectionEquality().equals(other._students, _students)&&const DeepCollectionEquality().equals(other._attendance, _attendance)&&const DeepCollectionEquality().equals(other._homeworks, _homeworks)&&const DeepCollectionEquality().equals(other._feedbackMessages, _feedbackMessages)&&const DeepCollectionEquality().equals(other._assignmentReviews, _assignmentReviews)&&(identical(other.studentSearch, studentSearch) || other.studentSearch == studentSearch)&&(identical(other.activeClassFilter, activeClassFilter) || other.activeClassFilter == activeClassFilter)&&(identical(other.attendanceSubmitting, attendanceSubmitting) || other.attendanceSubmitting == attendanceSubmitting));
}


@override
int get hashCode => Object.hash(runtimeType,session,const DeepCollectionEquality().hash(_classes),const DeepCollectionEquality().hash(_subjects),const DeepCollectionEquality().hash(_students),const DeepCollectionEquality().hash(_attendance),const DeepCollectionEquality().hash(_homeworks),const DeepCollectionEquality().hash(_feedbackMessages),const DeepCollectionEquality().hash(_assignmentReviews),studentSearch,activeClassFilter,attendanceSubmitting);

@override
String toString() {
  return 'SessionDetailState.loaded(session: $session, classes: $classes, subjects: $subjects, students: $students, attendance: $attendance, homeworks: $homeworks, feedbackMessages: $feedbackMessages, assignmentReviews: $assignmentReviews, studentSearch: $studentSearch, activeClassFilter: $activeClassFilter, attendanceSubmitting: $attendanceSubmitting)';
}


}

/// @nodoc
abstract mixin class $SessionDetailLoadedCopyWith<$Res> implements $SessionDetailStateCopyWith<$Res> {
  factory $SessionDetailLoadedCopyWith(SessionDetailLoaded value, $Res Function(SessionDetailLoaded) _then) = _$SessionDetailLoadedCopyWithImpl;
@useResult
$Res call({
 Session session, List<ClassGroup> classes, List<Subject> subjects, List<Student> students, Map<String, String> attendance, List<Homework> homeworks, List<FeedbackMessage> feedbackMessages, List<AssignmentReview> assignmentReviews, String studentSearch, String activeClassFilter, bool attendanceSubmitting
});


$SessionCopyWith<$Res> get session;

}
/// @nodoc
class _$SessionDetailLoadedCopyWithImpl<$Res>
    implements $SessionDetailLoadedCopyWith<$Res> {
  _$SessionDetailLoadedCopyWithImpl(this._self, this._then);

  final SessionDetailLoaded _self;
  final $Res Function(SessionDetailLoaded) _then;

/// Create a copy of SessionDetailState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? session = null,Object? classes = null,Object? subjects = null,Object? students = null,Object? attendance = null,Object? homeworks = null,Object? feedbackMessages = null,Object? assignmentReviews = null,Object? studentSearch = null,Object? activeClassFilter = null,Object? attendanceSubmitting = null,}) {
  return _then(SessionDetailLoaded(
session: null == session ? _self.session : session // ignore: cast_nullable_to_non_nullable
as Session,classes: null == classes ? _self._classes : classes // ignore: cast_nullable_to_non_nullable
as List<ClassGroup>,subjects: null == subjects ? _self._subjects : subjects // ignore: cast_nullable_to_non_nullable
as List<Subject>,students: null == students ? _self._students : students // ignore: cast_nullable_to_non_nullable
as List<Student>,attendance: null == attendance ? _self._attendance : attendance // ignore: cast_nullable_to_non_nullable
as Map<String, String>,homeworks: null == homeworks ? _self._homeworks : homeworks // ignore: cast_nullable_to_non_nullable
as List<Homework>,feedbackMessages: null == feedbackMessages ? _self._feedbackMessages : feedbackMessages // ignore: cast_nullable_to_non_nullable
as List<FeedbackMessage>,assignmentReviews: null == assignmentReviews ? _self._assignmentReviews : assignmentReviews // ignore: cast_nullable_to_non_nullable
as List<AssignmentReview>,studentSearch: null == studentSearch ? _self.studentSearch : studentSearch // ignore: cast_nullable_to_non_nullable
as String,activeClassFilter: null == activeClassFilter ? _self.activeClassFilter : activeClassFilter // ignore: cast_nullable_to_non_nullable
as String,attendanceSubmitting: null == attendanceSubmitting ? _self.attendanceSubmitting : attendanceSubmitting // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of SessionDetailState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SessionCopyWith<$Res> get session {
  
  return $SessionCopyWith<$Res>(_self.session, (value) {
    return _then(_self.copyWith(session: value));
  });
}
}

/// @nodoc


class SessionDetailError implements SessionDetailState {
  const SessionDetailError(this.message);
  

 final  String message;

/// Create a copy of SessionDetailState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SessionDetailErrorCopyWith<SessionDetailError> get copyWith => _$SessionDetailErrorCopyWithImpl<SessionDetailError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SessionDetailError&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'SessionDetailState.error(message: $message)';
}


}

/// @nodoc
abstract mixin class $SessionDetailErrorCopyWith<$Res> implements $SessionDetailStateCopyWith<$Res> {
  factory $SessionDetailErrorCopyWith(SessionDetailError value, $Res Function(SessionDetailError) _then) = _$SessionDetailErrorCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class _$SessionDetailErrorCopyWithImpl<$Res>
    implements $SessionDetailErrorCopyWith<$Res> {
  _$SessionDetailErrorCopyWithImpl(this._self, this._then);

  final SessionDetailError _self;
  final $Res Function(SessionDetailError) _then;

/// Create a copy of SessionDetailState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(SessionDetailError(
null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
