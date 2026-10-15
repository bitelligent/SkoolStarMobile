// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'child_attendance_record.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ChildAttendanceRecord {

 String get childId;/// Day of the session (date only).
 DateTime get date;/// `present` | `absent` | `late` | `unmarked` (see
/// `AttendanceStatusConfig`). Unknown server ids become `unmarked`.
 String get status; String get className; String get subjectName;/// `HH:mm`.
 String get startTime; String get endTime; String? get remarks; String? get occurrenceId;
/// Create a copy of ChildAttendanceRecord
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChildAttendanceRecordCopyWith<ChildAttendanceRecord> get copyWith => _$ChildAttendanceRecordCopyWithImpl<ChildAttendanceRecord>(this as ChildAttendanceRecord, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChildAttendanceRecord&&(identical(other.childId, childId) || other.childId == childId)&&(identical(other.date, date) || other.date == date)&&(identical(other.status, status) || other.status == status)&&(identical(other.className, className) || other.className == className)&&(identical(other.subjectName, subjectName) || other.subjectName == subjectName)&&(identical(other.startTime, startTime) || other.startTime == startTime)&&(identical(other.endTime, endTime) || other.endTime == endTime)&&(identical(other.remarks, remarks) || other.remarks == remarks)&&(identical(other.occurrenceId, occurrenceId) || other.occurrenceId == occurrenceId));
}


@override
int get hashCode => Object.hash(runtimeType,childId,date,status,className,subjectName,startTime,endTime,remarks,occurrenceId);

@override
String toString() {
  return 'ChildAttendanceRecord(childId: $childId, date: $date, status: $status, className: $className, subjectName: $subjectName, startTime: $startTime, endTime: $endTime, remarks: $remarks, occurrenceId: $occurrenceId)';
}


}

/// @nodoc
abstract mixin class $ChildAttendanceRecordCopyWith<$Res>  {
  factory $ChildAttendanceRecordCopyWith(ChildAttendanceRecord value, $Res Function(ChildAttendanceRecord) _then) = _$ChildAttendanceRecordCopyWithImpl;
@useResult
$Res call({
 String childId, DateTime date, String status, String className, String subjectName, String startTime, String endTime, String? remarks, String? occurrenceId
});




}
/// @nodoc
class _$ChildAttendanceRecordCopyWithImpl<$Res>
    implements $ChildAttendanceRecordCopyWith<$Res> {
  _$ChildAttendanceRecordCopyWithImpl(this._self, this._then);

  final ChildAttendanceRecord _self;
  final $Res Function(ChildAttendanceRecord) _then;

/// Create a copy of ChildAttendanceRecord
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? childId = null,Object? date = null,Object? status = null,Object? className = null,Object? subjectName = null,Object? startTime = null,Object? endTime = null,Object? remarks = freezed,Object? occurrenceId = freezed,}) {
  return _then(_self.copyWith(
childId: null == childId ? _self.childId : childId // ignore: cast_nullable_to_non_nullable
as String,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,className: null == className ? _self.className : className // ignore: cast_nullable_to_non_nullable
as String,subjectName: null == subjectName ? _self.subjectName : subjectName // ignore: cast_nullable_to_non_nullable
as String,startTime: null == startTime ? _self.startTime : startTime // ignore: cast_nullable_to_non_nullable
as String,endTime: null == endTime ? _self.endTime : endTime // ignore: cast_nullable_to_non_nullable
as String,remarks: freezed == remarks ? _self.remarks : remarks // ignore: cast_nullable_to_non_nullable
as String?,occurrenceId: freezed == occurrenceId ? _self.occurrenceId : occurrenceId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ChildAttendanceRecord].
extension ChildAttendanceRecordPatterns on ChildAttendanceRecord {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChildAttendanceRecord value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChildAttendanceRecord() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChildAttendanceRecord value)  $default,){
final _that = this;
switch (_that) {
case _ChildAttendanceRecord():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChildAttendanceRecord value)?  $default,){
final _that = this;
switch (_that) {
case _ChildAttendanceRecord() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String childId,  DateTime date,  String status,  String className,  String subjectName,  String startTime,  String endTime,  String? remarks,  String? occurrenceId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChildAttendanceRecord() when $default != null:
return $default(_that.childId,_that.date,_that.status,_that.className,_that.subjectName,_that.startTime,_that.endTime,_that.remarks,_that.occurrenceId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String childId,  DateTime date,  String status,  String className,  String subjectName,  String startTime,  String endTime,  String? remarks,  String? occurrenceId)  $default,) {final _that = this;
switch (_that) {
case _ChildAttendanceRecord():
return $default(_that.childId,_that.date,_that.status,_that.className,_that.subjectName,_that.startTime,_that.endTime,_that.remarks,_that.occurrenceId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String childId,  DateTime date,  String status,  String className,  String subjectName,  String startTime,  String endTime,  String? remarks,  String? occurrenceId)?  $default,) {final _that = this;
switch (_that) {
case _ChildAttendanceRecord() when $default != null:
return $default(_that.childId,_that.date,_that.status,_that.className,_that.subjectName,_that.startTime,_that.endTime,_that.remarks,_that.occurrenceId);case _:
  return null;

}
}

}

/// @nodoc


class _ChildAttendanceRecord implements ChildAttendanceRecord {
  const _ChildAttendanceRecord({required this.childId, required this.date, required this.status, this.className = '', this.subjectName = '', this.startTime = '', this.endTime = '', this.remarks, this.occurrenceId});
  

@override final  String childId;
/// Day of the session (date only).
@override final  DateTime date;
/// `present` | `absent` | `late` | `unmarked` (see
/// `AttendanceStatusConfig`). Unknown server ids become `unmarked`.
@override final  String status;
@override@JsonKey() final  String className;
@override@JsonKey() final  String subjectName;
/// `HH:mm`.
@override@JsonKey() final  String startTime;
@override@JsonKey() final  String endTime;
@override final  String? remarks;
@override final  String? occurrenceId;

/// Create a copy of ChildAttendanceRecord
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChildAttendanceRecordCopyWith<_ChildAttendanceRecord> get copyWith => __$ChildAttendanceRecordCopyWithImpl<_ChildAttendanceRecord>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChildAttendanceRecord&&(identical(other.childId, childId) || other.childId == childId)&&(identical(other.date, date) || other.date == date)&&(identical(other.status, status) || other.status == status)&&(identical(other.className, className) || other.className == className)&&(identical(other.subjectName, subjectName) || other.subjectName == subjectName)&&(identical(other.startTime, startTime) || other.startTime == startTime)&&(identical(other.endTime, endTime) || other.endTime == endTime)&&(identical(other.remarks, remarks) || other.remarks == remarks)&&(identical(other.occurrenceId, occurrenceId) || other.occurrenceId == occurrenceId));
}


@override
int get hashCode => Object.hash(runtimeType,childId,date,status,className,subjectName,startTime,endTime,remarks,occurrenceId);

@override
String toString() {
  return 'ChildAttendanceRecord(childId: $childId, date: $date, status: $status, className: $className, subjectName: $subjectName, startTime: $startTime, endTime: $endTime, remarks: $remarks, occurrenceId: $occurrenceId)';
}


}

