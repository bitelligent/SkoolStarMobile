// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'feedback_chat_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$FeedbackChatState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FeedbackChatState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'FeedbackChatState()';
}


}

/// @nodoc
class $FeedbackChatStateCopyWith<$Res>  {
$FeedbackChatStateCopyWith(FeedbackChatState _, $Res Function(FeedbackChatState) __);
}


/// Adds pattern-matching-related methods to [FeedbackChatState].
extension FeedbackChatStatePatterns on FeedbackChatState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( FeedbackChatInitial value)?  initial,TResult Function( FeedbackChatLoading value)?  loading,TResult Function( FeedbackChatLoaded value)?  loaded,TResult Function( FeedbackChatError value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case FeedbackChatInitial() when initial != null:
return initial(_that);case FeedbackChatLoading() when loading != null:
return loading(_that);case FeedbackChatLoaded() when loaded != null:
return loaded(_that);case FeedbackChatError() when error != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( FeedbackChatInitial value)  initial,required TResult Function( FeedbackChatLoading value)  loading,required TResult Function( FeedbackChatLoaded value)  loaded,required TResult Function( FeedbackChatError value)  error,}){
final _that = this;
switch (_that) {
case FeedbackChatInitial():
return initial(_that);case FeedbackChatLoading():
return loading(_that);case FeedbackChatLoaded():
return loaded(_that);case FeedbackChatError():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( FeedbackChatInitial value)?  initial,TResult? Function( FeedbackChatLoading value)?  loading,TResult? Function( FeedbackChatLoaded value)?  loaded,TResult? Function( FeedbackChatError value)?  error,}){
final _that = this;
switch (_that) {
case FeedbackChatInitial() when initial != null:
return initial(_that);case FeedbackChatLoading() when loading != null:
return loading(_that);case FeedbackChatLoaded() when loaded != null:
return loaded(_that);case FeedbackChatError() when error != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initial,TResult Function()?  loading,TResult Function( ChatThread thread,  List<FeedbackTopic> topics,  Set<String> expandedTopicIds,  String? sendingReplyTopicId,  bool creatingTopic)?  loaded,TResult Function( String message)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case FeedbackChatInitial() when initial != null:
return initial();case FeedbackChatLoading() when loading != null:
return loading();case FeedbackChatLoaded() when loaded != null:
return loaded(_that.thread,_that.topics,_that.expandedTopicIds,_that.sendingReplyTopicId,_that.creatingTopic);case FeedbackChatError() when error != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initial,required TResult Function()  loading,required TResult Function( ChatThread thread,  List<FeedbackTopic> topics,  Set<String> expandedTopicIds,  String? sendingReplyTopicId,  bool creatingTopic)  loaded,required TResult Function( String message)  error,}) {final _that = this;
switch (_that) {
case FeedbackChatInitial():
return initial();case FeedbackChatLoading():
return loading();case FeedbackChatLoaded():
return loaded(_that.thread,_that.topics,_that.expandedTopicIds,_that.sendingReplyTopicId,_that.creatingTopic);case FeedbackChatError():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initial,TResult? Function()?  loading,TResult? Function( ChatThread thread,  List<FeedbackTopic> topics,  Set<String> expandedTopicIds,  String? sendingReplyTopicId,  bool creatingTopic)?  loaded,TResult? Function( String message)?  error,}) {final _that = this;
switch (_that) {
case FeedbackChatInitial() when initial != null:
return initial();case FeedbackChatLoading() when loading != null:
return loading();case FeedbackChatLoaded() when loaded != null:
return loaded(_that.thread,_that.topics,_that.expandedTopicIds,_that.sendingReplyTopicId,_that.creatingTopic);case FeedbackChatError() when error != null:
return error(_that.message);case _:
  return null;

}
}

}

/// @nodoc


class FeedbackChatInitial implements FeedbackChatState {
  const FeedbackChatInitial();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FeedbackChatInitial);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'FeedbackChatState.initial()';
}


}




/// @nodoc


class FeedbackChatLoading implements FeedbackChatState {
  const FeedbackChatLoading();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FeedbackChatLoading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'FeedbackChatState.loading()';
}


}




/// @nodoc


class FeedbackChatLoaded implements FeedbackChatState {
  const FeedbackChatLoaded({required this.thread, required final  List<FeedbackTopic> topics, final  Set<String> expandedTopicIds = const <String>{}, this.sendingReplyTopicId, this.creatingTopic = false}): _topics = topics,_expandedTopicIds = expandedTopicIds;
  

 final  ChatThread thread;
 final  List<FeedbackTopic> _topics;
 List<FeedbackTopic> get topics {
  if (_topics is EqualUnmodifiableListView) return _topics;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_topics);
}

/// Which topic cards are currently expanded. Kept here (not inside
/// each tile's own state) so expansion survives list rebuilds when
/// a reply/new-topic edit lands.
 final  Set<String> _expandedTopicIds;
