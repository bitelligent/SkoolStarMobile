// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'role_selection_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$RoleSelectionState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RoleSelectionState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'RoleSelectionState()';
}


}

/// @nodoc
class $RoleSelectionStateCopyWith<$Res>  {
$RoleSelectionStateCopyWith(RoleSelectionState _, $Res Function(RoleSelectionState) __);
}


/// Adds pattern-matching-related methods to [RoleSelectionState].
extension RoleSelectionStatePatterns on RoleSelectionState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( RoleSelectionIdle value)?  idle,TResult Function( RoleSelectionSelecting value)?  selecting,TResult Function( RoleSelectionSelected value)?  selected,TResult Function( RoleSelectionFailure value)?  failure,required TResult orElse(),}){
final _that = this;
switch (_that) {
case RoleSelectionIdle() when idle != null:
return idle(_that);case RoleSelectionSelecting() when selecting != null:
return selecting(_that);case RoleSelectionSelected() when selected != null:
return selected(_that);case RoleSelectionFailure() when failure != null:
return failure(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( RoleSelectionIdle value)  idle,required TResult Function( RoleSelectionSelecting value)  selecting,required TResult Function( RoleSelectionSelected value)  selected,required TResult Function( RoleSelectionFailure value)  failure,}){
final _that = this;
switch (_that) {
case RoleSelectionIdle():
return idle(_that);case RoleSelectionSelecting():
return selecting(_that);case RoleSelectionSelected():
return selected(_that);case RoleSelectionFailure():
return failure(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( RoleSelectionIdle value)?  idle,TResult? Function( RoleSelectionSelecting value)?  selecting,TResult? Function( RoleSelectionSelected value)?  selected,TResult? Function( RoleSelectionFailure value)?  failure,}){
final _that = this;
switch (_that) {
case RoleSelectionIdle() when idle != null:
return idle(_that);case RoleSelectionSelecting() when selecting != null:
return selecting(_that);case RoleSelectionSelected() when selected != null:
return selected(_that);case RoleSelectionFailure() when failure != null:
return failure(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  idle,TResult Function( String contextKey)?  selecting,TResult Function( AuthContext active)?  selected,TResult Function( String message)?  failure,required TResult orElse(),}) {final _that = this;
switch (_that) {
case RoleSelectionIdle() when idle != null:
return idle();case RoleSelectionSelecting() when selecting != null:
return selecting(_that.contextKey);case RoleSelectionSelected() when selected != null:
return selected(_that.active);case RoleSelectionFailure() when failure != null:
return failure(_that.message);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  idle,required TResult Function( String contextKey)  selecting,required TResult Function( AuthContext active)  selected,required TResult Function( String message)  failure,}) {final _that = this;
switch (_that) {
case RoleSelectionIdle():
return idle();case RoleSelectionSelecting():
return selecting(_that.contextKey);case RoleSelectionSelected():
return selected(_that.active);case RoleSelectionFailure():
return failure(_that.message);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  idle,TResult? Function( String contextKey)?  selecting,TResult? Function( AuthContext active)?  selected,TResult? Function( String message)?  failure,}) {final _that = this;
switch (_that) {
case RoleSelectionIdle() when idle != null:
return idle();case RoleSelectionSelecting() when selecting != null:
return selecting(_that.contextKey);case RoleSelectionSelected() when selected != null:
return selected(_that.active);case RoleSelectionFailure() when failure != null:
return failure(_that.message);case _:
  return null;

}
}

}

/// @nodoc


class RoleSelectionIdle implements RoleSelectionState {
  const RoleSelectionIdle();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RoleSelectionIdle);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'RoleSelectionState.idle()';
}


}




/// @nodoc


class RoleSelectionSelecting implements RoleSelectionState {
  const RoleSelectionSelecting(this.contextKey);
  

 final  String contextKey;

/// Create a copy of RoleSelectionState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RoleSelectionSelectingCopyWith<RoleSelectionSelecting> get copyWith => _$RoleSelectionSelectingCopyWithImpl<RoleSelectionSelecting>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RoleSelectionSelecting&&(identical(other.contextKey, contextKey) || other.contextKey == contextKey));
}


