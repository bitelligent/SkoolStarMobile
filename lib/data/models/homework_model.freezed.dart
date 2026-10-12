// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'homework_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$HomeworkAttachment {

 String get fileName; int get sizeKb; String get type;/// Server reference returned by the upload endpoint (empty until uploaded).
 String get reference;
/// Create a copy of HomeworkAttachment
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HomeworkAttachmentCopyWith<HomeworkAttachment> get copyWith => _$HomeworkAttachmentCopyWithImpl<HomeworkAttachment>(this as HomeworkAttachment, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HomeworkAttachment&&(identical(other.fileName, fileName) || other.fileName == fileName)&&(identical(other.sizeKb, sizeKb) || other.sizeKb == sizeKb)&&(identical(other.type, type) || other.type == type)&&(identical(other.reference, reference) || other.reference == reference));
}


@override
int get hashCode => Object.hash(runtimeType,fileName,sizeKb,type,reference);

@override
String toString() {
  return 'HomeworkAttachment(fileName: $fileName, sizeKb: $sizeKb, type: $type, reference: $reference)';
}


}

/// @nodoc
abstract mixin class $HomeworkAttachmentCopyWith<$Res>  {
  factory $HomeworkAttachmentCopyWith(HomeworkAttachment value, $Res Function(HomeworkAttachment) _then) = _$HomeworkAttachmentCopyWithImpl;
@useResult
$Res call({
 String fileName, int sizeKb, String type, String reference
});




}
/// @nodoc
class _$HomeworkAttachmentCopyWithImpl<$Res>
    implements $HomeworkAttachmentCopyWith<$Res> {
  _$HomeworkAttachmentCopyWithImpl(this._self, this._then);

  final HomeworkAttachment _self;
  final $Res Function(HomeworkAttachment) _then;

/// Create a copy of HomeworkAttachment
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? fileName = null,Object? sizeKb = null,Object? type = null,Object? reference = null,}) {
  return _then(_self.copyWith(
fileName: null == fileName ? _self.fileName : fileName // ignore: cast_nullable_to_non_nullable
as String,sizeKb: null == sizeKb ? _self.sizeKb : sizeKb // ignore: cast_nullable_to_non_nullable
as int,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,reference: null == reference ? _self.reference : reference // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [HomeworkAttachment].
extension HomeworkAttachmentPatterns on HomeworkAttachment {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HomeworkAttachment value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HomeworkAttachment() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HomeworkAttachment value)  $default,){
final _that = this;
switch (_that) {
case _HomeworkAttachment():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HomeworkAttachment value)?  $default,){
final _that = this;
switch (_that) {
case _HomeworkAttachment() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String fileName,  int sizeKb,  String type,  String reference)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HomeworkAttachment() when $default != null:
return $default(_that.fileName,_that.sizeKb,_that.type,_that.reference);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String fileName,  int sizeKb,  String type,  String reference)  $default,) {final _that = this;
switch (_that) {
case _HomeworkAttachment():
return $default(_that.fileName,_that.sizeKb,_that.type,_that.reference);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String fileName,  int sizeKb,  String type,  String reference)?  $default,) {final _that = this;
switch (_that) {
case _HomeworkAttachment() when $default != null:
return $default(_that.fileName,_that.sizeKb,_that.type,_that.reference);case _:
  return null;

}
}

}

/// @nodoc


class _HomeworkAttachment extends HomeworkAttachment {
  const _HomeworkAttachment({required this.fileName, required this.sizeKb, required this.type, this.reference = ''}): super._();
  

@override final  String fileName;
@override final  int sizeKb;
@override final  String type;
/// Server reference returned by the upload endpoint (empty until uploaded).
@override@JsonKey() final  String reference;

/// Create a copy of HomeworkAttachment
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HomeworkAttachmentCopyWith<_HomeworkAttachment> get copyWith => __$HomeworkAttachmentCopyWithImpl<_HomeworkAttachment>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _HomeworkAttachment&&(identical(other.fileName, fileName) || other.fileName == fileName)&&(identical(other.sizeKb, sizeKb) || other.sizeKb == sizeKb)&&(identical(other.type, type) || other.type == type)&&(identical(other.reference, reference) || other.reference == reference));
}


