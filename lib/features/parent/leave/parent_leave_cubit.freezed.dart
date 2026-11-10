// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'parent_leave_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ParentLeaveState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ParentLeaveState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ParentLeaveState()';
}


}

/// @nodoc
class $ParentLeaveStateCopyWith<$Res>  {
$ParentLeaveStateCopyWith(ParentLeaveState _, $Res Function(ParentLeaveState) __);
}


/// Adds pattern-matching-related methods to [ParentLeaveState].
extension ParentLeaveStatePatterns on ParentLeaveState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( ParentLeaveInitial value)?  initial,TResult Function( ParentLeaveLoading value)?  loading,TResult Function( ParentLeaveError value)?  error,TResult Function( ParentLeaveLoaded value)?  loaded,required TResult orElse(),}){
final _that = this;
switch (_that) {
case ParentLeaveInitial() when initial != null:
return initial(_that);case ParentLeaveLoading() when loading != null:
return loading(_that);case ParentLeaveError() when error != null:
return error(_that);case ParentLeaveLoaded() when loaded != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( ParentLeaveInitial value)  initial,required TResult Function( ParentLeaveLoading value)  loading,required TResult Function( ParentLeaveError value)  error,required TResult Function( ParentLeaveLoaded value)  loaded,}){
final _that = this;
switch (_that) {
case ParentLeaveInitial():
return initial(_that);case ParentLeaveLoading():
return loading(_that);case ParentLeaveError():
return error(_that);case ParentLeaveLoaded():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( ParentLeaveInitial value)?  initial,TResult? Function( ParentLeaveLoading value)?  loading,TResult? Function( ParentLeaveError value)?  error,TResult? Function( ParentLeaveLoaded value)?  loaded,}){
final _that = this;
switch (_that) {
case ParentLeaveInitial() when initial != null:
return initial(_that);case ParentLeaveLoading() when loading != null:
return loading(_that);case ParentLeaveError() when error != null:
return error(_that);case ParentLeaveLoaded() when loaded != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initial,TResult Function()?  loading,TResult Function( String message)?  error,TResult Function( Child child,  List<LeaveRequest> items,  LeaveStatus? filter,  bool hasMore,  bool loadingMore,  Set<String> cancelling)?  loaded,required TResult orElse(),}) {final _that = this;
switch (_that) {
case ParentLeaveInitial() when initial != null:
return initial();case ParentLeaveLoading() when loading != null:
return loading();case ParentLeaveError() when error != null:
return error(_that.message);case ParentLeaveLoaded() when loaded != null:
return loaded(_that.child,_that.items,_that.filter,_that.hasMore,_that.loadingMore,_that.cancelling);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initial,required TResult Function()  loading,required TResult Function( String message)  error,required TResult Function( Child child,  List<LeaveRequest> items,  LeaveStatus? filter,  bool hasMore,  bool loadingMore,  Set<String> cancelling)  loaded,}) {final _that = this;
switch (_that) {
case ParentLeaveInitial():
return initial();case ParentLeaveLoading():
return loading();case ParentLeaveError():
return error(_that.message);case ParentLeaveLoaded():
return loaded(_that.child,_that.items,_that.filter,_that.hasMore,_that.loadingMore,_that.cancelling);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initial,TResult? Function()?  loading,TResult? Function( String message)?  error,TResult? Function( Child child,  List<LeaveRequest> items,  LeaveStatus? filter,  bool hasMore,  bool loadingMore,  Set<String> cancelling)?  loaded,}) {final _that = this;
switch (_that) {
case ParentLeaveInitial() when initial != null:
return initial();case ParentLeaveLoading() when loading != null:
return loading();case ParentLeaveError() when error != null:
return error(_that.message);case ParentLeaveLoaded() when loaded != null:
return loaded(_that.child,_that.items,_that.filter,_that.hasMore,_that.loadingMore,_that.cancelling);case _:
  return null;

}
}

}

/// @nodoc


class ParentLeaveInitial implements ParentLeaveState {
  const ParentLeaveInitial();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ParentLeaveInitial);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ParentLeaveState.initial()';
}


}




/// @nodoc


class ParentLeaveLoading implements ParentLeaveState {
  const ParentLeaveLoading();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ParentLeaveLoading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ParentLeaveState.loading()';
}


}




/// @nodoc


class ParentLeaveError implements ParentLeaveState {
  const ParentLeaveError(this.message);
  

 final  String message;

/// Create a copy of ParentLeaveState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ParentLeaveErrorCopyWith<ParentLeaveError> get copyWith => _$ParentLeaveErrorCopyWithImpl<ParentLeaveError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ParentLeaveError&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'ParentLeaveState.error(message: $message)';
}


}

