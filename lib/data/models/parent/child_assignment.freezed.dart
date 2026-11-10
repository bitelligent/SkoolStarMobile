// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'child_assignment.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ChildAssignment {

 String get id; String get childId; String get title; DateTime get deadline; String get description; int get maxMarks; bool get isCompleted; DateTime? get completedAt;/// Teacher's review comment and marks, once graded.
 String? get feedback; int? get marks; DateTime? get sessionDate; String get className; String get subjectName; String? get occurrenceId;
/// Create a copy of ChildAssignment
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChildAssignmentCopyWith<ChildAssignment> get copyWith => _$ChildAssignmentCopyWithImpl<ChildAssignment>(this as ChildAssignment, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChildAssignment&&(identical(other.id, id) || other.id == id)&&(identical(other.childId, childId) || other.childId == childId)&&(identical(other.title, title) || other.title == title)&&(identical(other.deadline, deadline) || other.deadline == deadline)&&(identical(other.description, description) || other.description == description)&&(identical(other.maxMarks, maxMarks) || other.maxMarks == maxMarks)&&(identical(other.isCompleted, isCompleted) || other.isCompleted == isCompleted)&&(identical(other.completedAt, completedAt) || other.completedAt == completedAt)&&(identical(other.feedback, feedback) || other.feedback == feedback)&&(identical(other.marks, marks) || other.marks == marks)&&(identical(other.sessionDate, sessionDate) || other.sessionDate == sessionDate)&&(identical(other.className, className) || other.className == className)&&(identical(other.subjectName, subjectName) || other.subjectName == subjectName)&&(identical(other.occurrenceId, occurrenceId) || other.occurrenceId == occurrenceId));
}


@override
int get hashCode => Object.hash(runtimeType,id,childId,title,deadline,description,maxMarks,isCompleted,completedAt,feedback,marks,sessionDate,className,subjectName,occurrenceId);

@override
String toString() {
  return 'ChildAssignment(id: $id, childId: $childId, title: $title, deadline: $deadline, description: $description, maxMarks: $maxMarks, isCompleted: $isCompleted, completedAt: $completedAt, feedback: $feedback, marks: $marks, sessionDate: $sessionDate, className: $className, subjectName: $subjectName, occurrenceId: $occurrenceId)';
}


}

