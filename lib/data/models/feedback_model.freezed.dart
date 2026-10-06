// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'feedback_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$FeedbackMessage {

 String get id; String get sessionId; List<String> get studentIds; String get message; bool get isPositive; DateTime? get sentAt;
/// Create a copy of FeedbackMessage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FeedbackMessageCopyWith<FeedbackMessage> get copyWith => _$FeedbackMessageCopyWithImpl<FeedbackMessage>(this as FeedbackMessage, _$identity);

  /// Serializes this FeedbackMessage to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FeedbackMessage&&(identical(other.id, id) || other.id == id)&&(identical(other.sessionId, sessionId) || other.sessionId == sessionId)&&const DeepCollectionEquality().equals(other.studentIds, studentIds)&&(identical(other.message, message) || other.message == message)&&(identical(other.isPositive, isPositive) || other.isPositive == isPositive)&&(identical(other.sentAt, sentAt) || other.sentAt == sentAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,sessionId,const DeepCollectionEquality().hash(studentIds),message,isPositive,sentAt);

@override
String toString() {
  return 'FeedbackMessage(id: $id, sessionId: $sessionId, studentIds: $studentIds, message: $message, isPositive: $isPositive, sentAt: $sentAt)';
}


}

/// @nodoc
abstract mixin class $FeedbackMessageCopyWith<$Res>  {
  factory $FeedbackMessageCopyWith(FeedbackMessage value, $Res Function(FeedbackMessage) _then) = _$FeedbackMessageCopyWithImpl;
@useResult
$Res call({
 String id, String sessionId, List<String> studentIds, String message, bool isPositive, DateTime? sentAt
});




}
/// @nodoc
class _$FeedbackMessageCopyWithImpl<$Res>
    implements $FeedbackMessageCopyWith<$Res> {
  _$FeedbackMessageCopyWithImpl(this._self, this._then);

  final FeedbackMessage _self;
  final $Res Function(FeedbackMessage) _then;

/// Create a copy of FeedbackMessage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? sessionId = null,Object? studentIds = null,Object? message = null,Object? isPositive = null,Object? sentAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,sessionId: null == sessionId ? _self.sessionId : sessionId // ignore: cast_nullable_to_non_nullable
as String,studentIds: null == studentIds ? _self.studentIds : studentIds // ignore: cast_nullable_to_non_nullable
as List<String>,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,isPositive: null == isPositive ? _self.isPositive : isPositive // ignore: cast_nullable_to_non_nullable
as bool,sentAt: freezed == sentAt ? _self.sentAt : sentAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [FeedbackMessage].
extension FeedbackMessagePatterns on FeedbackMessage {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FeedbackMessage value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FeedbackMessage() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FeedbackMessage value)  $default,){
final _that = this;
switch (_that) {
case _FeedbackMessage():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FeedbackMessage value)?  $default,){
final _that = this;
switch (_that) {
case _FeedbackMessage() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String sessionId,  List<String> studentIds,  String message,  bool isPositive,  DateTime? sentAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FeedbackMessage() when $default != null:
return $default(_that.id,_that.sessionId,_that.studentIds,_that.message,_that.isPositive,_that.sentAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String sessionId,  List<String> studentIds,  String message,  bool isPositive,  DateTime? sentAt)  $default,) {final _that = this;
switch (_that) {
case _FeedbackMessage():
return $default(_that.id,_that.sessionId,_that.studentIds,_that.message,_that.isPositive,_that.sentAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String sessionId,  List<String> studentIds,  String message,  bool isPositive,  DateTime? sentAt)?  $default,) {final _that = this;
switch (_that) {
case _FeedbackMessage() when $default != null:
return $default(_that.id,_that.sessionId,_that.studentIds,_that.message,_that.isPositive,_that.sentAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FeedbackMessage implements FeedbackMessage {
  const _FeedbackMessage({required this.id, required this.sessionId, required final  List<String> studentIds, required this.message, this.isPositive = true, this.sentAt}): _studentIds = studentIds;
  factory _FeedbackMessage.fromJson(Map<String, dynamic> json) => _$FeedbackMessageFromJson(json);

@override final  String id;
@override final  String sessionId;
 final  List<String> _studentIds;
@override List<String> get studentIds {
  if (_studentIds is EqualUnmodifiableListView) return _studentIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_studentIds);
}

@override final  String message;
@override@JsonKey() final  bool isPositive;
@override final  DateTime? sentAt;

/// Create a copy of FeedbackMessage
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FeedbackMessageCopyWith<_FeedbackMessage> get copyWith => __$FeedbackMessageCopyWithImpl<_FeedbackMessage>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FeedbackMessageToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FeedbackMessage&&(identical(other.id, id) || other.id == id)&&(identical(other.sessionId, sessionId) || other.sessionId == sessionId)&&const DeepCollectionEquality().equals(other._studentIds, _studentIds)&&(identical(other.message, message) || other.message == message)&&(identical(other.isPositive, isPositive) || other.isPositive == isPositive)&&(identical(other.sentAt, sentAt) || other.sentAt == sentAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,sessionId,const DeepCollectionEquality().hash(_studentIds),message,isPositive,sentAt);

@override
String toString() {
  return 'FeedbackMessage(id: $id, sessionId: $sessionId, studentIds: $studentIds, message: $message, isPositive: $isPositive, sentAt: $sentAt)';
}


}

/// @nodoc
abstract mixin class _$FeedbackMessageCopyWith<$Res> implements $FeedbackMessageCopyWith<$Res> {
  factory _$FeedbackMessageCopyWith(_FeedbackMessage value, $Res Function(_FeedbackMessage) _then) = __$FeedbackMessageCopyWithImpl;
@override @useResult
$Res call({
 String id, String sessionId, List<String> studentIds, String message, bool isPositive, DateTime? sentAt
});




}
/// @nodoc
class __$FeedbackMessageCopyWithImpl<$Res>
    implements _$FeedbackMessageCopyWith<$Res> {
  __$FeedbackMessageCopyWithImpl(this._self, this._then);

  final _FeedbackMessage _self;
  final $Res Function(_FeedbackMessage) _then;

/// Create a copy of FeedbackMessage
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? sessionId = null,Object? studentIds = null,Object? message = null,Object? isPositive = null,Object? sentAt = freezed,}) {
  return _then(_FeedbackMessage(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,sessionId: null == sessionId ? _self.sessionId : sessionId // ignore: cast_nullable_to_non_nullable
as String,studentIds: null == studentIds ? _self._studentIds : studentIds // ignore: cast_nullable_to_non_nullable
as List<String>,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,isPositive: null == isPositive ? _self.isPositive : isPositive // ignore: cast_nullable_to_non_nullable
as bool,sentAt: freezed == sentAt ? _self.sentAt : sentAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$AssignmentReview {

 String get id; String get sessionId; String get homeworkId; String get studentId; int get marks; String get reviewText; DateTime? get reviewedAt;
/// Create a copy of AssignmentReview
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AssignmentReviewCopyWith<AssignmentReview> get copyWith => _$AssignmentReviewCopyWithImpl<AssignmentReview>(this as AssignmentReview, _$identity);

  /// Serializes this AssignmentReview to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AssignmentReview&&(identical(other.id, id) || other.id == id)&&(identical(other.sessionId, sessionId) || other.sessionId == sessionId)&&(identical(other.homeworkId, homeworkId) || other.homeworkId == homeworkId)&&(identical(other.studentId, studentId) || other.studentId == studentId)&&(identical(other.marks, marks) || other.marks == marks)&&(identical(other.reviewText, reviewText) || other.reviewText == reviewText)&&(identical(other.reviewedAt, reviewedAt) || other.reviewedAt == reviewedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,sessionId,homeworkId,studentId,marks,reviewText,reviewedAt);

@override
String toString() {
  return 'AssignmentReview(id: $id, sessionId: $sessionId, homeworkId: $homeworkId, studentId: $studentId, marks: $marks, reviewText: $reviewText, reviewedAt: $reviewedAt)';
}


}

/// @nodoc
abstract mixin class $AssignmentReviewCopyWith<$Res>  {
  factory $AssignmentReviewCopyWith(AssignmentReview value, $Res Function(AssignmentReview) _then) = _$AssignmentReviewCopyWithImpl;
@useResult
$Res call({
 String id, String sessionId, String homeworkId, String studentId, int marks, String reviewText, DateTime? reviewedAt
});




}
/// @nodoc
class _$AssignmentReviewCopyWithImpl<$Res>
    implements $AssignmentReviewCopyWith<$Res> {
  _$AssignmentReviewCopyWithImpl(this._self, this._then);

  final AssignmentReview _self;
  final $Res Function(AssignmentReview) _then;

/// Create a copy of AssignmentReview
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? sessionId = null,Object? homeworkId = null,Object? studentId = null,Object? marks = null,Object? reviewText = null,Object? reviewedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,sessionId: null == sessionId ? _self.sessionId : sessionId // ignore: cast_nullable_to_non_nullable
as String,homeworkId: null == homeworkId ? _self.homeworkId : homeworkId // ignore: cast_nullable_to_non_nullable
as String,studentId: null == studentId ? _self.studentId : studentId // ignore: cast_nullable_to_non_nullable
as String,marks: null == marks ? _self.marks : marks // ignore: cast_nullable_to_non_nullable
as int,reviewText: null == reviewText ? _self.reviewText : reviewText // ignore: cast_nullable_to_non_nullable
as String,reviewedAt: freezed == reviewedAt ? _self.reviewedAt : reviewedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [AssignmentReview].
extension AssignmentReviewPatterns on AssignmentReview {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AssignmentReview value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AssignmentReview() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AssignmentReview value)  $default,){
final _that = this;
switch (_that) {
case _AssignmentReview():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AssignmentReview value)?  $default,){
final _that = this;
switch (_that) {
case _AssignmentReview() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String sessionId,  String homeworkId,  String studentId,  int marks,  String reviewText,  DateTime? reviewedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AssignmentReview() when $default != null:
return $default(_that.id,_that.sessionId,_that.homeworkId,_that.studentId,_that.marks,_that.reviewText,_that.reviewedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String sessionId,  String homeworkId,  String studentId,  int marks,  String reviewText,  DateTime? reviewedAt)  $default,) {final _that = this;
switch (_that) {
case _AssignmentReview():
return $default(_that.id,_that.sessionId,_that.homeworkId,_that.studentId,_that.marks,_that.reviewText,_that.reviewedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String sessionId,  String homeworkId,  String studentId,  int marks,  String reviewText,  DateTime? reviewedAt)?  $default,) {final _that = this;
switch (_that) {
case _AssignmentReview() when $default != null:
return $default(_that.id,_that.sessionId,_that.homeworkId,_that.studentId,_that.marks,_that.reviewText,_that.reviewedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AssignmentReview implements AssignmentReview {
  const _AssignmentReview({required this.id, required this.sessionId, required this.homeworkId, required this.studentId, required this.marks, required this.reviewText, this.reviewedAt});
  factory _AssignmentReview.fromJson(Map<String, dynamic> json) => _$AssignmentReviewFromJson(json);

@override final  String id;
@override final  String sessionId;
@override final  String homeworkId;
@override final  String studentId;
@override final  int marks;
@override final  String reviewText;
@override final  DateTime? reviewedAt;

/// Create a copy of AssignmentReview
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AssignmentReviewCopyWith<_AssignmentReview> get copyWith => __$AssignmentReviewCopyWithImpl<_AssignmentReview>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AssignmentReviewToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AssignmentReview&&(identical(other.id, id) || other.id == id)&&(identical(other.sessionId, sessionId) || other.sessionId == sessionId)&&(identical(other.homeworkId, homeworkId) || other.homeworkId == homeworkId)&&(identical(other.studentId, studentId) || other.studentId == studentId)&&(identical(other.marks, marks) || other.marks == marks)&&(identical(other.reviewText, reviewText) || other.reviewText == reviewText)&&(identical(other.reviewedAt, reviewedAt) || other.reviewedAt == reviewedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,sessionId,homeworkId,studentId,marks,reviewText,reviewedAt);

@override
String toString() {
  return 'AssignmentReview(id: $id, sessionId: $sessionId, homeworkId: $homeworkId, studentId: $studentId, marks: $marks, reviewText: $reviewText, reviewedAt: $reviewedAt)';
}


}

/// @nodoc
abstract mixin class _$AssignmentReviewCopyWith<$Res> implements $AssignmentReviewCopyWith<$Res> {
  factory _$AssignmentReviewCopyWith(_AssignmentReview value, $Res Function(_AssignmentReview) _then) = __$AssignmentReviewCopyWithImpl;
@override @useResult
$Res call({
 String id, String sessionId, String homeworkId, String studentId, int marks, String reviewText, DateTime? reviewedAt
});




}
/// @nodoc
class __$AssignmentReviewCopyWithImpl<$Res>
    implements _$AssignmentReviewCopyWith<$Res> {
  __$AssignmentReviewCopyWithImpl(this._self, this._then);

  final _AssignmentReview _self;
  final $Res Function(_AssignmentReview) _then;

/// Create a copy of AssignmentReview
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? sessionId = null,Object? homeworkId = null,Object? studentId = null,Object? marks = null,Object? reviewText = null,Object? reviewedAt = freezed,}) {
  return _then(_AssignmentReview(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,sessionId: null == sessionId ? _self.sessionId : sessionId // ignore: cast_nullable_to_non_nullable
as String,homeworkId: null == homeworkId ? _self.homeworkId : homeworkId // ignore: cast_nullable_to_non_nullable
as String,studentId: null == studentId ? _self.studentId : studentId // ignore: cast_nullable_to_non_nullable
as String,marks: null == marks ? _self.marks : marks // ignore: cast_nullable_to_non_nullable
as int,reviewText: null == reviewText ? _self.reviewText : reviewText // ignore: cast_nullable_to_non_nullable
as String,reviewedAt: freezed == reviewedAt ? _self.reviewedAt : reviewedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
