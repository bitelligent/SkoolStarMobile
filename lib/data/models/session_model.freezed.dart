// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'session_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Session {

/// The occurrence's public GUID. Used for routing and API lookups.
 String get id; DateTime get date;/// `HH:mm`, local time.
 String get startTime; String get endTime; List<String> get classIds; List<String> get subjectIds; String get teacherId;/// Cancelled / otherwise not open for editing.
 bool get isLocked;/// Numeric occurrence id and parent schedule id, required by the
/// attendance / homework / feedback endpoints.
 int get occurrenceId; int get scheduleId; int? get sectionId;
/// Create a copy of Session
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SessionCopyWith<Session> get copyWith => _$SessionCopyWithImpl<Session>(this as Session, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Session&&(identical(other.id, id) || other.id == id)&&(identical(other.date, date) || other.date == date)&&(identical(other.startTime, startTime) || other.startTime == startTime)&&(identical(other.endTime, endTime) || other.endTime == endTime)&&const DeepCollectionEquality().equals(other.classIds, classIds)&&const DeepCollectionEquality().equals(other.subjectIds, subjectIds)&&(identical(other.teacherId, teacherId) || other.teacherId == teacherId)&&(identical(other.isLocked, isLocked) || other.isLocked == isLocked)&&(identical(other.occurrenceId, occurrenceId) || other.occurrenceId == occurrenceId)&&(identical(other.scheduleId, scheduleId) || other.scheduleId == scheduleId)&&(identical(other.sectionId, sectionId) || other.sectionId == sectionId));
}


@override
int get hashCode => Object.hash(runtimeType,id,date,startTime,endTime,const DeepCollectionEquality().hash(classIds),const DeepCollectionEquality().hash(subjectIds),teacherId,isLocked,occurrenceId,scheduleId,sectionId);

@override
String toString() {
  return 'Session(id: $id, date: $date, startTime: $startTime, endTime: $endTime, classIds: $classIds, subjectIds: $subjectIds, teacherId: $teacherId, isLocked: $isLocked, occurrenceId: $occurrenceId, scheduleId: $scheduleId, sectionId: $sectionId)';
}


}

/// @nodoc
abstract mixin class $SessionCopyWith<$Res>  {
  factory $SessionCopyWith(Session value, $Res Function(Session) _then) = _$SessionCopyWithImpl;
@useResult
$Res call({
 String id, DateTime date, String startTime, String endTime, List<String> classIds, List<String> subjectIds, String teacherId, bool isLocked, int occurrenceId, int scheduleId, int? sectionId
});




}
/// @nodoc
class _$SessionCopyWithImpl<$Res>
    implements $SessionCopyWith<$Res> {
  _$SessionCopyWithImpl(this._self, this._then);

  final Session _self;
  final $Res Function(Session) _then;

/// Create a copy of Session
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? date = null,Object? startTime = null,Object? endTime = null,Object? classIds = null,Object? subjectIds = null,Object? teacherId = null,Object? isLocked = null,Object? occurrenceId = null,Object? scheduleId = null,Object? sectionId = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,startTime: null == startTime ? _self.startTime : startTime // ignore: cast_nullable_to_non_nullable
as String,endTime: null == endTime ? _self.endTime : endTime // ignore: cast_nullable_to_non_nullable
as String,classIds: null == classIds ? _self.classIds : classIds // ignore: cast_nullable_to_non_nullable
as List<String>,subjectIds: null == subjectIds ? _self.subjectIds : subjectIds // ignore: cast_nullable_to_non_nullable
as List<String>,teacherId: null == teacherId ? _self.teacherId : teacherId // ignore: cast_nullable_to_non_nullable
as String,isLocked: null == isLocked ? _self.isLocked : isLocked // ignore: cast_nullable_to_non_nullable
as bool,occurrenceId: null == occurrenceId ? _self.occurrenceId : occurrenceId // ignore: cast_nullable_to_non_nullable
as int,scheduleId: null == scheduleId ? _self.scheduleId : scheduleId // ignore: cast_nullable_to_non_nullable
as int,sectionId: freezed == sectionId ? _self.sectionId : sectionId // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [Session].
extension SessionPatterns on Session {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Session value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Session() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Session value)  $default,){
final _that = this;
switch (_that) {
case _Session():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Session value)?  $default,){
final _that = this;
switch (_that) {
case _Session() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  DateTime date,  String startTime,  String endTime,  List<String> classIds,  List<String> subjectIds,  String teacherId,  bool isLocked,  int occurrenceId,  int scheduleId,  int? sectionId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Session() when $default != null:
return $default(_that.id,_that.date,_that.startTime,_that.endTime,_that.classIds,_that.subjectIds,_that.teacherId,_that.isLocked,_that.occurrenceId,_that.scheduleId,_that.sectionId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  DateTime date,  String startTime,  String endTime,  List<String> classIds,  List<String> subjectIds,  String teacherId,  bool isLocked,  int occurrenceId,  int scheduleId,  int? sectionId)  $default,) {final _that = this;
switch (_that) {
case _Session():
return $default(_that.id,_that.date,_that.startTime,_that.endTime,_that.classIds,_that.subjectIds,_that.teacherId,_that.isLocked,_that.occurrenceId,_that.scheduleId,_that.sectionId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  DateTime date,  String startTime,  String endTime,  List<String> classIds,  List<String> subjectIds,  String teacherId,  bool isLocked,  int occurrenceId,  int scheduleId,  int? sectionId)?  $default,) {final _that = this;
switch (_that) {
case _Session() when $default != null:
return $default(_that.id,_that.date,_that.startTime,_that.endTime,_that.classIds,_that.subjectIds,_that.teacherId,_that.isLocked,_that.occurrenceId,_that.scheduleId,_that.sectionId);case _:
  return null;

}
}

}

/// @nodoc


class _Session extends Session {
  const _Session({required this.id, required this.date, required this.startTime, required this.endTime, required final  List<String> classIds, required final  List<String> subjectIds, required this.teacherId, this.isLocked = false, this.occurrenceId = 0, this.scheduleId = 0, this.sectionId}): _classIds = classIds,_subjectIds = subjectIds,super._();
  

/// The occurrence's public GUID. Used for routing and API lookups.
@override final  String id;
@override final  DateTime date;
/// `HH:mm`, local time.
@override final  String startTime;
@override final  String endTime;
 final  List<String> _classIds;
@override List<String> get classIds {
  if (_classIds is EqualUnmodifiableListView) return _classIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_classIds);
}

 final  List<String> _subjectIds;
@override List<String> get subjectIds {
  if (_subjectIds is EqualUnmodifiableListView) return _subjectIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_subjectIds);
}

