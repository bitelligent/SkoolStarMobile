// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'direct_chat_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$DirectChatState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DirectChatState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'DirectChatState()';
}


}

/// @nodoc
class $DirectChatStateCopyWith<$Res>  {
$DirectChatStateCopyWith(DirectChatState _, $Res Function(DirectChatState) __);
}


/// Adds pattern-matching-related methods to [DirectChatState].
extension DirectChatStatePatterns on DirectChatState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( DirectChatInitial value)?  initial,TResult Function( DirectChatLoading value)?  loading,TResult Function( DirectChatLoaded value)?  loaded,TResult Function( DirectChatError value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case DirectChatInitial() when initial != null:
return initial(_that);case DirectChatLoading() when loading != null:
return loading(_that);case DirectChatLoaded() when loaded != null:
return loaded(_that);case DirectChatError() when error != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( DirectChatInitial value)  initial,required TResult Function( DirectChatLoading value)  loading,required TResult Function( DirectChatLoaded value)  loaded,required TResult Function( DirectChatError value)  error,}){
final _that = this;
switch (_that) {
case DirectChatInitial():
return initial(_that);case DirectChatLoading():
return loading(_that);case DirectChatLoaded():
return loaded(_that);case DirectChatError():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( DirectChatInitial value)?  initial,TResult? Function( DirectChatLoading value)?  loading,TResult? Function( DirectChatLoaded value)?  loaded,TResult? Function( DirectChatError value)?  error,}){
final _that = this;
switch (_that) {
case DirectChatInitial() when initial != null:
return initial(_that);case DirectChatLoading() when loading != null:
return loading(_that);case DirectChatLoaded() when loaded != null:
return loaded(_that);case DirectChatError() when error != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initial,TResult Function()?  loading,TResult Function( ChatThread thread,  List<DirectMessage> messages,  bool isSending)?  loaded,TResult Function( String message)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case DirectChatInitial() when initial != null:
return initial();case DirectChatLoading() when loading != null:
return loading();case DirectChatLoaded() when loaded != null:
return loaded(_that.thread,_that.messages,_that.isSending);case DirectChatError() when error != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initial,required TResult Function()  loading,required TResult Function( ChatThread thread,  List<DirectMessage> messages,  bool isSending)  loaded,required TResult Function( String message)  error,}) {final _that = this;
switch (_that) {
case DirectChatInitial():
return initial();case DirectChatLoading():
return loading();case DirectChatLoaded():
return loaded(_that.thread,_that.messages,_that.isSending);case DirectChatError():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initial,TResult? Function()?  loading,TResult? Function( ChatThread thread,  List<DirectMessage> messages,  bool isSending)?  loaded,TResult? Function( String message)?  error,}) {final _that = this;
switch (_that) {
case DirectChatInitial() when initial != null:
return initial();case DirectChatLoading() when loading != null:
return loading();case DirectChatLoaded() when loaded != null:
return loaded(_that.thread,_that.messages,_that.isSending);case DirectChatError() when error != null:
return error(_that.message);case _:
  return null;

}
}

}

/// @nodoc


class DirectChatInitial implements DirectChatState {
  const DirectChatInitial();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DirectChatInitial);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'DirectChatState.initial()';
}


}




/// @nodoc


class DirectChatLoading implements DirectChatState {
  const DirectChatLoading();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DirectChatLoading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'DirectChatState.loading()';
}


}




/// @nodoc


class DirectChatLoaded implements DirectChatState {
  const DirectChatLoaded({required this.thread, required final  List<DirectMessage> messages, this.isSending = false}): _messages = messages;
  

 final  ChatThread thread;
 final  List<DirectMessage> _messages;
 List<DirectMessage> get messages {
  if (_messages is EqualUnmodifiableListView) return _messages;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_messages);
}

@JsonKey() final  bool isSending;

/// Create a copy of DirectChatState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DirectChatLoadedCopyWith<DirectChatLoaded> get copyWith => _$DirectChatLoadedCopyWithImpl<DirectChatLoaded>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DirectChatLoaded&&(identical(other.thread, thread) || other.thread == thread)&&const DeepCollectionEquality().equals(other._messages, _messages)&&(identical(other.isSending, isSending) || other.isSending == isSending));
}


@override
int get hashCode => Object.hash(runtimeType,thread,const DeepCollectionEquality().hash(_messages),isSending);

@override
String toString() {
  return 'DirectChatState.loaded(thread: $thread, messages: $messages, isSending: $isSending)';
}


}

/// @nodoc
abstract mixin class $DirectChatLoadedCopyWith<$Res> implements $DirectChatStateCopyWith<$Res> {
  factory $DirectChatLoadedCopyWith(DirectChatLoaded value, $Res Function(DirectChatLoaded) _then) = _$DirectChatLoadedCopyWithImpl;
@useResult
$Res call({
 ChatThread thread, List<DirectMessage> messages, bool isSending
});


$ChatThreadCopyWith<$Res> get thread;

}
/// @nodoc
class _$DirectChatLoadedCopyWithImpl<$Res>
    implements $DirectChatLoadedCopyWith<$Res> {
  _$DirectChatLoadedCopyWithImpl(this._self, this._then);

  final DirectChatLoaded _self;
  final $Res Function(DirectChatLoaded) _then;

/// Create a copy of DirectChatState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? thread = null,Object? messages = null,Object? isSending = null,}) {
  return _then(DirectChatLoaded(
thread: null == thread ? _self.thread : thread // ignore: cast_nullable_to_non_nullable
as ChatThread,messages: null == messages ? _self._messages : messages // ignore: cast_nullable_to_non_nullable
as List<DirectMessage>,isSending: null == isSending ? _self.isSending : isSending // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of DirectChatState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ChatThreadCopyWith<$Res> get thread {
  
  return $ChatThreadCopyWith<$Res>(_self.thread, (value) {
    return _then(_self.copyWith(thread: value));
  });
}
}

/// @nodoc


class DirectChatError implements DirectChatState {
  const DirectChatError(this.message);
  

 final  String message;

/// Create a copy of DirectChatState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DirectChatErrorCopyWith<DirectChatError> get copyWith => _$DirectChatErrorCopyWithImpl<DirectChatError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DirectChatError&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'DirectChatState.error(message: $message)';
}


}

/// @nodoc
abstract mixin class $DirectChatErrorCopyWith<$Res> implements $DirectChatStateCopyWith<$Res> {
  factory $DirectChatErrorCopyWith(DirectChatError value, $Res Function(DirectChatError) _then) = _$DirectChatErrorCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class _$DirectChatErrorCopyWithImpl<$Res>
    implements $DirectChatErrorCopyWith<$Res> {
  _$DirectChatErrorCopyWithImpl(this._self, this._then);

  final DirectChatError _self;
  final $Res Function(DirectChatError) _then;

/// Create a copy of DirectChatState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(DirectChatError(
null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
