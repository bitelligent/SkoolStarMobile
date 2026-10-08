// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'login_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$LoginResponse {

 String? get tokenType; String? get accessToken; String? get refreshToken;/// Access-token lifetime in seconds.
 int? get expiresIn; String? get activeContextKey;/// True when the account has several contexts and the client must pick
/// one (re-submit login with `contextKey`) before a token is issued.
 bool get requiresContextSelection; List<AuthContext> get availableContexts;
/// Create a copy of LoginResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LoginResponseCopyWith<LoginResponse> get copyWith => _$LoginResponseCopyWithImpl<LoginResponse>(this as LoginResponse, _$identity);

  /// Serializes this LoginResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LoginResponse&&(identical(other.tokenType, tokenType) || other.tokenType == tokenType)&&(identical(other.accessToken, accessToken) || other.accessToken == accessToken)&&(identical(other.refreshToken, refreshToken) || other.refreshToken == refreshToken)&&(identical(other.expiresIn, expiresIn) || other.expiresIn == expiresIn)&&(identical(other.activeContextKey, activeContextKey) || other.activeContextKey == activeContextKey)&&(identical(other.requiresContextSelection, requiresContextSelection) || other.requiresContextSelection == requiresContextSelection)&&const DeepCollectionEquality().equals(other.availableContexts, availableContexts));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,tokenType,accessToken,refreshToken,expiresIn,activeContextKey,requiresContextSelection,const DeepCollectionEquality().hash(availableContexts));

@override
String toString() {
  return 'LoginResponse(tokenType: $tokenType, accessToken: $accessToken, refreshToken: $refreshToken, expiresIn: $expiresIn, activeContextKey: $activeContextKey, requiresContextSelection: $requiresContextSelection, availableContexts: $availableContexts)';
}


}

/// @nodoc
abstract mixin class $LoginResponseCopyWith<$Res>  {
  factory $LoginResponseCopyWith(LoginResponse value, $Res Function(LoginResponse) _then) = _$LoginResponseCopyWithImpl;
@useResult
$Res call({
 String? tokenType, String? accessToken, String? refreshToken, int? expiresIn, String? activeContextKey, bool requiresContextSelection, List<AuthContext> availableContexts
});




}
/// @nodoc
class _$LoginResponseCopyWithImpl<$Res>
    implements $LoginResponseCopyWith<$Res> {
  _$LoginResponseCopyWithImpl(this._self, this._then);

  final LoginResponse _self;
  final $Res Function(LoginResponse) _then;

/// Create a copy of LoginResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? tokenType = freezed,Object? accessToken = freezed,Object? refreshToken = freezed,Object? expiresIn = freezed,Object? activeContextKey = freezed,Object? requiresContextSelection = null,Object? availableContexts = null,}) {
  return _then(_self.copyWith(
tokenType: freezed == tokenType ? _self.tokenType : tokenType // ignore: cast_nullable_to_non_nullable
as String?,accessToken: freezed == accessToken ? _self.accessToken : accessToken // ignore: cast_nullable_to_non_nullable
as String?,refreshToken: freezed == refreshToken ? _self.refreshToken : refreshToken // ignore: cast_nullable_to_non_nullable
as String?,expiresIn: freezed == expiresIn ? _self.expiresIn : expiresIn // ignore: cast_nullable_to_non_nullable
as int?,activeContextKey: freezed == activeContextKey ? _self.activeContextKey : activeContextKey // ignore: cast_nullable_to_non_nullable
as String?,requiresContextSelection: null == requiresContextSelection ? _self.requiresContextSelection : requiresContextSelection // ignore: cast_nullable_to_non_nullable
as bool,availableContexts: null == availableContexts ? _self.availableContexts : availableContexts // ignore: cast_nullable_to_non_nullable
as List<AuthContext>,
  ));
}

}