/// @nodoc
abstract mixin class $ChildAssignmentCopyWith<$Res>  {
  factory $ChildAssignmentCopyWith(ChildAssignment value, $Res Function(ChildAssignment) _then) = _$ChildAssignmentCopyWithImpl;
@useResult
$Res call({
 String id, String childId, String title, DateTime deadline, String description, int maxMarks, bool isCompleted, DateTime? completedAt, String? feedback, int? marks, DateTime? sessionDate, String className, String subjectName, String? occurrenceId
});




}
/// @nodoc
class _$ChildAssignmentCopyWithImpl<$Res>
    implements $ChildAssignmentCopyWith<$Res> {
  _$ChildAssignmentCopyWithImpl(this._self, this._then);

  final ChildAssignment _self;
  final $Res Function(ChildAssignment) _then;

/// Create a copy of ChildAssignment
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? childId = null,Object? title = null,Object? deadline = null,Object? description = null,Object? maxMarks = null,Object? isCompleted = null,Object? completedAt = freezed,Object? feedback = freezed,Object? marks = freezed,Object? sessionDate = freezed,Object? className = null,Object? subjectName = null,Object? occurrenceId = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,childId: null == childId ? _self.childId : childId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,deadline: null == deadline ? _self.deadline : deadline // ignore: cast_nullable_to_non_nullable
as DateTime,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,maxMarks: null == maxMarks ? _self.maxMarks : maxMarks // ignore: cast_nullable_to_non_nullable
as int,isCompleted: null == isCompleted ? _self.isCompleted : isCompleted // ignore: cast_nullable_to_non_nullable
as bool,completedAt: freezed == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,feedback: freezed == feedback ? _self.feedback : feedback // ignore: cast_nullable_to_non_nullable
as String?,marks: freezed == marks ? _self.marks : marks // ignore: cast_nullable_to_non_nullable
as int?,sessionDate: freezed == sessionDate ? _self.sessionDate : sessionDate // ignore: cast_nullable_to_non_nullable
as DateTime?,className: null == className ? _self.className : className // ignore: cast_nullable_to_non_nullable
as String,subjectName: null == subjectName ? _self.subjectName : subjectName // ignore: cast_nullable_to_non_nullable
as String,occurrenceId: freezed == occurrenceId ? _self.occurrenceId : occurrenceId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ChildAssignment].
extension ChildAssignmentPatterns on ChildAssignment {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChildAssignment value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChildAssignment() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChildAssignment value)  $default,){
final _that = this;
switch (_that) {
case _ChildAssignment():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChildAssignment value)?  $default,){
final _that = this;
switch (_that) {
case _ChildAssignment() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String childId,  String title,  DateTime deadline,  String description,  int maxMarks,  bool isCompleted,  DateTime? completedAt,  String? feedback,  int? marks,  DateTime? sessionDate,  String className,  String subjectName,  String? occurrenceId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChildAssignment() when $default != null:
return $default(_that.id,_that.childId,_that.title,_that.deadline,_that.description,_that.maxMarks,_that.isCompleted,_that.completedAt,_that.feedback,_that.marks,_that.sessionDate,_that.className,_that.subjectName,_that.occurrenceId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String childId,  String title,  DateTime deadline,  String description,  int maxMarks,  bool isCompleted,  DateTime? completedAt,  String? feedback,  int? marks,  DateTime? sessionDate,  String className,  String subjectName,  String? occurrenceId)  $default,) {final _that = this;
switch (_that) {
case _ChildAssignment():
return $default(_that.id,_that.childId,_that.title,_that.deadline,_that.description,_that.maxMarks,_that.isCompleted,_that.completedAt,_that.feedback,_that.marks,_that.sessionDate,_that.className,_that.subjectName,_that.occurrenceId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String childId,  String title,  DateTime deadline,  String description,  int maxMarks,  bool isCompleted,  DateTime? completedAt,  String? feedback,  int? marks,  DateTime? sessionDate,  String className,  String subjectName,  String? occurrenceId)?  $default,) {final _that = this;
switch (_that) {
case _ChildAssignment() when $default != null:
return $default(_that.id,_that.childId,_that.title,_that.deadline,_that.description,_that.maxMarks,_that.isCompleted,_that.completedAt,_that.feedback,_that.marks,_that.sessionDate,_that.className,_that.subjectName,_that.occurrenceId);case _:
  return null;

}
}

}

/// @nodoc


class _ChildAssignment extends ChildAssignment {
  const _ChildAssignment({required this.id, required this.childId, required this.title, required this.deadline, this.description = '', this.maxMarks = 100, this.isCompleted = false, this.completedAt, this.feedback, this.marks, this.sessionDate, this.className = '', this.subjectName = '', this.occurrenceId}): super._();
  

@override final  String id;
@override final  String childId;
@override final  String title;
@override final  DateTime deadline;
@override@JsonKey() final  String description;
@override@JsonKey() final  int maxMarks;
@override@JsonKey() final  bool isCompleted;
@override final  DateTime? completedAt;
/// Teacher's review comment and marks, once graded.
@override final  String? feedback;
@override final  int? marks;
@override final  DateTime? sessionDate;
@override@JsonKey() final  String className;
@override@JsonKey() final  String subjectName;
@override final  String? occurrenceId;

/// Create a copy of ChildAssignment
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChildAssignmentCopyWith<_ChildAssignment> get copyWith => __$ChildAssignmentCopyWithImpl<_ChildAssignment>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChildAssignment&&(identical(other.id, id) || other.id == id)&&(identical(other.childId, childId) || other.childId == childId)&&(identical(other.title, title) || other.title == title)&&(identical(other.deadline, deadline) || other.deadline == deadline)&&(identical(other.description, description) || other.description == description)&&(identical(other.maxMarks, maxMarks) || other.maxMarks == maxMarks)&&(identical(other.isCompleted, isCompleted) || other.isCompleted == isCompleted)&&(identical(other.completedAt, completedAt) || other.completedAt == completedAt)&&(identical(other.feedback, feedback) || other.feedback == feedback)&&(identical(other.marks, marks) || other.marks == marks)&&(identical(other.sessionDate, sessionDate) || other.sessionDate == sessionDate)&&(identical(other.className, className) || other.className == className)&&(identical(other.subjectName, subjectName) || other.subjectName == subjectName)&&(identical(other.occurrenceId, occurrenceId) || other.occurrenceId == occurrenceId));
}


