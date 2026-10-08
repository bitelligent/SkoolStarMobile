// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'auth_context.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AuthContext {

 String get contextKey; String get role; int? get clientId; String? get clientName; int? get instituteId; String? get instituteName; int? get staffId; int? get studentId; int? get guardianId; String? get displayName;
/// Create a copy of AuthContext
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AuthContextCopyWith<AuthContext> get copyWith => _$AuthContextCopyWithImpl<AuthContext>(this as AuthContext, _$identity);

  /// Serializes this AuthContext to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthContext&&(identical(other.contextKey, contextKey) || other.contextKey == contextKey)&&(identical(other.role, role) || other.role == role)&&(identical(other.clientId, clientId) || other.clientId == clientId)&&(identical(other.clientName, clientName) || other.clientName == clientName)&&(identical(other.instituteId, instituteId) || other.instituteId == instituteId)&&(identical(other.instituteName, instituteName) || other.instituteName == instituteName)&&(identical(other.staffId, staffId) || other.staffId == staffId)&&(identical(other.studentId, studentId) || other.studentId == studentId)&&(identical(other.guardianId, guardianId) || other.guardianId == guardianId)&&(identical(other.displayName, displayName) || other.displayName == displayName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,contextKey,role,clientId,clientName,instituteId,instituteName,staffId,studentId,guardianId,displayName);

@override
String toString() {
  return 'AuthContext(contextKey: $contextKey, role: $role, clientId: $clientId, clientName: $clientName, instituteId: $instituteId, instituteName: $instituteName, staffId: $staffId, studentId: $studentId, guardianId: $guardianId, displayName: $displayName)';
}


}