/// @nodoc
abstract mixin class $ParentLeaveErrorCopyWith<$Res> implements $ParentLeaveStateCopyWith<$Res> {
  factory $ParentLeaveErrorCopyWith(ParentLeaveError value, $Res Function(ParentLeaveError) _then) = _$ParentLeaveErrorCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class _$ParentLeaveErrorCopyWithImpl<$Res>
    implements $ParentLeaveErrorCopyWith<$Res> {
  _$ParentLeaveErrorCopyWithImpl(this._self, this._then);

  final ParentLeaveError _self;
  final $Res Function(ParentLeaveError) _then;

/// Create a copy of ParentLeaveState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(ParentLeaveError(
null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class ParentLeaveLoaded implements ParentLeaveState {
  const ParentLeaveLoaded({required this.child, required final  List<LeaveRequest> items, this.filter, this.hasMore = false, this.loadingMore = false, final  Set<String> cancelling = const <String>{}}): _items = items,_cancelling = cancelling;
  

 final  Child child;
 final  List<LeaveRequest> _items;
 List<LeaveRequest> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

/// `null` shows every status.
 final  LeaveStatus? filter;
@JsonKey() final  bool hasMore;
@JsonKey() final  bool loadingMore;
/// Requests whose cancel call is in flight.
 final  Set<String> _cancelling;
/// Requests whose cancel call is in flight.
@JsonKey() Set<String> get cancelling {
  if (_cancelling is EqualUnmodifiableSetView) return _cancelling;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_cancelling);
}


/// Create a copy of ParentLeaveState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ParentLeaveLoadedCopyWith<ParentLeaveLoaded> get copyWith => _$ParentLeaveLoadedCopyWithImpl<ParentLeaveLoaded>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ParentLeaveLoaded&&(identical(other.child, child) || other.child == child)&&const DeepCollectionEquality().equals(other._items, _items)&&(identical(other.filter, filter) || other.filter == filter)&&(identical(other.hasMore, hasMore) || other.hasMore == hasMore)&&(identical(other.loadingMore, loadingMore) || other.loadingMore == loadingMore)&&const DeepCollectionEquality().equals(other._cancelling, _cancelling));
}


@override
int get hashCode => Object.hash(runtimeType,child,const DeepCollectionEquality().hash(_items),filter,hasMore,loadingMore,const DeepCollectionEquality().hash(_cancelling));

@override
String toString() {
  return 'ParentLeaveState.loaded(child: $child, items: $items, filter: $filter, hasMore: $hasMore, loadingMore: $loadingMore, cancelling: $cancelling)';
}


}

/// @nodoc
abstract mixin class $ParentLeaveLoadedCopyWith<$Res> implements $ParentLeaveStateCopyWith<$Res> {
  factory $ParentLeaveLoadedCopyWith(ParentLeaveLoaded value, $Res Function(ParentLeaveLoaded) _then) = _$ParentLeaveLoadedCopyWithImpl;
@useResult
$Res call({
 Child child, List<LeaveRequest> items, LeaveStatus? filter, bool hasMore, bool loadingMore, Set<String> cancelling
});


$ChildCopyWith<$Res> get child;

}
/// @nodoc
class _$ParentLeaveLoadedCopyWithImpl<$Res>
    implements $ParentLeaveLoadedCopyWith<$Res> {
  _$ParentLeaveLoadedCopyWithImpl(this._self, this._then);

  final ParentLeaveLoaded _self;
  final $Res Function(ParentLeaveLoaded) _then;

/// Create a copy of ParentLeaveState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? child = null,Object? items = null,Object? filter = freezed,Object? hasMore = null,Object? loadingMore = null,Object? cancelling = null,}) {
  return _then(ParentLeaveLoaded(
child: null == child ? _self.child : child // ignore: cast_nullable_to_non_nullable
as Child,items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<LeaveRequest>,filter: freezed == filter ? _self.filter : filter // ignore: cast_nullable_to_non_nullable
as LeaveStatus?,hasMore: null == hasMore ? _self.hasMore : hasMore // ignore: cast_nullable_to_non_nullable
as bool,loadingMore: null == loadingMore ? _self.loadingMore : loadingMore // ignore: cast_nullable_to_non_nullable
as bool,cancelling: null == cancelling ? _self._cancelling : cancelling // ignore: cast_nullable_to_non_nullable
as Set<String>,
  ));
}

/// Create a copy of ParentLeaveState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ChildCopyWith<$Res> get child {
  
  return $ChildCopyWith<$Res>(_self.child, (value) {
    return _then(_self.copyWith(child: value));
  });
}
}

// dart format on