@override
int get hashCode => Object.hash(runtimeType,fileName,sizeKb,type,reference);

@override
String toString() {
  return 'HomeworkAttachment(fileName: $fileName, sizeKb: $sizeKb, type: $type, reference: $reference)';
}


}

/// @nodoc
abstract mixin class _$HomeworkAttachmentCopyWith<$Res> implements $HomeworkAttachmentCopyWith<$Res> {
  factory _$HomeworkAttachmentCopyWith(_HomeworkAttachment value, $Res Function(_HomeworkAttachment) _then) = __$HomeworkAttachmentCopyWithImpl;
@override @useResult
$Res call({
 String fileName, int sizeKb, String type, String reference
});




}
/// @nodoc
class __$HomeworkAttachmentCopyWithImpl<$Res>
    implements _$HomeworkAttachmentCopyWith<$Res> {
  __$HomeworkAttachmentCopyWithImpl(this._self, this._then);

  final _HomeworkAttachment _self;
  final $Res Function(_HomeworkAttachment) _then;

/// Create a copy of HomeworkAttachment
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? fileName = null,Object? sizeKb = null,Object? type = null,Object? reference = null,}) {
  return _then(_HomeworkAttachment(
fileName: null == fileName ? _self.fileName : fileName // ignore: cast_nullable_to_non_nullable
as String,sizeKb: null == sizeKb ? _self.sizeKb : sizeKb // ignore: cast_nullable_to_non_nullable
as int,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,reference: null == reference ? _self.reference : reference // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$Homework {

 String get id; String get sessionId; String get classId; String get subjectId; String get title; String get description; DateTime get deadline; int get maxMarks; List<String> get assignedStudentIds;/// Number of students the task is assigned to, when the server only sends
/// a count (`totalAssigned`) and not their ids.
 int get assignedCount; List<HomeworkAttachment> get attachments;
/// Create a copy of Homework
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HomeworkCopyWith<Homework> get copyWith => _$HomeworkCopyWithImpl<Homework>(this as Homework, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Homework&&(identical(other.id, id) || other.id == id)&&(identical(other.sessionId, sessionId) || other.sessionId == sessionId)&&(identical(other.classId, classId) || other.classId == classId)&&(identical(other.subjectId, subjectId) || other.subjectId == subjectId)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.deadline, deadline) || other.deadline == deadline)&&(identical(other.maxMarks, maxMarks) || other.maxMarks == maxMarks)&&const DeepCollectionEquality().equals(other.assignedStudentIds, assignedStudentIds)&&(identical(other.assignedCount, assignedCount) || other.assignedCount == assignedCount)&&const DeepCollectionEquality().equals(other.attachments, attachments));
}


@override
int get hashCode => Object.hash(runtimeType,id,sessionId,classId,subjectId,title,description,deadline,maxMarks,const DeepCollectionEquality().hash(assignedStudentIds),assignedCount,const DeepCollectionEquality().hash(attachments));

@override
String toString() {
  return 'Homework(id: $id, sessionId: $sessionId, classId: $classId, subjectId: $subjectId, title: $title, description: $description, deadline: $deadline, maxMarks: $maxMarks, assignedStudentIds: $assignedStudentIds, assignedCount: $assignedCount, attachments: $attachments)';
}


}

