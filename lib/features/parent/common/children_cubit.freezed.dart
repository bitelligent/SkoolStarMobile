// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'children_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ChildrenState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChildrenState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ChildrenState()';
}


}

/// @nodoc
class $ChildrenStateCopyWith<$Res>  {
$ChildrenStateCopyWith(ChildrenState _, $Res Function(ChildrenState) __);
}


/// Adds pattern-matching-related methods to [ChildrenState].
extension ChildrenStatePatterns on ChildrenState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( ChildrenInitial value)?  initial,TResult Function( ChildrenLoading value)?  loading,TResult Function( ChildrenLoaded value)?  loaded,TResult Function( ChildrenError value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case ChildrenInitial() when initial != null:
return initial(_that);case ChildrenLoading() when loading != null:
return loading(_that);case ChildrenLoaded() when loaded != null:
return loaded(_that);case ChildrenError() when error != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( ChildrenInitial value)  initial,required TResult Function( ChildrenLoading value)  loading,required TResult Function( ChildrenLoaded value)  loaded,required TResult Function( ChildrenError value)  error,}){
final _that = this;
switch (_that) {
case ChildrenInitial():
return initial(_that);case ChildrenLoading():
return loading(_that);case ChildrenLoaded():
return loaded(_that);case ChildrenError():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( ChildrenInitial value)?  initial,TResult? Function( ChildrenLoading value)?  loading,TResult? Function( ChildrenLoaded value)?  loaded,TResult? Function( ChildrenError value)?  error,}){
final _that = this;
switch (_that) {
case ChildrenInitial() when initial != null:
return initial(_that);case ChildrenLoading() when loading != null:
return loading(_that);case ChildrenLoaded() when loaded != null:
return loaded(_that);case ChildrenError() when error != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initial,TResult Function()?  loading,TResult Function( List<Child> children,  Child? selected)?  loaded,TResult Function( String message)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case ChildrenInitial() when initial != null:
return initial();case ChildrenLoading() when loading != null:
return loading();case ChildrenLoaded() when loaded != null:
return loaded(_that.children,_that.selected);case ChildrenError() when error != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initial,required TResult Function()  loading,required TResult Function( List<Child> children,  Child? selected)  loaded,required TResult Function( String message)  error,}) {final _that = this;
switch (_that) {
case ChildrenInitial():
return initial();case ChildrenLoading():
return loading();case ChildrenLoaded():
return loaded(_that.children,_that.selected);case ChildrenError():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initial,TResult? Function()?  loading,TResult? Function( List<Child> children,  Child? selected)?  loaded,TResult? Function( String message)?  error,}) {final _that = this;
switch (_that) {
case ChildrenInitial() when initial != null:
return initial();case ChildrenLoading() when loading != null:
return loading();case ChildrenLoaded() when loaded != null:
return loaded(_that.children,_that.selected);case ChildrenError() when error != null:
return error(_that.message);case _:
  return null;

}
}

}

/// @nodoc


class ChildrenInitial extends ChildrenState {
  const ChildrenInitial(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChildrenInitial);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ChildrenState.initial()';
}


}




/// @nodoc


class ChildrenLoading extends ChildrenState {
  const ChildrenLoading(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChildrenLoading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ChildrenState.loading()';
}


}




/// @nodoc


class ChildrenLoaded extends ChildrenState {
  const ChildrenLoaded({required final  List<Child> children, required this.selected}): _children = children,super._();
  

 final  List<Child> _children;
 List<Child> get children {
  if (_children is EqualUnmodifiableListView) return _children;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_children);
}

 final  Child? selected;

/// Create a copy of ChildrenState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChildrenLoadedCopyWith<ChildrenLoaded> get copyWith => _$ChildrenLoadedCopyWithImpl<ChildrenLoaded>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChildrenLoaded&&const DeepCollectionEquality().equals(other._children, _children)&&(identical(other.selected, selected) || other.selected == selected));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_children),selected);

@override
String toString() {
  return 'ChildrenState.loaded(children: $children, selected: $selected)';
}


}

/// @nodoc
abstract mixin class $ChildrenLoadedCopyWith<$Res> implements $ChildrenStateCopyWith<$Res> {
  factory $ChildrenLoadedCopyWith(ChildrenLoaded value, $Res Function(ChildrenLoaded) _then) = _$ChildrenLoadedCopyWithImpl;
@useResult
$Res call({
 List<Child> children, Child? selected
});


$ChildCopyWith<$Res>? get selected;

}
/// @nodoc
class _$ChildrenLoadedCopyWithImpl<$Res>
    implements $ChildrenLoadedCopyWith<$Res> {
  _$ChildrenLoadedCopyWithImpl(this._self, this._then);

  final ChildrenLoaded _self;
  final $Res Function(ChildrenLoaded) _then;

/// Create a copy of ChildrenState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? children = null,Object? selected = freezed,}) {
  return _then(ChildrenLoaded(
children: null == children ? _self._children : children // ignore: cast_nullable_to_non_nullable
as List<Child>,selected: freezed == selected ? _self.selected : selected // ignore: cast_nullable_to_non_nullable
as Child?,
  ));
}

/// Create a copy of ChildrenState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ChildCopyWith<$Res>? get selected {
    if (_self.selected == null) {
    return null;
  }

  return $ChildCopyWith<$Res>(_self.selected!, (value) {
    return _then(_self.copyWith(selected: value));
  });
}
}

/// @nodoc


class ChildrenError extends ChildrenState {
  const ChildrenError(this.message): super._();
  

 final  String message;

/// Create a copy of ChildrenState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChildrenErrorCopyWith<ChildrenError> get copyWith => _$ChildrenErrorCopyWithImpl<ChildrenError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChildrenError&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'ChildrenState.error(message: $message)';
}


}

/// @nodoc
abstract mixin class $ChildrenErrorCopyWith<$Res> implements $ChildrenStateCopyWith<$Res> {
  factory $ChildrenErrorCopyWith(ChildrenError value, $Res Function(ChildrenError) _then) = _$ChildrenErrorCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class _$ChildrenErrorCopyWithImpl<$Res>
    implements $ChildrenErrorCopyWith<$Res> {
  _$ChildrenErrorCopyWithImpl(this._self, this._then);

  final ChildrenError _self;
  final $Res Function(ChildrenError) _then;

/// Create a copy of ChildrenState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(ChildrenError(
null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
