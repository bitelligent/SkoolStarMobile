// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'parent_profile_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ParentProfileState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ParentProfileState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ParentProfileState()';
}


}

/// @nodoc
class $ParentProfileStateCopyWith<$Res>  {
$ParentProfileStateCopyWith(ParentProfileState _, $Res Function(ParentProfileState) __);
}


/// Adds pattern-matching-related methods to [ParentProfileState].
extension ParentProfileStatePatterns on ParentProfileState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( ParentProfileInitial value)?  initial,TResult Function( ParentProfileLoading value)?  loading,TResult Function( ParentProfileError value)?  error,TResult Function( ParentProfileLoaded value)?  loaded,required TResult orElse(),}){
final _that = this;
switch (_that) {
case ParentProfileInitial() when initial != null:
return initial(_that);case ParentProfileLoading() when loading != null:
return loading(_that);case ParentProfileError() when error != null:
return error(_that);case ParentProfileLoaded() when loaded != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( ParentProfileInitial value)  initial,required TResult Function( ParentProfileLoading value)  loading,required TResult Function( ParentProfileError value)  error,required TResult Function( ParentProfileLoaded value)  loaded,}){
final _that = this;
switch (_that) {
case ParentProfileInitial():
return initial(_that);case ParentProfileLoading():
return loading(_that);case ParentProfileError():
return error(_that);case ParentProfileLoaded():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( ParentProfileInitial value)?  initial,TResult? Function( ParentProfileLoading value)?  loading,TResult? Function( ParentProfileError value)?  error,TResult? Function( ParentProfileLoaded value)?  loaded,}){
final _that = this;
switch (_that) {
case ParentProfileInitial() when initial != null:
return initial(_that);case ParentProfileLoading() when loading != null:
return loading(_that);case ParentProfileError() when error != null:
return error(_that);case ParentProfileLoaded() when loaded != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initial,TResult Function()?  loading,TResult Function( String message)?  error,TResult Function( GuardianProfile profile)?  loaded,required TResult orElse(),}) {final _that = this;
switch (_that) {
case ParentProfileInitial() when initial != null:
return initial();case ParentProfileLoading() when loading != null:
return loading();case ParentProfileError() when error != null:
return error(_that.message);case ParentProfileLoaded() when loaded != null:
return loaded(_that.profile);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initial,required TResult Function()  loading,required TResult Function( String message)  error,required TResult Function( GuardianProfile profile)  loaded,}) {final _that = this;
switch (_that) {
case ParentProfileInitial():
return initial();case ParentProfileLoading():
return loading();case ParentProfileError():
return error(_that.message);case ParentProfileLoaded():
return loaded(_that.profile);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initial,TResult? Function()?  loading,TResult? Function( String message)?  error,TResult? Function( GuardianProfile profile)?  loaded,}) {final _that = this;
switch (_that) {
case ParentProfileInitial() when initial != null:
return initial();case ParentProfileLoading() when loading != null:
return loading();case ParentProfileError() when error != null:
return error(_that.message);case ParentProfileLoaded() when loaded != null:
return loaded(_that.profile);case _:
  return null;

}
}

}

/// @nodoc


class ParentProfileInitial implements ParentProfileState {
  const ParentProfileInitial();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ParentProfileInitial);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ParentProfileState.initial()';
}


}




/// @nodoc


class ParentProfileLoading implements ParentProfileState {
  const ParentProfileLoading();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ParentProfileLoading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ParentProfileState.loading()';
}


}




/// @nodoc


class ParentProfileError implements ParentProfileState {
  const ParentProfileError(this.message);
  

 final  String message;

/// Create a copy of ParentProfileState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ParentProfileErrorCopyWith<ParentProfileError> get copyWith => _$ParentProfileErrorCopyWithImpl<ParentProfileError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ParentProfileError&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'ParentProfileState.error(message: $message)';
}


}

/// @nodoc
abstract mixin class $ParentProfileErrorCopyWith<$Res> implements $ParentProfileStateCopyWith<$Res> {
  factory $ParentProfileErrorCopyWith(ParentProfileError value, $Res Function(ParentProfileError) _then) = _$ParentProfileErrorCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class _$ParentProfileErrorCopyWithImpl<$Res>
    implements $ParentProfileErrorCopyWith<$Res> {
  _$ParentProfileErrorCopyWithImpl(this._self, this._then);

  final ParentProfileError _self;
  final $Res Function(ParentProfileError) _then;

/// Create a copy of ParentProfileState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(ParentProfileError(
null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class ParentProfileLoaded implements ParentProfileState {
  const ParentProfileLoaded(this.profile);
  

 final  GuardianProfile profile;

/// Create a copy of ParentProfileState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ParentProfileLoadedCopyWith<ParentProfileLoaded> get copyWith => _$ParentProfileLoadedCopyWithImpl<ParentProfileLoaded>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ParentProfileLoaded&&(identical(other.profile, profile) || other.profile == profile));
}


@override
int get hashCode => Object.hash(runtimeType,profile);

@override
String toString() {
  return 'ParentProfileState.loaded(profile: $profile)';
}


}

/// @nodoc
abstract mixin class $ParentProfileLoadedCopyWith<$Res> implements $ParentProfileStateCopyWith<$Res> {
  factory $ParentProfileLoadedCopyWith(ParentProfileLoaded value, $Res Function(ParentProfileLoaded) _then) = _$ParentProfileLoadedCopyWithImpl;
@useResult
$Res call({
 GuardianProfile profile
});




}
/// @nodoc
class _$ParentProfileLoadedCopyWithImpl<$Res>
    implements $ParentProfileLoadedCopyWith<$Res> {
  _$ParentProfileLoadedCopyWithImpl(this._self, this._then);

  final ParentProfileLoaded _self;
  final $Res Function(ParentProfileLoaded) _then;

/// Create a copy of ParentProfileState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? profile = null,}) {
  return _then(ParentProfileLoaded(
null == profile ? _self.profile : profile // ignore: cast_nullable_to_non_nullable
as GuardianProfile,
  ));
}


}

// dart format on