/// @nodoc
abstract mixin class $HomeworkCopyWith<$Res>  {
  factory $HomeworkCopyWith(Homework value, $Res Function(Homework) _then) = _$HomeworkCopyWithImpl;
@useResult
$Res call({
 String id, String sessionId, String classId, String subjectId, String title, String description, DateTime deadline, int maxMarks, List<String> assignedStudentIds, int assignedCount, List<HomeworkAttachment> attachments
});




}
/// @nodoc
class _$HomeworkCopyWithImpl<$Res>
    implements $HomeworkCopyWith<$Res> {
  _$HomeworkCopyWithImpl(this._self, this._then);

  final Homework _self;
  final $Res Function(Homework) _then;

/// Create a copy of Homework
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? sessionId = null,Object? classId = null,Object? subjectId = null,Object? title = null,Object? description = null,Object? deadline = null,Object? maxMarks = null,Object? assignedStudentIds = null,Object? assignedCount = null,Object? attachments = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,sessionId: null == sessionId ? _self.sessionId : sessionId // ignore: cast_nullable_to_non_nullable
as String,classId: null == classId ? _self.classId : classId // ignore: cast_nullable_to_non_nullable
as String,subjectId: null == subjectId ? _self.subjectId : subjectId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,deadline: null == deadline ? _self.deadline : deadline // ignore: cast_nullable_to_non_nullable
as DateTime,maxMarks: null == maxMarks ? _self.maxMarks : maxMarks // ignore: cast_nullable_to_non_nullable
as int,assignedStudentIds: null == assignedStudentIds ? _self.assignedStudentIds : assignedStudentIds // ignore: cast_nullable_to_non_nullable
as List<String>,assignedCount: null == assignedCount ? _self.assignedCount : assignedCount // ignore: cast_nullable_to_non_nullable
as int,attachments: null == attachments ? _self.attachments : attachments // ignore: cast_nullable_to_non_nullable
as List<HomeworkAttachment>,
  ));
}

}


/// Adds pattern-matching-related methods to [Homework].
extension HomeworkPatterns on Homework {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Homework value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Homework() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Homework value)  $default,){
final _that = this;
switch (_that) {
case _Homework():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Homework value)?  $default,){
final _that = this;
switch (_that) {
case _Homework() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String sessionId,  String classId,  String subjectId,  String title,  String description,  DateTime deadline,  int maxMarks,  List<String> assignedStudentIds,  int assignedCount,  List<HomeworkAttachment> attachments)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Homework() when $default != null:
return $default(_that.id,_that.sessionId,_that.classId,_that.subjectId,_that.title,_that.description,_that.deadline,_that.maxMarks,_that.assignedStudentIds,_that.assignedCount,_that.attachments);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String sessionId,  String classId,  String subjectId,  String title,  String description,  DateTime deadline,  int maxMarks,  List<String> assignedStudentIds,  int assignedCount,  List<HomeworkAttachment> attachments)  $default,) {final _that = this;
switch (_that) {
case _Homework():
return $default(_that.id,_that.sessionId,_that.classId,_that.subjectId,_that.title,_that.description,_that.deadline,_that.maxMarks,_that.assignedStudentIds,_that.assignedCount,_that.attachments);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String sessionId,  String classId,  String subjectId,  String title,  String description,  DateTime deadline,  int maxMarks,  List<String> assignedStudentIds,  int assignedCount,  List<HomeworkAttachment> attachments)?  $default,) {final _that = this;
switch (_that) {
case _Homework() when $default != null:
return $default(_that.id,_that.sessionId,_that.classId,_that.subjectId,_that.title,_that.description,_that.deadline,_that.maxMarks,_that.assignedStudentIds,_that.assignedCount,_that.attachments);case _:
  return null;

}
}

}

/// @nodoc


class _Homework extends Homework {
  const _Homework({required this.id, required this.sessionId, required this.classId, required this.subjectId, required this.title, required this.description, required this.deadline, this.maxMarks = 100, final  List<String> assignedStudentIds = const [], this.assignedCount = 0, final  List<HomeworkAttachment> attachments = const []}): _assignedStudentIds = assignedStudentIds,_attachments = attachments,super._();
  

@override final  String id;
@override final  String sessionId;
@override final  String classId;
@override final  String subjectId;
@override final  String title;
@override final  String description;
@override final  DateTime deadline;
@override@JsonKey() final  int maxMarks;
 final  List<String> _assignedStudentIds;
@override@JsonKey() List<String> get assignedStudentIds {
  if (_assignedStudentIds is EqualUnmodifiableListView) return _assignedStudentIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_assignedStudentIds);
}

