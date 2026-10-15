// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'parent_assignments_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ParentAssignmentsState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ParentAssignmentsState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ParentAssignmentsState()';
}


}

/// @nodoc
class $ParentAssignmentsStateCopyWith<$Res>  {
$ParentAssignmentsStateCopyWith(ParentAssignmentsState _, $Res Function(ParentAssignmentsState) __);
}


/// Adds pattern-matching-related methods to [ParentAssignmentsState].
extension ParentAssignmentsStatePatterns on ParentAssignmentsState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( ParentAssignmentsInitial value)?  initial,TResult Function( ParentAssignmentsLoading value)?  loading,TResult Function( ParentAssignmentsError value)?  error,TResult Function( ParentAssignmentsLoaded value)?  loaded,required TResult orElse(),}){
final _that = this;
switch (_that) {
case ParentAssignmentsInitial() when initial != null:
return initial(_that);case ParentAssignmentsLoading() when loading != null:
return loading(_that);case ParentAssignmentsError() when error != null:
return error(_that);case ParentAssignmentsLoaded() when loaded != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( ParentAssignmentsInitial value)  initial,required TResult Function( ParentAssignmentsLoading value)  loading,required TResult Function( ParentAssignmentsError value)  error,required TResult Function( ParentAssignmentsLoaded value)  loaded,}){
final _that = this;
switch (_that) {
case ParentAssignmentsInitial():
return initial(_that);case ParentAssignmentsLoading():
return loading(_that);case ParentAssignmentsError():
return error(_that);case ParentAssignmentsLoaded():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( ParentAssignmentsInitial value)?  initial,TResult? Function( ParentAssignmentsLoading value)?  loading,TResult? Function( ParentAssignmentsError value)?  error,TResult? Function( ParentAssignmentsLoaded value)?  loaded,}){
final _that = this;
switch (_that) {
case ParentAssignmentsInitial() when initial != null:
return initial(_that);case ParentAssignmentsLoading() when loading != null:
return loading(_that);case ParentAssignmentsError() when error != null:
return error(_that);case ParentAssignmentsLoaded() when loaded != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initial,TResult Function()?  loading,TResult Function( String message)?  error,TResult Function( Child child,  List<ChildAssignment> items,  AssignmentFilter filter)?  loaded,required TResult orElse(),}) {final _that = this;
switch (_that) {
case ParentAssignmentsInitial() when initial != null:
return initial();case ParentAssignmentsLoading() when loading != null:
return loading();case ParentAssignmentsError() when error != null:
return error(_that.message);case ParentAssignmentsLoaded() when loaded != null:
return loaded(_that.child,_that.items,_that.filter);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initial,required TResult Function()  loading,required TResult Function( String message)  error,required TResult Function( Child child,  List<ChildAssignment> items,  AssignmentFilter filter)  loaded,}) {final _that = this;
switch (_that) {
case ParentAssignmentsInitial():
return initial();case ParentAssignmentsLoading():
return loading();case ParentAssignmentsError():
return error(_that.message);case ParentAssignmentsLoaded():
return loaded(_that.child,_that.items,_that.filter);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initial,TResult? Function()?  loading,TResult? Function( String message)?  error,TResult? Function( Child child,  List<ChildAssignment> items,  AssignmentFilter filter)?  loaded,}) {final _that = this;
switch (_that) {
case ParentAssignmentsInitial() when initial != null:
return initial();case ParentAssignmentsLoading() when loading != null:
return loading();case ParentAssignmentsError() when error != null:
return error(_that.message);case ParentAssignmentsLoaded() when loaded != null:
return loaded(_that.child,_that.items,_that.filter);case _:
  return null;

}
}

}

/// @nodoc


class ParentAssignmentsInitial implements ParentAssignmentsState {
  const ParentAssignmentsInitial();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ParentAssignmentsInitial);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ParentAssignmentsState.initial()';
}


}




