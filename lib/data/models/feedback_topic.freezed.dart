// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'feedback_topic.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$FeedbackMessage {

 String get id; bool get fromTeacher; String get content; DateTime get sentAt; bool get isRead;
/// Create a copy of FeedbackMessage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FeedbackMessageCopyWith<FeedbackMessage> get copyWith => _$FeedbackMessageCopyWithImpl<FeedbackMessage>(this as FeedbackMessage, _$identity);

  /// Serializes this FeedbackMessage to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FeedbackMessage&&(identical(other.id, id) || other.id == id)&&(identical(other.fromTeacher, fromTeacher) || other.fromTeacher == fromTeacher)&&(identical(other.content, content) || other.content == content)&&(identical(other.sentAt, sentAt) || other.sentAt == sentAt)&&(identical(other.isRead, isRead) || other.isRead == isRead));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,fromTeacher,content,sentAt,isRead);

@override
String toString() {
  return 'FeedbackMessage(id: $id, fromTeacher: $fromTeacher, content: $content, sentAt: $sentAt, isRead: $isRead)';
}


}

/// @nodoc
abstract mixin class $FeedbackMessageCopyWith<$Res>  {
  factory $FeedbackMessageCopyWith(FeedbackMessage value, $Res Function(FeedbackMessage) _then) = _$FeedbackMessageCopyWithImpl;
@useResult
$Res call({
 String id, bool fromTeacher, String content, DateTime sentAt, bool isRead
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
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? fromTeacher = null,Object? content = null,Object? sentAt = null,Object? isRead = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,fromTeacher: null == fromTeacher ? _self.fromTeacher : fromTeacher // ignore: cast_nullable_to_non_nullable
as bool,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,sentAt: null == sentAt ? _self.sentAt : sentAt // ignore: cast_nullable_to_non_nullable
as DateTime,isRead: null == isRead ? _self.isRead : isRead // ignore: cast_nullable_to_non_nullable
as bool,
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  bool fromTeacher,  String content,  DateTime sentAt,  bool isRead)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FeedbackMessage() when $default != null:
return $default(_that.id,_that.fromTeacher,_that.content,_that.sentAt,_that.isRead);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  bool fromTeacher,  String content,  DateTime sentAt,  bool isRead)  $default,) {final _that = this;
switch (_that) {
case _FeedbackMessage():
return $default(_that.id,_that.fromTeacher,_that.content,_that.sentAt,_that.isRead);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  bool fromTeacher,  String content,  DateTime sentAt,  bool isRead)?  $default,) {final _that = this;
switch (_that) {
case _FeedbackMessage() when $default != null:
return $default(_that.id,_that.fromTeacher,_that.content,_that.sentAt,_that.isRead);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FeedbackMessage implements FeedbackMessage {
  const _FeedbackMessage({required this.id, required this.fromTeacher, required this.content, required this.sentAt, this.isRead = true});
  factory _FeedbackMessage.fromJson(Map<String, dynamic> json) => _$FeedbackMessageFromJson(json);

@override final  String id;
@override final  bool fromTeacher;
@override final  String content;
@override final  DateTime sentAt;
@override@JsonKey() final  bool isRead;

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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FeedbackMessage&&(identical(other.id, id) || other.id == id)&&(identical(other.fromTeacher, fromTeacher) || other.fromTeacher == fromTeacher)&&(identical(other.content, content) || other.content == content)&&(identical(other.sentAt, sentAt) || other.sentAt == sentAt)&&(identical(other.isRead, isRead) || other.isRead == isRead));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,fromTeacher,content,sentAt,isRead);

@override
String toString() {
  return 'FeedbackMessage(id: $id, fromTeacher: $fromTeacher, content: $content, sentAt: $sentAt, isRead: $isRead)';
}


}