/// Which topic cards are currently expanded. Kept here (not inside
/// each tile's own state) so expansion survives list rebuilds when
/// a reply/new-topic edit lands.
@JsonKey() Set<String> get expandedTopicIds {
  if (_expandedTopicIds is EqualUnmodifiableSetView) return _expandedTopicIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_expandedTopicIds);
}

/// Topic currently waiting on a server reply — disables its composer
/// so the user can't double-submit.
 final  String? sendingReplyTopicId;
/// True while a new feedback topic is being created from the sheet.
@JsonKey() final  bool creatingTopic;

/// Create a copy of FeedbackChatState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FeedbackChatLoadedCopyWith<FeedbackChatLoaded> get copyWith => _$FeedbackChatLoadedCopyWithImpl<FeedbackChatLoaded>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FeedbackChatLoaded&&(identical(other.thread, thread) || other.thread == thread)&&const DeepCollectionEquality().equals(other._topics, _topics)&&const DeepCollectionEquality().equals(other._expandedTopicIds, _expandedTopicIds)&&(identical(other.sendingReplyTopicId, sendingReplyTopicId) || other.sendingReplyTopicId == sendingReplyTopicId)&&(identical(other.creatingTopic, creatingTopic) || other.creatingTopic == creatingTopic));
}


@override
int get hashCode => Object.hash(runtimeType,thread,const DeepCollectionEquality().hash(_topics),const DeepCollectionEquality().hash(_expandedTopicIds),sendingReplyTopicId,creatingTopic);

@override
String toString() {
  return 'FeedbackChatState.loaded(thread: $thread, topics: $topics, expandedTopicIds: $expandedTopicIds, sendingReplyTopicId: $sendingReplyTopicId, creatingTopic: $creatingTopic)';
}


}

/// @nodoc
abstract mixin class $FeedbackChatLoadedCopyWith<$Res> implements $FeedbackChatStateCopyWith<$Res> {
  factory $FeedbackChatLoadedCopyWith(FeedbackChatLoaded value, $Res Function(FeedbackChatLoaded) _then) = _$FeedbackChatLoadedCopyWithImpl;
@useResult
$Res call({
 ChatThread thread, List<FeedbackTopic> topics, Set<String> expandedTopicIds, String? sendingReplyTopicId, bool creatingTopic
});


$ChatThreadCopyWith<$Res> get thread;

}
/// @nodoc
class _$FeedbackChatLoadedCopyWithImpl<$Res>
    implements $FeedbackChatLoadedCopyWith<$Res> {
  _$FeedbackChatLoadedCopyWithImpl(this._self, this._then);

  final FeedbackChatLoaded _self;
  final $Res Function(FeedbackChatLoaded) _then;

/// Create a copy of FeedbackChatState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? thread = null,Object? topics = null,Object? expandedTopicIds = null,Object? sendingReplyTopicId = freezed,Object? creatingTopic = null,}) {
  return _then(FeedbackChatLoaded(
thread: null == thread ? _self.thread : thread // ignore: cast_nullable_to_non_nullable
as ChatThread,topics: null == topics ? _self._topics : topics // ignore: cast_nullable_to_non_nullable
as List<FeedbackTopic>,expandedTopicIds: null == expandedTopicIds ? _self._expandedTopicIds : expandedTopicIds // ignore: cast_nullable_to_non_nullable
as Set<String>,sendingReplyTopicId: freezed == sendingReplyTopicId ? _self.sendingReplyTopicId : sendingReplyTopicId // ignore: cast_nullable_to_non_nullable
as String?,creatingTopic: null == creatingTopic ? _self.creatingTopic : creatingTopic // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of FeedbackChatState
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


class FeedbackChatError implements FeedbackChatState {
  const FeedbackChatError(this.message);
  

 final  String message;

/// Create a copy of FeedbackChatState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FeedbackChatErrorCopyWith<FeedbackChatError> get copyWith => _$FeedbackChatErrorCopyWithImpl<FeedbackChatError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FeedbackChatError&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'FeedbackChatState.error(message: $message)';
}


}

/// @nodoc
abstract mixin class $FeedbackChatErrorCopyWith<$Res> implements $FeedbackChatStateCopyWith<$Res> {
  factory $FeedbackChatErrorCopyWith(FeedbackChatError value, $Res Function(FeedbackChatError) _then) = _$FeedbackChatErrorCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class _$FeedbackChatErrorCopyWithImpl<$Res>
    implements $FeedbackChatErrorCopyWith<$Res> {
  _$FeedbackChatErrorCopyWithImpl(this._self, this._then);

  final FeedbackChatError _self;
  final $Res Function(FeedbackChatError) _then;

/// Create a copy of FeedbackChatState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(FeedbackChatError(
null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
