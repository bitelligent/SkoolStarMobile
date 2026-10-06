// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chat_thread.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ChatThread {

 String get id; String get name; ChatCategory get category; DateTime get lastMessageAt; String get avatarUrl; String get role; String get lastMessage; int get unreadCount; bool get isOnline; bool get isPinned; bool get isTyping; bool get outgoingLast;
/// Create a copy of ChatThread
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChatThreadCopyWith<ChatThread> get copyWith => _$ChatThreadCopyWithImpl<ChatThread>(this as ChatThread, _$identity);

  /// Serializes this ChatThread to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChatThread&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.category, category) || other.category == category)&&(identical(other.lastMessageAt, lastMessageAt) || other.lastMessageAt == lastMessageAt)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.role, role) || other.role == role)&&(identical(other.lastMessage, lastMessage) || other.lastMessage == lastMessage)&&(identical(other.unreadCount, unreadCount) || other.unreadCount == unreadCount)&&(identical(other.isOnline, isOnline) || other.isOnline == isOnline)&&(identical(other.isPinned, isPinned) || other.isPinned == isPinned)&&(identical(other.isTyping, isTyping) || other.isTyping == isTyping)&&(identical(other.outgoingLast, outgoingLast) || other.outgoingLast == outgoingLast));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,category,lastMessageAt,avatarUrl,role,lastMessage,unreadCount,isOnline,isPinned,isTyping,outgoingLast);

@override
String toString() {
  return 'ChatThread(id: $id, name: $name, category: $category, lastMessageAt: $lastMessageAt, avatarUrl: $avatarUrl, role: $role, lastMessage: $lastMessage, unreadCount: $unreadCount, isOnline: $isOnline, isPinned: $isPinned, isTyping: $isTyping, outgoingLast: $outgoingLast)';
}


}

/// @nodoc
abstract mixin class $ChatThreadCopyWith<$Res>  {
  factory $ChatThreadCopyWith(ChatThread value, $Res Function(ChatThread) _then) = _$ChatThreadCopyWithImpl;
@useResult
$Res call({
 String id, String name, ChatCategory category, DateTime lastMessageAt, String avatarUrl, String role, String lastMessage, int unreadCount, bool isOnline, bool isPinned, bool isTyping, bool outgoingLast
});




}
/// @nodoc
class _$ChatThreadCopyWithImpl<$Res>
    implements $ChatThreadCopyWith<$Res> {
  _$ChatThreadCopyWithImpl(this._self, this._then);

  final ChatThread _self;
  final $Res Function(ChatThread) _then;

/// Create a copy of ChatThread
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? category = null,Object? lastMessageAt = null,Object? avatarUrl = null,Object? role = null,Object? lastMessage = null,Object? unreadCount = null,Object? isOnline = null,Object? isPinned = null,Object? isTyping = null,Object? outgoingLast = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as ChatCategory,lastMessageAt: null == lastMessageAt ? _self.lastMessageAt : lastMessageAt // ignore: cast_nullable_to_non_nullable
as DateTime,avatarUrl: null == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String,lastMessage: null == lastMessage ? _self.lastMessage : lastMessage // ignore: cast_nullable_to_non_nullable
as String,unreadCount: null == unreadCount ? _self.unreadCount : unreadCount // ignore: cast_nullable_to_non_nullable
as int,isOnline: null == isOnline ? _self.isOnline : isOnline // ignore: cast_nullable_to_non_nullable
as bool,isPinned: null == isPinned ? _self.isPinned : isPinned // ignore: cast_nullable_to_non_nullable
as bool,isTyping: null == isTyping ? _self.isTyping : isTyping // ignore: cast_nullable_to_non_nullable
as bool,outgoingLast: null == outgoingLast ? _self.outgoingLast : outgoingLast // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [ChatThread].
extension ChatThreadPatterns on ChatThread {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChatThread value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChatThread() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChatThread value)  $default,){
final _that = this;
switch (_that) {
case _ChatThread():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChatThread value)?  $default,){
final _that = this;
switch (_that) {
case _ChatThread() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  ChatCategory category,  DateTime lastMessageAt,  String avatarUrl,  String role,  String lastMessage,  int unreadCount,  bool isOnline,  bool isPinned,  bool isTyping,  bool outgoingLast)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChatThread() when $default != null:
return $default(_that.id,_that.name,_that.category,_that.lastMessageAt,_that.avatarUrl,_that.role,_that.lastMessage,_that.unreadCount,_that.isOnline,_that.isPinned,_that.isTyping,_that.outgoingLast);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  ChatCategory category,  DateTime lastMessageAt,  String avatarUrl,  String role,  String lastMessage,  int unreadCount,  bool isOnline,  bool isPinned,  bool isTyping,  bool outgoingLast)  $default,) {final _that = this;
switch (_that) {
case _ChatThread():
return $default(_that.id,_that.name,_that.category,_that.lastMessageAt,_that.avatarUrl,_that.role,_that.lastMessage,_that.unreadCount,_that.isOnline,_that.isPinned,_that.isTyping,_that.outgoingLast);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  ChatCategory category,  DateTime lastMessageAt,  String avatarUrl,  String role,  String lastMessage,  int unreadCount,  bool isOnline,  bool isPinned,  bool isTyping,  bool outgoingLast)?  $default,) {final _that = this;
switch (_that) {
case _ChatThread() when $default != null:
return $default(_that.id,_that.name,_that.category,_that.lastMessageAt,_that.avatarUrl,_that.role,_that.lastMessage,_that.unreadCount,_that.isOnline,_that.isPinned,_that.isTyping,_that.outgoingLast);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ChatThread implements ChatThread {
  const _ChatThread({required this.id, required this.name, required this.category, required this.lastMessageAt, this.avatarUrl = '', this.role = '', this.lastMessage = '', this.unreadCount = 0, this.isOnline = false, this.isPinned = false, this.isTyping = false, this.outgoingLast = false});
  factory _ChatThread.fromJson(Map<String, dynamic> json) => _$ChatThreadFromJson(json);

@override final  String id;
@override final  String name;
@override final  ChatCategory category;
@override final  DateTime lastMessageAt;
@override@JsonKey() final  String avatarUrl;
@override@JsonKey() final  String role;
@override@JsonKey() final  String lastMessage;
@override@JsonKey() final  int unreadCount;
@override@JsonKey() final  bool isOnline;
@override@JsonKey() final  bool isPinned;
@override@JsonKey() final  bool isTyping;
@override@JsonKey() final  bool outgoingLast;

/// Create a copy of ChatThread
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChatThreadCopyWith<_ChatThread> get copyWith => __$ChatThreadCopyWithImpl<_ChatThread>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ChatThreadToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChatThread&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.category, category) || other.category == category)&&(identical(other.lastMessageAt, lastMessageAt) || other.lastMessageAt == lastMessageAt)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.role, role) || other.role == role)&&(identical(other.lastMessage, lastMessage) || other.lastMessage == lastMessage)&&(identical(other.unreadCount, unreadCount) || other.unreadCount == unreadCount)&&(identical(other.isOnline, isOnline) || other.isOnline == isOnline)&&(identical(other.isPinned, isPinned) || other.isPinned == isPinned)&&(identical(other.isTyping, isTyping) || other.isTyping == isTyping)&&(identical(other.outgoingLast, outgoingLast) || other.outgoingLast == outgoingLast));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,category,lastMessageAt,avatarUrl,role,lastMessage,unreadCount,isOnline,isPinned,isTyping,outgoingLast);