@override
int get hashCode => Object.hash(runtimeType,contextKey);

@override
String toString() {
  return 'RoleSelectionState.selecting(contextKey: $contextKey)';
}


}

/// @nodoc
abstract mixin class $RoleSelectionSelectingCopyWith<$Res> implements $RoleSelectionStateCopyWith<$Res> {
  factory $RoleSelectionSelectingCopyWith(RoleSelectionSelecting value, $Res Function(RoleSelectionSelecting) _then) = _$RoleSelectionSelectingCopyWithImpl;
@useResult
$Res call({
 String contextKey
});




}
/// @nodoc
class _$RoleSelectionSelectingCopyWithImpl<$Res>
    implements $RoleSelectionSelectingCopyWith<$Res> {
  _$RoleSelectionSelectingCopyWithImpl(this._self, this._then);

  final RoleSelectionSelecting _self;
  final $Res Function(RoleSelectionSelecting) _then;

/// Create a copy of RoleSelectionState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? contextKey = null,}) {
  return _then(RoleSelectionSelecting(
null == contextKey ? _self.contextKey : contextKey // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class RoleSelectionSelected implements RoleSelectionState {
  const RoleSelectionSelected(this.active);
  

 final  AuthContext active;

/// Create a copy of RoleSelectionState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RoleSelectionSelectedCopyWith<RoleSelectionSelected> get copyWith => _$RoleSelectionSelectedCopyWithImpl<RoleSelectionSelected>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RoleSelectionSelected&&(identical(other.active, active) || other.active == active));
}


@override
int get hashCode => Object.hash(runtimeType,active);

@override
String toString() {
  return 'RoleSelectionState.selected(active: $active)';
}


}

/// @nodoc
abstract mixin class $RoleSelectionSelectedCopyWith<$Res> implements $RoleSelectionStateCopyWith<$Res> {
  factory $RoleSelectionSelectedCopyWith(RoleSelectionSelected value, $Res Function(RoleSelectionSelected) _then) = _$RoleSelectionSelectedCopyWithImpl;
@useResult
$Res call({
 AuthContext active
});


$AuthContextCopyWith<$Res> get active;

}
/// @nodoc
class _$RoleSelectionSelectedCopyWithImpl<$Res>
    implements $RoleSelectionSelectedCopyWith<$Res> {
  _$RoleSelectionSelectedCopyWithImpl(this._self, this._then);

  final RoleSelectionSelected _self;
  final $Res Function(RoleSelectionSelected) _then;

/// Create a copy of RoleSelectionState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? active = null,}) {
  return _then(RoleSelectionSelected(
null == active ? _self.active : active // ignore: cast_nullable_to_non_nullable
as AuthContext,
  ));
}

/// Create a copy of RoleSelectionState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AuthContextCopyWith<$Res> get active {
  
  return $AuthContextCopyWith<$Res>(_self.active, (value) {
    return _then(_self.copyWith(active: value));
  });
}
}

/// @nodoc


class RoleSelectionFailure implements RoleSelectionState {
  const RoleSelectionFailure(this.message);
  

 final  String message;

/// Create a copy of RoleSelectionState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RoleSelectionFailureCopyWith<RoleSelectionFailure> get copyWith => _$RoleSelectionFailureCopyWithImpl<RoleSelectionFailure>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RoleSelectionFailure&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'RoleSelectionState.failure(message: $message)';
}


}

/// @nodoc
abstract mixin class $RoleSelectionFailureCopyWith<$Res> implements $RoleSelectionStateCopyWith<$Res> {
  factory $RoleSelectionFailureCopyWith(RoleSelectionFailure value, $Res Function(RoleSelectionFailure) _then) = _$RoleSelectionFailureCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class _$RoleSelectionFailureCopyWithImpl<$Res>
    implements $RoleSelectionFailureCopyWith<$Res> {
  _$RoleSelectionFailureCopyWithImpl(this._self, this._then);

  final RoleSelectionFailure _self;
  final $Res Function(RoleSelectionFailure) _then;

/// Create a copy of RoleSelectionState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(RoleSelectionFailure(
null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