/// @nodoc
abstract mixin class $AuthContextCopyWith<$Res>  {
  factory $AuthContextCopyWith(AuthContext value, $Res Function(AuthContext) _then) = _$AuthContextCopyWithImpl;
@useResult
$Res call({
 String contextKey, String role, int? clientId, String? clientName, int? instituteId, String? instituteName, int? staffId, int? studentId, int? guardianId, String? displayName
});




}
/// @nodoc
class _$AuthContextCopyWithImpl<$Res>
    implements $AuthContextCopyWith<$Res> {
  _$AuthContextCopyWithImpl(this._self, this._then);

  final AuthContext _self;
  final $Res Function(AuthContext) _then;

/// Create a copy of AuthContext
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? contextKey = null,Object? role = null,Object? clientId = freezed,Object? clientName = freezed,Object? instituteId = freezed,Object? instituteName = freezed,Object? staffId = freezed,Object? studentId = freezed,Object? guardianId = freezed,Object? displayName = freezed,}) {
  return _then(_self.copyWith(
contextKey: null == contextKey ? _self.contextKey : contextKey // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String,clientId: freezed == clientId ? _self.clientId : clientId // ignore: cast_nullable_to_non_nullable
as int?,clientName: freezed == clientName ? _self.clientName : clientName // ignore: cast_nullable_to_non_nullable
as String?,instituteId: freezed == instituteId ? _self.instituteId : instituteId // ignore: cast_nullable_to_non_nullable
as int?,instituteName: freezed == instituteName ? _self.instituteName : instituteName // ignore: cast_nullable_to_non_nullable
as String?,staffId: freezed == staffId ? _self.staffId : staffId // ignore: cast_nullable_to_non_nullable
as int?,studentId: freezed == studentId ? _self.studentId : studentId // ignore: cast_nullable_to_non_nullable
as int?,guardianId: freezed == guardianId ? _self.guardianId : guardianId // ignore: cast_nullable_to_non_nullable
as int?,displayName: freezed == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [AuthContext].
extension AuthContextPatterns on AuthContext {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AuthContext value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AuthContext() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AuthContext value)  $default,){
final _that = this;
switch (_that) {
case _AuthContext():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AuthContext value)?  $default,){
final _that = this;
switch (_that) {
case _AuthContext() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String contextKey,  String role,  int? clientId,  String? clientName,  int? instituteId,  String? instituteName,  int? staffId,  int? studentId,  int? guardianId,  String? displayName)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AuthContext() when $default != null:
return $default(_that.contextKey,_that.role,_that.clientId,_that.clientName,_that.instituteId,_that.instituteName,_that.staffId,_that.studentId,_that.guardianId,_that.displayName);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String contextKey,  String role,  int? clientId,  String? clientName,  int? instituteId,  String? instituteName,  int? staffId,  int? studentId,  int? guardianId,  String? displayName)  $default,) {final _that = this;
switch (_that) {
case _AuthContext():
return $default(_that.contextKey,_that.role,_that.clientId,_that.clientName,_that.instituteId,_that.instituteName,_that.staffId,_that.studentId,_that.guardianId,_that.displayName);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String contextKey,  String role,  int? clientId,  String? clientName,  int? instituteId,  String? instituteName,  int? staffId,  int? studentId,  int? guardianId,  String? displayName)?  $default,) {final _that = this;
switch (_that) {
case _AuthContext() when $default != null:
return $default(_that.contextKey,_that.role,_that.clientId,_that.clientName,_that.instituteId,_that.instituteName,_that.staffId,_that.studentId,_that.guardianId,_that.displayName);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AuthContext implements AuthContext {
  const _AuthContext({required this.contextKey, required this.role, this.clientId, this.clientName, this.instituteId, this.instituteName, this.staffId, this.studentId, this.guardianId, this.displayName});
  factory _AuthContext.fromJson(Map<String, dynamic> json) => _$AuthContextFromJson(json);

@override final  String contextKey;
@override final  String role;
@override final  int? clientId;
@override final  String? clientName;
@override final  int? instituteId;
@override final  String? instituteName;
@override final  int? staffId;
@override final  int? studentId;
@override final  int? guardianId;
@override final  String? displayName;

/// Create a copy of AuthContext
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AuthContextCopyWith<_AuthContext> get copyWith => __$AuthContextCopyWithImpl<_AuthContext>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AuthContextToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AuthContext&&(identical(other.contextKey, contextKey) || other.contextKey == contextKey)&&(identical(other.role, role) || other.role == role)&&(identical(other.clientId, clientId) || other.clientId == clientId)&&(identical(other.clientName, clientName) || other.clientName == clientName)&&(identical(other.instituteId, instituteId) || other.instituteId == instituteId)&&(identical(other.instituteName, instituteName) || other.instituteName == instituteName)&&(identical(other.staffId, staffId) || other.staffId == staffId)&&(identical(other.studentId, studentId) || other.studentId == studentId)&&(identical(other.guardianId, guardianId) || other.guardianId == guardianId)&&(identical(other.displayName, displayName) || other.displayName == displayName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,contextKey,role,clientId,clientName,instituteId,instituteName,staffId,studentId,guardianId,displayName);

@override
String toString() {
  return 'AuthContext(contextKey: $contextKey, role: $role, clientId: $clientId, clientName: $clientName, instituteId: $instituteId, instituteName: $instituteName, staffId: $staffId, studentId: $studentId, guardianId: $guardianId, displayName: $displayName)';
}


}

/// @nodoc
abstract mixin class _$AuthContextCopyWith<$Res> implements $AuthContextCopyWith<$Res> {
  factory _$AuthContextCopyWith(_AuthContext value, $Res Function(_AuthContext) _then) = __$AuthContextCopyWithImpl;
@override @useResult
$Res call({
 String contextKey, String role, int? clientId, String? clientName, int? instituteId, String? instituteName, int? staffId, int? studentId, int? guardianId, String? displayName
});




}
/// @nodoc
class __$AuthContextCopyWithImpl<$Res>
    implements _$AuthContextCopyWith<$Res> {
  __$AuthContextCopyWithImpl(this._self, this._then);

  final _AuthContext _self;
  final $Res Function(_AuthContext) _then;

/// Create a copy of AuthContext
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? contextKey = null,Object? role = null,Object? clientId = freezed,Object? clientName = freezed,Object? instituteId = freezed,Object? instituteName = freezed,Object? staffId = freezed,Object? studentId = freezed,Object? guardianId = freezed,Object? displayName = freezed,}) {
  return _then(_AuthContext(
contextKey: null == contextKey ? _self.contextKey : contextKey // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String,clientId: freezed == clientId ? _self.clientId : clientId // ignore: cast_nullable_to_non_nullable
as int?,clientName: freezed == clientName ? _self.clientName : clientName // ignore: cast_nullable_to_non_nullable
as String?,instituteId: freezed == instituteId ? _self.instituteId : instituteId // ignore: cast_nullable_to_non_nullable
as int?,instituteName: freezed == instituteName ? _self.instituteName : instituteName // ignore: cast_nullable_to_non_nullable
as String?,staffId: freezed == staffId ? _self.staffId : staffId // ignore: cast_nullable_to_non_nullable
as int?,studentId: freezed == studentId ? _self.studentId : studentId // ignore: cast_nullable_to_non_nullable
as int?,guardianId: freezed == guardianId ? _self.guardianId : guardianId // ignore: cast_nullable_to_non_nullable
as int?,displayName: freezed == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
