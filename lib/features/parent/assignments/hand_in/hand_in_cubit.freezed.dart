// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'hand_in_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$HandInFile {

 int get id; PickedAttachment get source; UploadStatus get status;/// Set once the server has stored it; kept across retries so a file is
/// never uploaded twice.
 SubmissionFile? get stored;/// Why the upload failed.
 String? get error;
/// Create a copy of HandInFile
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HandInFileCopyWith<HandInFile> get copyWith => _$HandInFileCopyWithImpl<HandInFile>(this as HandInFile, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HandInFile&&(identical(other.id, id) || other.id == id)&&(identical(other.source, source) || other.source == source)&&(identical(other.status, status) || other.status == status)&&(identical(other.stored, stored) || other.stored == stored)&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode => Object.hash(runtimeType,id,source,status,stored,error);

@override
String toString() {
  return 'HandInFile(id: $id, source: $source, status: $status, stored: $stored, error: $error)';
}


}

/// @nodoc
abstract mixin class $HandInFileCopyWith<$Res>  {
  factory $HandInFileCopyWith(HandInFile value, $Res Function(HandInFile) _then) = _$HandInFileCopyWithImpl;
@useResult
$Res call({
 int id, PickedAttachment source, UploadStatus status, SubmissionFile? stored, String? error
});




}
/// @nodoc
class _$HandInFileCopyWithImpl<$Res>
    implements $HandInFileCopyWith<$Res> {
  _$HandInFileCopyWithImpl(this._self, this._then);

  final HandInFile _self;
  final $Res Function(HandInFile) _then;

/// Create a copy of HandInFile
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? source = null,Object? status = null,Object? stored = freezed,Object? error = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as PickedAttachment,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as UploadStatus,stored: freezed == stored ? _self.stored : stored // ignore: cast_nullable_to_non_nullable
as SubmissionFile?,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [HandInFile].
extension HandInFilePatterns on HandInFile {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HandInFile value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HandInFile() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HandInFile value)  $default,){
final _that = this;
switch (_that) {
case _HandInFile():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HandInFile value)?  $default,){
final _that = this;
switch (_that) {
case _HandInFile() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  PickedAttachment source,  UploadStatus status,  SubmissionFile? stored,  String? error)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HandInFile() when $default != null:
return $default(_that.id,_that.source,_that.status,_that.stored,_that.error);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  PickedAttachment source,  UploadStatus status,  SubmissionFile? stored,  String? error)  $default,) {final _that = this;
switch (_that) {
case _HandInFile():
return $default(_that.id,_that.source,_that.status,_that.stored,_that.error);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  PickedAttachment source,  UploadStatus status,  SubmissionFile? stored,  String? error)?  $default,) {final _that = this;
switch (_that) {
case _HandInFile() when $default != null:
return $default(_that.id,_that.source,_that.status,_that.stored,_that.error);case _:
  return null;

}
}

}

/// @nodoc


class _HandInFile implements HandInFile {
  const _HandInFile({required this.id, required this.source, this.status = UploadStatus.waiting, this.stored, this.error});
  

@override final  int id;
@override final  PickedAttachment source;
@override@JsonKey() final  UploadStatus status;
/// Set once the server has stored it; kept across retries so a file is
/// never uploaded twice.
@override final  SubmissionFile? stored;
/// Why the upload failed.
@override final  String? error;

/// Create a copy of HandInFile
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HandInFileCopyWith<_HandInFile> get copyWith => __$HandInFileCopyWithImpl<_HandInFile>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _HandInFile&&(identical(other.id, id) || other.id == id)&&(identical(other.source, source) || other.source == source)&&(identical(other.status, status) || other.status == status)&&(identical(other.stored, stored) || other.stored == stored)&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode => Object.hash(runtimeType,id,source,status,stored,error);

@override
String toString() {
  return 'HandInFile(id: $id, source: $source, status: $status, stored: $stored, error: $error)';
}


}