@override
String toString() {
  return 'ChatThread(id: $id, name: $name, category: $category, lastMessageAt: $lastMessageAt, avatarUrl: $avatarUrl, role: $role, lastMessage: $lastMessage, unreadCount: $unreadCount, isOnline: $isOnline, isPinned: $isPinned, isTyping: $isTyping, outgoingLast: $outgoingLast)';
}


}

/// @nodoc
abstract mixin class _$ChatThreadCopyWith<$Res> implements $ChatThreadCopyWith<$Res> {
  factory _$ChatThreadCopyWith(_ChatThread value, $Res Function(_ChatThread) _then) = __$ChatThreadCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, ChatCategory category, DateTime lastMessageAt, String avatarUrl, String role, String lastMessage, int unreadCount, bool isOnline, bool isPinned, bool isTyping, bool outgoingLast
});




}
/// @nodoc
class __$ChatThreadCopyWithImpl<$Res>
    implements _$ChatThreadCopyWith<$Res> {
  __$ChatThreadCopyWithImpl(this._self, this._then);

  final _ChatThread _self;
  final $Res Function(_ChatThread) _then;

/// Create a copy of ChatThread
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? category = null,Object? lastMessageAt = null,Object? avatarUrl = null,Object? role = null,Object? lastMessage = null,Object? unreadCount = null,Object? isOnline = null,Object? isPinned = null,Object? isTyping = null,Object? outgoingLast = null,}) {
  return _then(_ChatThread(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as ChatCategory,lastMessageAt: null == lastMessageAt ? _self.lastMessageAt : lastMessageAt // ignore: cast_nullable_to_non_nullable
as DateTime,avatarUrl: null == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String,lastMessage: null == lastMessage ? _self.lastMessage : lastMessage // ignore: cast_nullable_to_non_nullable
as String,unreadCount: null == unreadCount ? _self.unreadCount : unreadCount // ignore: cast_nullable_to_non_nullable
as int,isOnline: null == isOnline ? _self.isOnline : isOnline // ignore: cast_nullable_to_non_nullable
as bool,isPinned: null == isPinned ? _self.isPinned : isPinned // ignore: cast_nullable_to_non_nullable
as bool,isTyping: null == isTyping ? _self.isTyping : isTyping // ignore: cast_nullable_to_non_nullable
as bool,outgoingLast: null == outgoingLast ? _self.outgoingLast : outgoingLast // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
