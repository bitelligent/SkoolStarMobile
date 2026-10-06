// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'direct_message.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DirectMessage {

 String get id; String get threadId; bool get fromTeacher; String get content; DateTime get sentAt; bool get isRead;
/// Create a copy of DirectMessage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DirectMessageCopyWith<DirectMessage> get copyWith => _$DirectMessageCopyWithImpl<DirectMessage>(this as DirectMessage, _$identity);

  /// Serializes this DirectMessage to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DirectMessage&&(identical(other.id, id) || other.id == id)&&(identical(other.threadId, threadId) || other.threadId == threadId)&&(identical(other.fromTeacher, fromTeacher) || other.fromTeacher == fromTeacher)&&(identical(other.content, content) || other.content == content)&&(identical(other.sentAt, sentAt) || other.sentAt == sentAt)&&(identical(other.isRead, isRead) || other.isRead == isRead));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,threadId,fromTeacher,content,sentAt,isRead);

@override
String toString() {
  return 'DirectMessage(id: $id, threadId: $threadId, fromTeacher: $fromTeacher, content: $content, sentAt: $sentAt, isRead: $isRead)';
}


}

/// @nodoc
abstract mixin class $DirectMessageCopyWith<$Res>  {
  factory $DirectMessageCopyWith(DirectMessage value, $Res Function(DirectMessage) _then) = _$DirectMessageCopyWithImpl;
@useResult
$Res call({
 String id, String threadId, bool fromTeacher, String content, DateTime sentAt, bool isRead
});




}
/// @nodoc
class _$DirectMessageCopyWithImpl<$Res>
    implements $DirectMessageCopyWith<$Res> {
  _$DirectMessageCopyWithImpl(this._self, this._then);

  final DirectMessage _self;
  final $Res Function(DirectMessage) _then;

/// Create a copy of DirectMessage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? threadId = null,Object? fromTeacher = null,Object? content = null,Object? sentAt = null,Object? isRead = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,threadId: null == threadId ? _self.threadId : threadId // ignore: cast_nullable_to_non_nullable
as String,fromTeacher: null == fromTeacher ? _self.fromTeacher : fromTeacher // ignore: cast_nullable_to_non_nullable
as bool,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,sentAt: null == sentAt ? _self.sentAt : sentAt // ignore: cast_nullable_to_non_nullable
as DateTime,isRead: null == isRead ? _self.isRead : isRead // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [DirectMessage].
extension DirectMessagePatterns on DirectMessage {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DirectMessage value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DirectMessage() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DirectMessage value)  $default,){
final _that = this;
switch (_that) {
case _DirectMessage():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DirectMessage value)?  $default,){
final _that = this;
switch (_that) {
case _DirectMessage() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String threadId,  bool fromTeacher,  String content,  DateTime sentAt,  bool isRead)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DirectMessage() when $default != null:
return $default(_that.id,_that.threadId,_that.fromTeacher,_that.content,_that.sentAt,_that.isRead);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String threadId,  bool fromTeacher,  String content,  DateTime sentAt,  bool isRead)  $default,) {final _that = this;
switch (_that) {
case _DirectMessage():
return $default(_that.id,_that.threadId,_that.fromTeacher,_that.content,_that.sentAt,_that.isRead);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String threadId,  bool fromTeacher,  String content,  DateTime sentAt,  bool isRead)?  $default,) {final _that = this;
switch (_that) {
case _DirectMessage() when $default != null:
return $default(_that.id,_that.threadId,_that.fromTeacher,_that.content,_that.sentAt,_that.isRead);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DirectMessage implements DirectMessage {
  const _DirectMessage({required this.id, required this.threadId, required this.fromTeacher, required this.content, required this.sentAt, this.isRead = true});
  factory _DirectMessage.fromJson(Map<String, dynamic> json) => _$DirectMessageFromJson(json);

@override final  String id;
@override final  String threadId;
@override final  bool fromTeacher;
@override final  String content;
@override final  DateTime sentAt;
@override@JsonKey() final  bool isRead;

/// Create a copy of DirectMessage
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DirectMessageCopyWith<_DirectMessage> get copyWith => __$DirectMessageCopyWithImpl<_DirectMessage>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DirectMessageToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DirectMessage&&(identical(other.id, id) || other.id == id)&&(identical(other.threadId, threadId) || other.threadId == threadId)&&(identical(other.fromTeacher, fromTeacher) || other.fromTeacher == fromTeacher)&&(identical(other.content, content) || other.content == content)&&(identical(other.sentAt, sentAt) || other.sentAt == sentAt)&&(identical(other.isRead, isRead) || other.isRead == isRead));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,threadId,fromTeacher,content,sentAt,isRead);

@override
String toString() {
  return 'DirectMessage(id: $id, threadId: $threadId, fromTeacher: $fromTeacher, content: $content, sentAt: $sentAt, isRead: $isRead)';
}


}

/// @nodoc
abstract mixin class _$DirectMessageCopyWith<$Res> implements $DirectMessageCopyWith<$Res> {
  factory _$DirectMessageCopyWith(_DirectMessage value, $Res Function(_DirectMessage) _then) = __$DirectMessageCopyWithImpl;
@override @useResult
$Res call({
 String id, String threadId, bool fromTeacher, String content, DateTime sentAt, bool isRead
});




}
/// @nodoc
class __$DirectMessageCopyWithImpl<$Res>
    implements _$DirectMessageCopyWith<$Res> {
  __$DirectMessageCopyWithImpl(this._self, this._then);

  final _DirectMessage _self;
  final $Res Function(_DirectMessage) _then;

/// Create a copy of DirectMessage
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? threadId = null,Object? fromTeacher = null,Object? content = null,Object? sentAt = null,Object? isRead = null,}) {
  return _then(_DirectMessage(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,threadId: null == threadId ? _self.threadId : threadId // ignore: cast_nullable_to_non_nullable
as String,fromTeacher: null == fromTeacher ? _self.fromTeacher : fromTeacher // ignore: cast_nullable_to_non_nullable
as bool,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,sentAt: null == sentAt ? _self.sentAt : sentAt // ignore: cast_nullable_to_non_nullable
as DateTime,isRead: null == isRead ? _self.isRead : isRead // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