/// @nodoc
abstract mixin class _$HandInFileCopyWith<$Res> implements $HandInFileCopyWith<$Res> {
  factory _$HandInFileCopyWith(_HandInFile value, $Res Function(_HandInFile) _then) = __$HandInFileCopyWithImpl;
@override @useResult
$Res call({
 int id, PickedAttachment source, UploadStatus status, SubmissionFile? stored, String? error
});




}
/// @nodoc
class __$HandInFileCopyWithImpl<$Res>
    implements _$HandInFileCopyWith<$Res> {
  __$HandInFileCopyWithImpl(this._self, this._then);

  final _HandInFile _self;
  final $Res Function(_HandInFile) _then;

/// Create a copy of HandInFile
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? source = null,Object? status = null,Object? stored = freezed,Object? error = freezed,}) {
  return _then(_HandInFile(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as PickedAttachment,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as UploadStatus,stored: freezed == stored ? _self.stored : stored // ignore: cast_nullable_to_non_nullable
as SubmissionFile?,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc
mixin _$HandInState {

 List<HandInFile> get files; List<String> get links; String get note;/// Uploading or submitting: nothing may change meanwhile.
 bool get busy;/// Something the guardian should read, e.g. why a file was refused.
 String? get error;/// Set once the server recorded the hand-in.
 DateTime? get completedAt;
/// Create a copy of HandInState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HandInStateCopyWith<HandInState> get copyWith => _$HandInStateCopyWithImpl<HandInState>(this as HandInState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HandInState&&const DeepCollectionEquality().equals(other.files, files)&&const DeepCollectionEquality().equals(other.links, links)&&(identical(other.note, note) || other.note == note)&&(identical(other.busy, busy) || other.busy == busy)&&(identical(other.error, error) || other.error == error)&&(identical(other.completedAt, completedAt) || other.completedAt == completedAt));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(files),const DeepCollectionEquality().hash(links),note,busy,error,completedAt);

@override
String toString() {
  return 'HandInState(files: $files, links: $links, note: $note, busy: $busy, error: $error, completedAt: $completedAt)';
}


}

/// @nodoc
abstract mixin class $HandInStateCopyWith<$Res>  {
  factory $HandInStateCopyWith(HandInState value, $Res Function(HandInState) _then) = _$HandInStateCopyWithImpl;
@useResult
$Res call({
 List<HandInFile> files, List<String> links, String note, bool busy, String? error, DateTime? completedAt
});




}
/// @nodoc
class _$HandInStateCopyWithImpl<$Res>
    implements $HandInStateCopyWith<$Res> {
  _$HandInStateCopyWithImpl(this._self, this._then);

  final HandInState _self;
  final $Res Function(HandInState) _then;

/// Create a copy of HandInState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? files = null,Object? links = null,Object? note = null,Object? busy = null,Object? error = freezed,Object? completedAt = freezed,}) {
  return _then(_self.copyWith(
files: null == files ? _self.files : files // ignore: cast_nullable_to_non_nullable
as List<HandInFile>,links: null == links ? _self.links : links // ignore: cast_nullable_to_non_nullable
as List<String>,note: null == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String,busy: null == busy ? _self.busy : busy // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,completedAt: freezed == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [HandInState].
extension HandInStatePatterns on HandInState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HandInState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HandInState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HandInState value)  $default,){
final _that = this;
switch (_that) {
case _HandInState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HandInState value)?  $default,){
final _that = this;
switch (_that) {
case _HandInState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<HandInFile> files,  List<String> links,  String note,  bool busy,  String? error,  DateTime? completedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HandInState() when $default != null:
return $default(_that.files,_that.links,_that.note,_that.busy,_that.error,_that.completedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<HandInFile> files,  List<String> links,  String note,  bool busy,  String? error,  DateTime? completedAt)  $default,) {final _that = this;
switch (_that) {
case _HandInState():
return $default(_that.files,_that.links,_that.note,_that.busy,_that.error,_that.completedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<HandInFile> files,  List<String> links,  String note,  bool busy,  String? error,  DateTime? completedAt)?  $default,) {final _that = this;
switch (_that) {
case _HandInState() when $default != null:
return $default(_that.files,_that.links,_that.note,_that.busy,_that.error,_that.completedAt);case _:
  return null;

}
}

}

/// @nodoc


class _HandInState extends HandInState {
  const _HandInState({final  List<HandInFile> files = const <HandInFile>[], final  List<String> links = const <String>[], this.note = '', this.busy = false, this.error, this.completedAt}): _files = files,_links = links,super._();
  

 final  List<HandInFile> _files;
@override@JsonKey() List<HandInFile> get files {
  if (_files is EqualUnmodifiableListView) return _files;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_files);
}

 final  List<String> _links;
@override@JsonKey() List<String> get links {
  if (_links is EqualUnmodifiableListView) return _links;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_links);
}

@override@JsonKey() final  String note;
/// Uploading or submitting: nothing may change meanwhile.
@override@JsonKey() final  bool busy;
/// Something the guardian should read, e.g. why a file was refused.
@override final  String? error;
/// Set once the server recorded the hand-in.
@override final  DateTime? completedAt;

/// Create a copy of HandInState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HandInStateCopyWith<_HandInState> get copyWith => __$HandInStateCopyWithImpl<_HandInState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _HandInState&&const DeepCollectionEquality().equals(other._files, _files)&&const DeepCollectionEquality().equals(other._links, _links)&&(identical(other.note, note) || other.note == note)&&(identical(other.busy, busy) || other.busy == busy)&&(identical(other.error, error) || other.error == error)&&(identical(other.completedAt, completedAt) || other.completedAt == completedAt));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_files),const DeepCollectionEquality().hash(_links),note,busy,error,completedAt);

@override
String toString() {
  return 'HandInState(files: $files, links: $links, note: $note, busy: $busy, error: $error, completedAt: $completedAt)';
}


}

/// @nodoc
abstract mixin class _$HandInStateCopyWith<$Res> implements $HandInStateCopyWith<$Res> {
  factory _$HandInStateCopyWith(_HandInState value, $Res Function(_HandInState) _then) = __$HandInStateCopyWithImpl;
@override @useResult
$Res call({
 List<HandInFile> files, List<String> links, String note, bool busy, String? error, DateTime? completedAt
});




}
/// @nodoc
class __$HandInStateCopyWithImpl<$Res>
    implements _$HandInStateCopyWith<$Res> {
  __$HandInStateCopyWithImpl(this._self, this._then);

  final _HandInState _self;
  final $Res Function(_HandInState) _then;

/// Create a copy of HandInState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? files = null,Object? links = null,Object? note = null,Object? busy = null,Object? error = freezed,Object? completedAt = freezed,}) {
  return _then(_HandInState(
files: null == files ? _self._files : files // ignore: cast_nullable_to_non_nullable
as List<HandInFile>,links: null == links ? _self._links : links // ignore: cast_nullable_to_non_nullable
as List<String>,note: null == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String,busy: null == busy ? _self.busy : busy // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,completedAt: freezed == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
