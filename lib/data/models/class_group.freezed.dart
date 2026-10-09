// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'class_group.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ClassGroup {

 String get id; String get name; int get studentCount; String get colorHex;
/// Create a copy of ClassGroup
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ClassGroupCopyWith<ClassGroup> get copyWith => _$ClassGroupCopyWithImpl<ClassGroup>(this as ClassGroup, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ClassGroup&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.studentCount, studentCount) || other.studentCount == studentCount)&&(identical(other.colorHex, colorHex) || other.colorHex == colorHex));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,studentCount,colorHex);

@override
String toString() {
  return 'ClassGroup(id: $id, name: $name, studentCount: $studentCount, colorHex: $colorHex)';
}


}

/// @nodoc
abstract mixin class $ClassGroupCopyWith<$Res>  {
  factory $ClassGroupCopyWith(ClassGroup value, $Res Function(ClassGroup) _then) = _$ClassGroupCopyWithImpl;
@useResult
$Res call({
 String id, String name, int studentCount, String colorHex
});




}
/// @nodoc
class _$ClassGroupCopyWithImpl<$Res>
    implements $ClassGroupCopyWith<$Res> {
  _$ClassGroupCopyWithImpl(this._self, this._then);

  final ClassGroup _self;
  final $Res Function(ClassGroup) _then;

/// Create a copy of ClassGroup
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? studentCount = null,Object? colorHex = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,studentCount: null == studentCount ? _self.studentCount : studentCount // ignore: cast_nullable_to_non_nullable
as int,colorHex: null == colorHex ? _self.colorHex : colorHex // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ClassGroup].
extension ClassGroupPatterns on ClassGroup {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ClassGroup value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ClassGroup() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ClassGroup value)  $default,){
final _that = this;
switch (_that) {
case _ClassGroup():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ClassGroup value)?  $default,){
final _that = this;
switch (_that) {
case _ClassGroup() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  int studentCount,  String colorHex)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ClassGroup() when $default != null:
return $default(_that.id,_that.name,_that.studentCount,_that.colorHex);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  int studentCount,  String colorHex)  $default,) {final _that = this;
switch (_that) {
case _ClassGroup():
return $default(_that.id,_that.name,_that.studentCount,_that.colorHex);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  int studentCount,  String colorHex)?  $default,) {final _that = this;
switch (_that) {
case _ClassGroup() when $default != null:
return $default(_that.id,_that.name,_that.studentCount,_that.colorHex);case _:
  return null;

}
}

}

/// @nodoc


class _ClassGroup implements ClassGroup {
  const _ClassGroup({required this.id, required this.name, this.studentCount = 0, this.colorHex = '#2563EB'});
  

@override final  String id;
@override final  String name;
@override@JsonKey() final  int studentCount;
@override@JsonKey() final  String colorHex;

/// Create a copy of ClassGroup
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ClassGroupCopyWith<_ClassGroup> get copyWith => __$ClassGroupCopyWithImpl<_ClassGroup>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ClassGroup&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.studentCount, studentCount) || other.studentCount == studentCount)&&(identical(other.colorHex, colorHex) || other.colorHex == colorHex));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,studentCount,colorHex);

@override
String toString() {
  return 'ClassGroup(id: $id, name: $name, studentCount: $studentCount, colorHex: $colorHex)';
}


}

/// @nodoc
abstract mixin class _$ClassGroupCopyWith<$Res> implements $ClassGroupCopyWith<$Res> {
  factory _$ClassGroupCopyWith(_ClassGroup value, $Res Function(_ClassGroup) _then) = __$ClassGroupCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, int studentCount, String colorHex
});




}
/// @nodoc
class __$ClassGroupCopyWithImpl<$Res>
    implements _$ClassGroupCopyWith<$Res> {
  __$ClassGroupCopyWithImpl(this._self, this._then);

  final _ClassGroup _self;
  final $Res Function(_ClassGroup) _then;

/// Create a copy of ClassGroup
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? studentCount = null,Object? colorHex = null,}) {
  return _then(_ClassGroup(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,studentCount: null == studentCount ? _self.studentCount : studentCount // ignore: cast_nullable_to_non_nullable
as int,colorHex: null == colorHex ? _self.colorHex : colorHex // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