/// @nodoc
abstract mixin class _$FeedbackMessageCopyWith<$Res> implements $FeedbackMessageCopyWith<$Res> {
  factory _$FeedbackMessageCopyWith(_FeedbackMessage value, $Res Function(_FeedbackMessage) _then) = __$FeedbackMessageCopyWithImpl;
@override @useResult
$Res call({
 String id, bool fromTeacher, String content, DateTime sentAt, bool isRead
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
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? fromTeacher = null,Object? content = null,Object? sentAt = null,Object? isRead = null,}) {
  return _then(_FeedbackMessage(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,fromTeacher: null == fromTeacher ? _self.fromTeacher : fromTeacher // ignore: cast_nullable_to_non_nullable
as bool,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,sentAt: null == sentAt ? _self.sentAt : sentAt // ignore: cast_nullable_to_non_nullable
as DateTime,isRead: null == isRead ? _self.isRead : isRead // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$FeedbackTopic {

 String get id; String get threadId; String get subject; FeedbackTone get tone; DateTime get createdAt; List<FeedbackMessage> get messages; bool get isResolved;
/// Create a copy of FeedbackTopic
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FeedbackTopicCopyWith<FeedbackTopic> get copyWith => _$FeedbackTopicCopyWithImpl<FeedbackTopic>(this as FeedbackTopic, _$identity);

  /// Serializes this FeedbackTopic to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FeedbackTopic&&(identical(other.id, id) || other.id == id)&&(identical(other.threadId, threadId) || other.threadId == threadId)&&(identical(other.subject, subject) || other.subject == subject)&&(identical(other.tone, tone) || other.tone == tone)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&const DeepCollectionEquality().equals(other.messages, messages)&&(identical(other.isResolved, isResolved) || other.isResolved == isResolved));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,threadId,subject,tone,createdAt,const DeepCollectionEquality().hash(messages),isResolved);

@override
String toString() {
  return 'FeedbackTopic(id: $id, threadId: $threadId, subject: $subject, tone: $tone, createdAt: $createdAt, messages: $messages, isResolved: $isResolved)';
}


}

/// @nodoc
abstract mixin class $FeedbackTopicCopyWith<$Res>  {
  factory $FeedbackTopicCopyWith(FeedbackTopic value, $Res Function(FeedbackTopic) _then) = _$FeedbackTopicCopyWithImpl;
@useResult
$Res call({
 String id, String threadId, String subject, FeedbackTone tone, DateTime createdAt, List<FeedbackMessage> messages, bool isResolved
});




}
/// @nodoc
class _$FeedbackTopicCopyWithImpl<$Res>
    implements $FeedbackTopicCopyWith<$Res> {
  _$FeedbackTopicCopyWithImpl(this._self, this._then);

  final FeedbackTopic _self;
  final $Res Function(FeedbackTopic) _then;

/// Create a copy of FeedbackTopic
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? threadId = null,Object? subject = null,Object? tone = null,Object? createdAt = null,Object? messages = null,Object? isResolved = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,threadId: null == threadId ? _self.threadId : threadId // ignore: cast_nullable_to_non_nullable
as String,subject: null == subject ? _self.subject : subject // ignore: cast_nullable_to_non_nullable
as String,tone: null == tone ? _self.tone : tone // ignore: cast_nullable_to_non_nullable
as FeedbackTone,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,messages: null == messages ? _self.messages : messages // ignore: cast_nullable_to_non_nullable
as List<FeedbackMessage>,isResolved: null == isResolved ? _self.isResolved : isResolved // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [FeedbackTopic].
extension FeedbackTopicPatterns on FeedbackTopic {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FeedbackTopic value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FeedbackTopic() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FeedbackTopic value)  $default,){
final _that = this;
switch (_that) {
case _FeedbackTopic():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FeedbackTopic value)?  $default,){
final _that = this;
switch (_that) {
case _FeedbackTopic() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String threadId,  String subject,  FeedbackTone tone,  DateTime createdAt,  List<FeedbackMessage> messages,  bool isResolved)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FeedbackTopic() when $default != null:
return $default(_that.id,_that.threadId,_that.subject,_that.tone,_that.createdAt,_that.messages,_that.isResolved);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String threadId,  String subject,  FeedbackTone tone,  DateTime createdAt,  List<FeedbackMessage> messages,  bool isResolved)  $default,) {final _that = this;
switch (_that) {
case _FeedbackTopic():
return $default(_that.id,_that.threadId,_that.subject,_that.tone,_that.createdAt,_that.messages,_that.isResolved);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String threadId,  String subject,  FeedbackTone tone,  DateTime createdAt,  List<FeedbackMessage> messages,  bool isResolved)?  $default,) {final _that = this;
switch (_that) {
case _FeedbackTopic() when $default != null:
return $default(_that.id,_that.threadId,_that.subject,_that.tone,_that.createdAt,_that.messages,_that.isResolved);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FeedbackTopic extends FeedbackTopic {
  const _FeedbackTopic({required this.id, required this.threadId, required this.subject, required this.tone, required this.createdAt, required final  List<FeedbackMessage> messages, this.isResolved = false}): _messages = messages,super._();
  factory _FeedbackTopic.fromJson(Map<String, dynamic> json) => _$FeedbackTopicFromJson(json);

@override final  String id;
@override final  String threadId;
@override final  String subject;
@override final  FeedbackTone tone;
@override final  DateTime createdAt;
 final  List<FeedbackMessage> _messages;
@override List<FeedbackMessage> get messages {
  if (_messages is EqualUnmodifiableListView) return _messages;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_messages);
}

@override@JsonKey() final  bool isResolved;

/// Create a copy of FeedbackTopic
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FeedbackTopicCopyWith<_FeedbackTopic> get copyWith => __$FeedbackTopicCopyWithImpl<_FeedbackTopic>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FeedbackTopicToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FeedbackTopic&&(identical(other.id, id) || other.id == id)&&(identical(other.threadId, threadId) || other.threadId == threadId)&&(identical(other.subject, subject) || other.subject == subject)&&(identical(other.tone, tone) || other.tone == tone)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&const DeepCollectionEquality().equals(other._messages, _messages)&&(identical(other.isResolved, isResolved) || other.isResolved == isResolved));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,threadId,subject,tone,createdAt,const DeepCollectionEquality().hash(_messages),isResolved);

@override
String toString() {
  return 'FeedbackTopic(id: $id, threadId: $threadId, subject: $subject, tone: $tone, createdAt: $createdAt, messages: $messages, isResolved: $isResolved)';
}


}

/// @nodoc
abstract mixin class _$FeedbackTopicCopyWith<$Res> implements $FeedbackTopicCopyWith<$Res> {
  factory _$FeedbackTopicCopyWith(_FeedbackTopic value, $Res Function(_FeedbackTopic) _then) = __$FeedbackTopicCopyWithImpl;
@override @useResult
$Res call({
 String id, String threadId, String subject, FeedbackTone tone, DateTime createdAt, List<FeedbackMessage> messages, bool isResolved
});




}
/// @nodoc
class __$FeedbackTopicCopyWithImpl<$Res>
    implements _$FeedbackTopicCopyWith<$Res> {
  __$FeedbackTopicCopyWithImpl(this._self, this._then);

  final _FeedbackTopic _self;
  final $Res Function(_FeedbackTopic) _then;

/// Create a copy of FeedbackTopic
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? threadId = null,Object? subject = null,Object? tone = null,Object? createdAt = null,Object? messages = null,Object? isResolved = null,}) {
  return _then(_FeedbackTopic(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,threadId: null == threadId ? _self.threadId : threadId // ignore: cast_nullable_to_non_nullable
as String,subject: null == subject ? _self.subject : subject // ignore: cast_nullable_to_non_nullable
as String,tone: null == tone ? _self.tone : tone // ignore: cast_nullable_to_non_nullable
as FeedbackTone,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,messages: null == messages ? _self._messages : messages // ignore: cast_nullable_to_non_nullable
as List<FeedbackMessage>,isResolved: null == isResolved ? _self.isResolved : isResolved // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