@override
int get hashCode => Object.hash(runtimeType,id,childId,title,deadline,description,maxMarks,isCompleted,completedAt,feedback,marks,sessionDate,className,subjectName,occurrenceId);

@override
String toString() {
  return 'ChildAssignment(id: $id, childId: $childId, title: $title, deadline: $deadline, description: $description, maxMarks: $maxMarks, isCompleted: $isCompleted, completedAt: $completedAt, feedback: $feedback, marks: $marks, sessionDate: $sessionDate, className: $className, subjectName: $subjectName, occurrenceId: $occurrenceId)';
}


}

/// @nodoc
abstract mixin class _$ChildAssignmentCopyWith<$Res> implements $ChildAssignmentCopyWith<$Res> {
  factory _$ChildAssignmentCopyWith(_ChildAssignment value, $Res Function(_ChildAssignment) _then) = __$ChildAssignmentCopyWithImpl;
@override @useResult
$Res call({
 String id, String childId, String title, DateTime deadline, String description, int maxMarks, bool isCompleted, DateTime? completedAt, String? feedback, int? marks, DateTime? sessionDate, String className, String subjectName, String? occurrenceId
});




}
/// @nodoc
class __$ChildAssignmentCopyWithImpl<$Res>
    implements _$ChildAssignmentCopyWith<$Res> {
  __$ChildAssignmentCopyWithImpl(this._self, this._then);

  final _ChildAssignment _self;
  final $Res Function(_ChildAssignment) _then;

/// Create a copy of ChildAssignment
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? childId = null,Object? title = null,Object? deadline = null,Object? description = null,Object? maxMarks = null,Object? isCompleted = null,Object? completedAt = freezed,Object? feedback = freezed,Object? marks = freezed,Object? sessionDate = freezed,Object? className = null,Object? subjectName = null,Object? occurrenceId = freezed,}) {
  return _then(_ChildAssignment(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,childId: null == childId ? _self.childId : childId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,deadline: null == deadline ? _self.deadline : deadline // ignore: cast_nullable_to_non_nullable
as DateTime,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,maxMarks: null == maxMarks ? _self.maxMarks : maxMarks // ignore: cast_nullable_to_non_nullable
as int,isCompleted: null == isCompleted ? _self.isCompleted : isCompleted // ignore: cast_nullable_to_non_nullable
as bool,completedAt: freezed == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,feedback: freezed == feedback ? _self.feedback : feedback // ignore: cast_nullable_to_non_nullable
as String?,marks: freezed == marks ? _self.marks : marks // ignore: cast_nullable_to_non_nullable
as int?,sessionDate: freezed == sessionDate ? _self.sessionDate : sessionDate // ignore: cast_nullable_to_non_nullable
as DateTime?,className: null == className ? _self.className : className // ignore: cast_nullable_to_non_nullable
as String,subjectName: null == subjectName ? _self.subjectName : subjectName // ignore: cast_nullable_to_non_nullable
as String,occurrenceId: freezed == occurrenceId ? _self.occurrenceId : occurrenceId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
