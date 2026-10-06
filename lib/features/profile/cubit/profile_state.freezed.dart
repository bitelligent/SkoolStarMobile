// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'profile_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ProfileState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProfileState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ProfileState()';
}


}

/// @nodoc
class $ProfileStateCopyWith<$Res>  {
$ProfileStateCopyWith(ProfileState _, $Res Function(ProfileState) __);
}


/// Adds pattern-matching-related methods to [ProfileState].
extension ProfileStatePatterns on ProfileState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( ProfileInitial value)?  initial,TResult Function( ProfileLoading value)?  loading,TResult Function( ProfileLoaded value)?  loaded,TResult Function( ProfileError value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case ProfileInitial() when initial != null:
return initial(_that);case ProfileLoading() when loading != null:
return loading(_that);case ProfileLoaded() when loaded != null:
return loaded(_that);case ProfileError() when error != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( ProfileInitial value)  initial,required TResult Function( ProfileLoading value)  loading,required TResult Function( ProfileLoaded value)  loaded,required TResult Function( ProfileError value)  error,}){
final _that = this;
switch (_that) {
case ProfileInitial():
return initial(_that);case ProfileLoading():
return loading(_that);case ProfileLoaded():
return loaded(_that);case ProfileError():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( ProfileInitial value)?  initial,TResult? Function( ProfileLoading value)?  loading,TResult? Function( ProfileLoaded value)?  loaded,TResult? Function( ProfileError value)?  error,}){
final _that = this;
switch (_that) {
case ProfileInitial() when initial != null:
return initial(_that);case ProfileLoading() when loading != null:
return loading(_that);case ProfileLoaded() when loaded != null:
return loaded(_that);case ProfileError() when error != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initial,TResult Function()?  loading,TResult Function( UserModel user,  bool changePasswordEnabled,  bool isSaving,  String firstNameDraft,  String lastNameDraft,  String currentPasswordDraft,  String newPasswordDraft,  String confirmPasswordDraft,  String? errorMessage)?  loaded,TResult Function( String message)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case ProfileInitial() when initial != null:
return initial();case ProfileLoading() when loading != null:
return loading();case ProfileLoaded() when loaded != null:
return loaded(_that.user,_that.changePasswordEnabled,_that.isSaving,_that.firstNameDraft,_that.lastNameDraft,_that.currentPasswordDraft,_that.newPasswordDraft,_that.confirmPasswordDraft,_that.errorMessage);case ProfileError() when error != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initial,required TResult Function()  loading,required TResult Function( UserModel user,  bool changePasswordEnabled,  bool isSaving,  String firstNameDraft,  String lastNameDraft,  String currentPasswordDraft,  String newPasswordDraft,  String confirmPasswordDraft,  String? errorMessage)  loaded,required TResult Function( String message)  error,}) {final _that = this;
switch (_that) {
case ProfileInitial():
return initial();case ProfileLoading():
return loading();case ProfileLoaded():
return loaded(_that.user,_that.changePasswordEnabled,_that.isSaving,_that.firstNameDraft,_that.lastNameDraft,_that.currentPasswordDraft,_that.newPasswordDraft,_that.confirmPasswordDraft,_that.errorMessage);case ProfileError():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initial,TResult? Function()?  loading,TResult? Function( UserModel user,  bool changePasswordEnabled,  bool isSaving,  String firstNameDraft,  String lastNameDraft,  String currentPasswordDraft,  String newPasswordDraft,  String confirmPasswordDraft,  String? errorMessage)?  loaded,TResult? Function( String message)?  error,}) {final _that = this;
switch (_that) {
case ProfileInitial() when initial != null:
return initial();case ProfileLoading() when loading != null:
return loading();case ProfileLoaded() when loaded != null:
return loaded(_that.user,_that.changePasswordEnabled,_that.isSaving,_that.firstNameDraft,_that.lastNameDraft,_that.currentPasswordDraft,_that.newPasswordDraft,_that.confirmPasswordDraft,_that.errorMessage);case ProfileError() when error != null:
return error(_that.message);case _:
  return null;

}
}

}

/// @nodoc


class ProfileInitial implements ProfileState {
  const ProfileInitial();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProfileInitial);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ProfileState.initial()';
}


}




/// @nodoc


class ProfileLoading implements ProfileState {
  const ProfileLoading();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProfileLoading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ProfileState.loading()';
}


}




/// @nodoc


class ProfileLoaded implements ProfileState {
  const ProfileLoaded({required this.user, this.changePasswordEnabled = false, this.isSaving = false, this.firstNameDraft = '', this.lastNameDraft = '', this.currentPasswordDraft = '', this.newPasswordDraft = '', this.confirmPasswordDraft = '', this.errorMessage});
  