@override final  String teacherId;
/// Cancelled / otherwise not open for editing.
@override@JsonKey() final  bool isLocked;
/// Numeric occurrence id and parent schedule id, required by the
/// attendance / homework / feedback endpoints.
@override@JsonKey() final  int occurrenceId;
@override@JsonKey() final  int scheduleId;
@override final  int? sectionId;

/// Create a copy of Session
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SessionCopyWith<_Session> get copyWith => __$SessionCopyWithImpl<_Session>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Session&&(identical(other.id, id) || other.id == id)&&(identical(other.date, date) || other.date == date)&&(identical(other.startTime, startTime) || other.startTime == startTime)&&(identical(other.endTime, endTime) || other.endTime == endTime)&&const DeepCollectionEquality().equals(other._classIds, _classIds)&&const DeepCollectionEquality().equals(other._subjectIds, _subjectIds)&&(identical(other.teacherId, teacherId) || other.teacherId == teacherId)&&(identical(other.isLocked, isLocked) || other.isLocked == isLocked)&&(identical(other.occurrenceId, occurrenceId) || other.occurrenceId == occurrenceId)&&(identical(other.scheduleId, scheduleId) || other.scheduleId == scheduleId)&&(identical(other.sectionId, sectionId) || other.sectionId == sectionId));
}


@override
int get hashCode => Object.hash(runtimeType,id,date,startTime,endTime,const DeepCollectionEquality().hash(_classIds),const DeepCollectionEquality().hash(_subjectIds),teacherId,isLocked,occurrenceId,scheduleId,sectionId);

@override
String toString() {
  return 'Session(id: $id, date: $date, startTime: $startTime, endTime: $endTime, classIds: $classIds, subjectIds: $subjectIds, teacherId: $teacherId, isLocked: $isLocked, occurrenceId: $occurrenceId, scheduleId: $scheduleId, sectionId: $sectionId)';
}


}

/// @nodoc
abstract mixin class _$SessionCopyWith<$Res> implements $SessionCopyWith<$Res> {
  factory _$SessionCopyWith(_Session value, $Res Function(_Session) _then) = __$SessionCopyWithImpl;
@override @useResult
$Res call({
 String id, DateTime date, String startTime, String endTime, List<String> classIds, List<String> subjectIds, String teacherId, bool isLocked, int occurrenceId, int scheduleId, int? sectionId
});




}
/// @nodoc
class __$SessionCopyWithImpl<$Res>
    implements _$SessionCopyWith<$Res> {
  __$SessionCopyWithImpl(this._self, this._then);

  final _Session _self;
  final $Res Function(_Session) _then;

/// Create a copy of Session
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? date = null,Object? startTime = null,Object? endTime = null,Object? classIds = null,Object? subjectIds = null,Object? teacherId = null,Object? isLocked = null,Object? occurrenceId = null,Object? scheduleId = null,Object? sectionId = freezed,}) {
  return _then(_Session(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,startTime: null == startTime ? _self.startTime : startTime // ignore: cast_nullable_to_non_nullable
as String,endTime: null == endTime ? _self.endTime : endTime // ignore: cast_nullable_to_non_nullable
as String,classIds: null == classIds ? _self._classIds : classIds // ignore: cast_nullable_to_non_nullable
as List<String>,subjectIds: null == subjectIds ? _self._subjectIds : subjectIds // ignore: cast_nullable_to_non_nullable
as List<String>,teacherId: null == teacherId ? _self.teacherId : teacherId // ignore: cast_nullable_to_non_nullable
as String,isLocked: null == isLocked ? _self.isLocked : isLocked // ignore: cast_nullable_to_non_nullable
as bool,occurrenceId: null == occurrenceId ? _self.occurrenceId : occurrenceId // ignore: cast_nullable_to_non_nullable
as int,scheduleId: null == scheduleId ? _self.scheduleId : scheduleId // ignore: cast_nullable_to_non_nullable
as int,sectionId: freezed == sectionId ? _self.sectionId : sectionId // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on