/// @nodoc


class ParentAssignmentsLoading implements ParentAssignmentsState {
  const ParentAssignmentsLoading();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ParentAssignmentsLoading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ParentAssignmentsState.loading()';
}


}




/// @nodoc


class ParentAssignmentsError implements ParentAssignmentsState {
  const ParentAssignmentsError(this.message);
  

 final  String message;

/// Create a copy of ParentAssignmentsState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ParentAssignmentsErrorCopyWith<ParentAssignmentsError> get copyWith => _$ParentAssignmentsErrorCopyWithImpl<ParentAssignmentsError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ParentAssignmentsError&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'ParentAssignmentsState.error(message: $message)';
}


}

/// @nodoc
abstract mixin class $ParentAssignmentsErrorCopyWith<$Res> implements $ParentAssignmentsStateCopyWith<$Res> {
  factory $ParentAssignmentsErrorCopyWith(ParentAssignmentsError value, $Res Function(ParentAssignmentsError) _then) = _$ParentAssignmentsErrorCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class _$ParentAssignmentsErrorCopyWithImpl<$Res>
    implements $ParentAssignmentsErrorCopyWith<$Res> {
  _$ParentAssignmentsErrorCopyWithImpl(this._self, this._then);

  final ParentAssignmentsError _self;
  final $Res Function(ParentAssignmentsError) _then;

/// Create a copy of ParentAssignmentsState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(ParentAssignmentsError(
null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class ParentAssignmentsLoaded implements ParentAssignmentsState {
  const ParentAssignmentsLoaded({required this.child, required final  List<ChildAssignment> items, this.filter = AssignmentFilter.all}): _items = items;
  

 final  Child child;
 final  List<ChildAssignment> _items;
 List<ChildAssignment> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

@JsonKey() final  AssignmentFilter filter;

/// Create a copy of ParentAssignmentsState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ParentAssignmentsLoadedCopyWith<ParentAssignmentsLoaded> get copyWith => _$ParentAssignmentsLoadedCopyWithImpl<ParentAssignmentsLoaded>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ParentAssignmentsLoaded&&(identical(other.child, child) || other.child == child)&&const DeepCollectionEquality().equals(other._items, _items)&&(identical(other.filter, filter) || other.filter == filter));
}


@override
int get hashCode => Object.hash(runtimeType,child,const DeepCollectionEquality().hash(_items),filter);

@override
String toString() {
  return 'ParentAssignmentsState.loaded(child: $child, items: $items, filter: $filter)';
}


}

/// @nodoc
abstract mixin class $ParentAssignmentsLoadedCopyWith<$Res> implements $ParentAssignmentsStateCopyWith<$Res> {
  factory $ParentAssignmentsLoadedCopyWith(ParentAssignmentsLoaded value, $Res Function(ParentAssignmentsLoaded) _then) = _$ParentAssignmentsLoadedCopyWithImpl;
@useResult
$Res call({
 Child child, List<ChildAssignment> items, AssignmentFilter filter
});


$ChildCopyWith<$Res> get child;

}
/// @nodoc
class _$ParentAssignmentsLoadedCopyWithImpl<$Res>
    implements $ParentAssignmentsLoadedCopyWith<$Res> {
  _$ParentAssignmentsLoadedCopyWithImpl(this._self, this._then);

  final ParentAssignmentsLoaded _self;
  final $Res Function(ParentAssignmentsLoaded) _then;

/// Create a copy of ParentAssignmentsState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? child = null,Object? items = null,Object? filter = null,}) {
  return _then(ParentAssignmentsLoaded(
child: null == child ? _self.child : child // ignore: cast_nullable_to_non_nullable
as Child,items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<ChildAssignment>,filter: null == filter ? _self.filter : filter // ignore: cast_nullable_to_non_nullable
as AssignmentFilter,
  ));
}

/// Create a copy of ParentAssignmentsState
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