/// @nodoc
abstract mixin class _$ChildAttendanceRecordCopyWith<$Res> implements $ChildAttendanceRecordCopyWith<$Res> {
  factory _$ChildAttendanceRecordCopyWith(_ChildAttendanceRecord value, $Res Function(_ChildAttendanceRecord) _then) = __$ChildAttendanceRecordCopyWithImpl;
@override @useResult
$Res call({
 String childId, DateTime date, String status, String className, String subjectName, String startTime, String endTime, String? remarks, String? occurrenceId
});




}
/// @nodoc
class __$ChildAttendanceRecordCopyWithImpl<$Res>
    implements _$ChildAttendanceRecordCopyWith<$Res> {
  __$ChildAttendanceRecordCopyWithImpl(this._self, this._then);

  final _ChildAttendanceRecord _self;
  final $Res Function(_ChildAttendanceRecord) _then;

/// Create a copy of ChildAttendanceRecord
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? childId = null,Object? date = null,Object? status = null,Object? className = null,Object? subjectName = null,Object? startTime = null,Object? endTime = null,Object? remarks = freezed,Object? occurrenceId = freezed,}) {
  return _then(_ChildAttendanceRecord(
childId: null == childId ? _self.childId : childId // ignore: cast_nullable_to_non_nullable
as String,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,className: null == className ? _self.className : className // ignore: cast_nullable_to_non_nullable
as String,subjectName: null == subjectName ? _self.subjectName : subjectName // ignore: cast_nullable_to_non_nullable
as String,startTime: null == startTime ? _self.startTime : startTime // ignore: cast_nullable_to_non_nullable
as String,endTime: null == endTime ? _self.endTime : endTime // ignore: cast_nullable_to_non_nullable
as String,remarks: freezed == remarks ? _self.remarks : remarks // ignore: cast_nullable_to_non_nullable
as String?,occurrenceId: freezed == occurrenceId ? _self.occurrenceId : occurrenceId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