 final  UserModel user;
@JsonKey() final  bool changePasswordEnabled;
@JsonKey() final  bool isSaving;
@JsonKey() final  String firstNameDraft;
@JsonKey() final  String lastNameDraft;
@JsonKey() final  String currentPasswordDraft;
@JsonKey() final  String newPasswordDraft;
@JsonKey() final  String confirmPasswordDraft;
 final  String? errorMessage;

/// Create a copy of ProfileState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProfileLoadedCopyWith<ProfileLoaded> get copyWith => _$ProfileLoadedCopyWithImpl<ProfileLoaded>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProfileLoaded&&(identical(other.user, user) || other.user == user)&&(identical(other.changePasswordEnabled, changePasswordEnabled) || other.changePasswordEnabled == changePasswordEnabled)&&(identical(other.isSaving, isSaving) || other.isSaving == isSaving)&&(identical(other.firstNameDraft, firstNameDraft) || other.firstNameDraft == firstNameDraft)&&(identical(other.lastNameDraft, lastNameDraft) || other.lastNameDraft == lastNameDraft)&&(identical(other.currentPasswordDraft, currentPasswordDraft) || other.currentPasswordDraft == currentPasswordDraft)&&(identical(other.newPasswordDraft, newPasswordDraft) || other.newPasswordDraft == newPasswordDraft)&&(identical(other.confirmPasswordDraft, confirmPasswordDraft) || other.confirmPasswordDraft == confirmPasswordDraft)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,user,changePasswordEnabled,isSaving,firstNameDraft,lastNameDraft,currentPasswordDraft,newPasswordDraft,confirmPasswordDraft,errorMessage);

@override
String toString() {
  return 'ProfileState.loaded(user: $user, changePasswordEnabled: $changePasswordEnabled, isSaving: $isSaving, firstNameDraft: $firstNameDraft, lastNameDraft: $lastNameDraft, currentPasswordDraft: $currentPasswordDraft, newPasswordDraft: $newPasswordDraft, confirmPasswordDraft: $confirmPasswordDraft, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class $ProfileLoadedCopyWith<$Res> implements $ProfileStateCopyWith<$Res> {
  factory $ProfileLoadedCopyWith(ProfileLoaded value, $Res Function(ProfileLoaded) _then) = _$ProfileLoadedCopyWithImpl;
@useResult
$Res call({
 UserModel user, bool changePasswordEnabled, bool isSaving, String firstNameDraft, String lastNameDraft, String currentPasswordDraft, String newPasswordDraft, String confirmPasswordDraft, String? errorMessage
});


$UserModelCopyWith<$Res> get user;

}
/// @nodoc
class _$ProfileLoadedCopyWithImpl<$Res>
    implements $ProfileLoadedCopyWith<$Res> {
  _$ProfileLoadedCopyWithImpl(this._self, this._then);

  final ProfileLoaded _self;
  final $Res Function(ProfileLoaded) _then;

/// Create a copy of ProfileState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? user = null,Object? changePasswordEnabled = null,Object? isSaving = null,Object? firstNameDraft = null,Object? lastNameDraft = null,Object? currentPasswordDraft = null,Object? newPasswordDraft = null,Object? confirmPasswordDraft = null,Object? errorMessage = freezed,}) {
  return _then(ProfileLoaded(
user: null == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as UserModel,changePasswordEnabled: null == changePasswordEnabled ? _self.changePasswordEnabled : changePasswordEnabled // ignore: cast_nullable_to_non_nullable
as bool,isSaving: null == isSaving ? _self.isSaving : isSaving // ignore: cast_nullable_to_non_nullable
as bool,firstNameDraft: null == firstNameDraft ? _self.firstNameDraft : firstNameDraft // ignore: cast_nullable_to_non_nullable
as String,lastNameDraft: null == lastNameDraft ? _self.lastNameDraft : lastNameDraft // ignore: cast_nullable_to_non_nullable
as String,currentPasswordDraft: null == currentPasswordDraft ? _self.currentPasswordDraft : currentPasswordDraft // ignore: cast_nullable_to_non_nullable
as String,newPasswordDraft: null == newPasswordDraft ? _self.newPasswordDraft : newPasswordDraft // ignore: cast_nullable_to_non_nullable
as String,confirmPasswordDraft: null == confirmPasswordDraft ? _self.confirmPasswordDraft : confirmPasswordDraft // ignore: cast_nullable_to_non_nullable
as String,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of ProfileState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserModelCopyWith<$Res> get user {
  
  return $UserModelCopyWith<$Res>(_self.user, (value) {
    return _then(_self.copyWith(user: value));
  });
}
}

/// @nodoc


class ProfileError implements ProfileState {
  const ProfileError(this.message);
  

 final  String message;

/// Create a copy of ProfileState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProfileErrorCopyWith<ProfileError> get copyWith => _$ProfileErrorCopyWithImpl<ProfileError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProfileError&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'ProfileState.error(message: $message)';
}


}

/// @nodoc
abstract mixin class $ProfileErrorCopyWith<$Res> implements $ProfileStateCopyWith<$Res> {
  factory $ProfileErrorCopyWith(ProfileError value, $Res Function(ProfileError) _then) = _$ProfileErrorCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class _$ProfileErrorCopyWithImpl<$Res>
    implements $ProfileErrorCopyWith<$Res> {
  _$ProfileErrorCopyWithImpl(this._self, this._then);

  final ProfileError _self;
  final $Res Function(ProfileError) _then;

/// Create a copy of ProfileState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(ProfileError(
null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