/// Adds pattern-matching-related methods to [LoginResponse].
extension LoginResponsePatterns on LoginResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LoginResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LoginResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LoginResponse value)  $default,){
final _that = this;
switch (_that) {
case _LoginResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LoginResponse value)?  $default,){
final _that = this;
switch (_that) {
case _LoginResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? tokenType,  String? accessToken,  String? refreshToken,  int? expiresIn,  String? activeContextKey,  bool requiresContextSelection,  List<AuthContext> availableContexts)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LoginResponse() when $default != null:
return $default(_that.tokenType,_that.accessToken,_that.refreshToken,_that.expiresIn,_that.activeContextKey,_that.requiresContextSelection,_that.availableContexts);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? tokenType,  String? accessToken,  String? refreshToken,  int? expiresIn,  String? activeContextKey,  bool requiresContextSelection,  List<AuthContext> availableContexts)  $default,) {final _that = this;
switch (_that) {
case _LoginResponse():
return $default(_that.tokenType,_that.accessToken,_that.refreshToken,_that.expiresIn,_that.activeContextKey,_that.requiresContextSelection,_that.availableContexts);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? tokenType,  String? accessToken,  String? refreshToken,  int? expiresIn,  String? activeContextKey,  bool requiresContextSelection,  List<AuthContext> availableContexts)?  $default,) {final _that = this;
switch (_that) {
case _LoginResponse() when $default != null:
return $default(_that.tokenType,_that.accessToken,_that.refreshToken,_that.expiresIn,_that.activeContextKey,_that.requiresContextSelection,_that.availableContexts);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LoginResponse implements LoginResponse {
  const _LoginResponse({this.tokenType, this.accessToken, this.refreshToken, this.expiresIn, this.activeContextKey, this.requiresContextSelection = false, final  List<AuthContext> availableContexts = const <AuthContext>[]}): _availableContexts = availableContexts;
  factory _LoginResponse.fromJson(Map<String, dynamic> json) => _$LoginResponseFromJson(json);

@override final  String? tokenType;
@override final  String? accessToken;
@override final  String? refreshToken;
/// Access-token lifetime in seconds.
@override final  int? expiresIn;
@override final  String? activeContextKey;
/// True when the account has several contexts and the client must pick
/// one (re-submit login with `contextKey`) before a token is issued.
@override@JsonKey() final  bool requiresContextSelection;
 final  List<AuthContext> _availableContexts;
@override@JsonKey() List<AuthContext> get availableContexts {
  if (_availableContexts is EqualUnmodifiableListView) return _availableContexts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_availableContexts);
}


/// Create a copy of LoginResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LoginResponseCopyWith<_LoginResponse> get copyWith => __$LoginResponseCopyWithImpl<_LoginResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LoginResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LoginResponse&&(identical(other.tokenType, tokenType) || other.tokenType == tokenType)&&(identical(other.accessToken, accessToken) || other.accessToken == accessToken)&&(identical(other.refreshToken, refreshToken) || other.refreshToken == refreshToken)&&(identical(other.expiresIn, expiresIn) || other.expiresIn == expiresIn)&&(identical(other.activeContextKey, activeContextKey) || other.activeContextKey == activeContextKey)&&(identical(other.requiresContextSelection, requiresContextSelection) || other.requiresContextSelection == requiresContextSelection)&&const DeepCollectionEquality().equals(other._availableContexts, _availableContexts));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,tokenType,accessToken,refreshToken,expiresIn,activeContextKey,requiresContextSelection,const DeepCollectionEquality().hash(_availableContexts));

@override
String toString() {
  return 'LoginResponse(tokenType: $tokenType, accessToken: $accessToken, refreshToken: $refreshToken, expiresIn: $expiresIn, activeContextKey: $activeContextKey, requiresContextSelection: $requiresContextSelection, availableContexts: $availableContexts)';
}


}

/// @nodoc
abstract mixin class _$LoginResponseCopyWith<$Res> implements $LoginResponseCopyWith<$Res> {
  factory _$LoginResponseCopyWith(_LoginResponse value, $Res Function(_LoginResponse) _then) = __$LoginResponseCopyWithImpl;
@override @useResult
$Res call({
 String? tokenType, String? accessToken, String? refreshToken, int? expiresIn, String? activeContextKey, bool requiresContextSelection, List<AuthContext> availableContexts
});




}
/// @nodoc
class __$LoginResponseCopyWithImpl<$Res>
    implements _$LoginResponseCopyWith<$Res> {
  __$LoginResponseCopyWithImpl(this._self, this._then);

  final _LoginResponse _self;
  final $Res Function(_LoginResponse) _then;

/// Create a copy of LoginResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? tokenType = freezed,Object? accessToken = freezed,Object? refreshToken = freezed,Object? expiresIn = freezed,Object? activeContextKey = freezed,Object? requiresContextSelection = null,Object? availableContexts = null,}) {
  return _then(_LoginResponse(
tokenType: freezed == tokenType ? _self.tokenType : tokenType // ignore: cast_nullable_to_non_nullable
as String?,accessToken: freezed == accessToken ? _self.accessToken : accessToken // ignore: cast_nullable_to_non_nullable
as String?,refreshToken: freezed == refreshToken ? _self.refreshToken : refreshToken // ignore: cast_nullable_to_non_nullable
as String?,expiresIn: freezed == expiresIn ? _self.expiresIn : expiresIn // ignore: cast_nullable_to_non_nullable
as int?,activeContextKey: freezed == activeContextKey ? _self.activeContextKey : activeContextKey // ignore: cast_nullable_to_non_nullable
as String?,requiresContextSelection: null == requiresContextSelection ? _self.requiresContextSelection : requiresContextSelection // ignore: cast_nullable_to_non_nullable
as bool,availableContexts: null == availableContexts ? _self._availableContexts : availableContexts // ignore: cast_nullable_to_non_nullable
as List<AuthContext>,
  ));
}


}

// dart format on