/// Number of students the task is assigned to, when the server only sends
/// a count (`totalAssigned`) and not their ids.
@override@JsonKey() final  int assignedCount;
 final  List<HomeworkAttachment> _attachments;
@override@JsonKey() List<HomeworkAttachment> get attachments {
  if (_attachments is EqualUnmodifiableListView) return _attachments;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_attachments);
}


/// Create a copy of Homework
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HomeworkCopyWith<_Homework> get copyWith => __$HomeworkCopyWithImpl<_Homework>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Homework&&(identical(other.id, id) || other.id == id)&&(identical(other.sessionId, sessionId) || other.sessionId == sessionId)&&(identical(other.classId, classId) || other.classId == classId)&&(identical(other.subjectId, subjectId) || other.subjectId == subjectId)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.deadline, deadline) || other.deadline == deadline)&&(identical(other.maxMarks, maxMarks) || other.maxMarks == maxMarks)&&const DeepCollectionEquality().equals(other._assignedStudentIds, _assignedStudentIds)&&(identical(other.assignedCount, assignedCount) || other.assignedCount == assignedCount)&&const DeepCollectionEquality().equals(other._attachments, _attachments));
}


@override
int get hashCode => Object.hash(runtimeType,id,sessionId,classId,subjectId,title,description,deadline,maxMarks,const DeepCollectionEquality().hash(_assignedStudentIds),assignedCount,const DeepCollectionEquality().hash(_attachments));

@override
String toString() {
  return 'Homework(id: $id, sessionId: $sessionId, classId: $classId, subjectId: $subjectId, title: $title, description: $description, deadline: $deadline, maxMarks: $maxMarks, assignedStudentIds: $assignedStudentIds, assignedCount: $assignedCount, attachments: $attachments)';
}


}

/// @nodoc
abstract mixin class _$HomeworkCopyWith<$Res> implements $HomeworkCopyWith<$Res> {
  factory _$HomeworkCopyWith(_Homework value, $Res Function(_Homework) _then) = __$HomeworkCopyWithImpl;
@override @useResult
$Res call({
 String id, String sessionId, String classId, String subjectId, String title, String description, DateTime deadline, int maxMarks, List<String> assignedStudentIds, int assignedCount, List<HomeworkAttachment> attachments
});




}
/// @nodoc
class __$HomeworkCopyWithImpl<$Res>
    implements _$HomeworkCopyWith<$Res> {
  __$HomeworkCopyWithImpl(this._self, this._then);

  final _Homework _self;
  final $Res Function(_Homework) _then;

/// Create a copy of Homework
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? sessionId = null,Object? classId = null,Object? subjectId = null,Object? title = null,Object? description = null,Object? deadline = null,Object? maxMarks = null,Object? assignedStudentIds = null,Object? assignedCount = null,Object? attachments = null,}) {
  return _then(_Homework(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,sessionId: null == sessionId ? _self.sessionId : sessionId // ignore: cast_nullable_to_non_nullable
as String,classId: null == classId ? _self.classId : classId // ignore: cast_nullable_to_non_nullable
as String,subjectId: null == subjectId ? _self.subjectId : subjectId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,deadline: null == deadline ? _self.deadline : deadline // ignore: cast_nullable_to_non_nullable
as DateTime,maxMarks: null == maxMarks ? _self.maxMarks : maxMarks // ignore: cast_nullable_to_non_nullable
as int,assignedStudentIds: null == assignedStudentIds ? _self._assignedStudentIds : assignedStudentIds // ignore: cast_nullable_to_non_nullable
as List<String>,assignedCount: null == assignedCount ? _self.assignedCount : assignedCount // ignore: cast_nullable_to_non_nullable
as int,attachments: null == attachments ? _self._attachments : attachments // ignore: cast_nullable_to_non_nullable
as List<HomeworkAttachment>,
  ));
}


}

// dart format on
