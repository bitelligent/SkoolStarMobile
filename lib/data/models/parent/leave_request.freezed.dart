// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'leave_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$LeaveRequest {

 String get id; String get childId; String get childName; DateTime get startDate; DateTime get endDate; String get reason; LeaveStatus get status; String get className;/// Inclusive days, calculated by the server.
 int get durationDays;/// Why an admin approved / rejected it, when they said.
 String? get decisionReason; DateTime? get submittedAt; DateTime? get decidedAt;
/// Create a copy of LeaveRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LeaveRequestCopyWith<LeaveRequest> get copyWith => _$LeaveRequestCopyWithImpl<LeaveRequest>(this as LeaveRequest, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LeaveRequest&&(identical(other.id, id) || other.id == id)&&(identical(other.childId, childId) || other.childId == childId)&&(identical(other.childName, childName) || other.childName == childName)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.endDate, endDate) || other.endDate == endDate)&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.status, status) || other.status == status)&&(identical(other.className, className) || other.className == className)&&(identical(other.durationDays, durationDays) || other.durationDays == durationDays)&&(identical(other.decisionReason, decisionReason) || other.decisionReason == decisionReason)&&(identical(other.submittedAt, submittedAt) || other.submittedAt == submittedAt)&&(identical(other.decidedAt, decidedAt) || other.decidedAt == decidedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,childId,childName,startDate,endDate,reason,status,className,durationDays,decisionReason,submittedAt,decidedAt);

@override
String toString() {
  return 'LeaveRequest(id: $id, childId: $childId, childName: $childName, startDate: $startDate, endDate: $endDate, reason: $reason, status: $status, className: $className, durationDays: $durationDays, decisionReason: $decisionReason, submittedAt: $submittedAt, decidedAt: $decidedAt)';
}


}

/// @nodoc
abstract mixin class $LeaveRequestCopyWith<$Res>  {
  factory $LeaveRequestCopyWith(LeaveRequest value, $Res Function(LeaveRequest) _then) = _$LeaveRequestCopyWithImpl;
@useResult
$Res call({
 String id, String childId, String childName, DateTime startDate, DateTime endDate, String reason, LeaveStatus status, String className, int durationDays, String? decisionReason, DateTime? submittedAt, DateTime? decidedAt
});




}
/// @nodoc
class _$LeaveRequestCopyWithImpl<$Res>
    implements $LeaveRequestCopyWith<$Res> {
  _$LeaveRequestCopyWithImpl(this._self, this._then);

  final LeaveRequest _self;
  final $Res Function(LeaveRequest) _then;

/// Create a copy of LeaveRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? childId = null,Object? childName = null,Object? startDate = null,Object? endDate = null,Object? reason = null,Object? status = null,Object? className = null,Object? durationDays = null,Object? decisionReason = freezed,Object? submittedAt = freezed,Object? decidedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,childId: null == childId ? _self.childId : childId // ignore: cast_nullable_to_non_nullable
as String,childName: null == childName ? _self.childName : childName // ignore: cast_nullable_to_non_nullable
as String,startDate: null == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime,endDate: null == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as DateTime,reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as LeaveStatus,className: null == className ? _self.className : className // ignore: cast_nullable_to_non_nullable
as String,durationDays: null == durationDays ? _self.durationDays : durationDays // ignore: cast_nullable_to_non_nullable
as int,decisionReason: freezed == decisionReason ? _self.decisionReason : decisionReason // ignore: cast_nullable_to_non_nullable
as String?,submittedAt: freezed == submittedAt ? _self.submittedAt : submittedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,decidedAt: freezed == decidedAt ? _self.decidedAt : decidedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [LeaveRequest].
extension LeaveRequestPatterns on LeaveRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LeaveRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LeaveRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LeaveRequest value)  $default,){
final _that = this;
switch (_that) {
case _LeaveRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LeaveRequest value)?  $default,){
final _that = this;
switch (_that) {
case _LeaveRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String childId,  String childName,  DateTime startDate,  DateTime endDate,  String reason,  LeaveStatus status,  String className,  int durationDays,  String? decisionReason,  DateTime? submittedAt,  DateTime? decidedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LeaveRequest() when $default != null:
return $default(_that.id,_that.childId,_that.childName,_that.startDate,_that.endDate,_that.reason,_that.status,_that.className,_that.durationDays,_that.decisionReason,_that.submittedAt,_that.decidedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String childId,  String childName,  DateTime startDate,  DateTime endDate,  String reason,  LeaveStatus status,  String className,  int durationDays,  String? decisionReason,  DateTime? submittedAt,  DateTime? decidedAt)  $default,) {final _that = this;
switch (_that) {
case _LeaveRequest():
return $default(_that.id,_that.childId,_that.childName,_that.startDate,_that.endDate,_that.reason,_that.status,_that.className,_that.durationDays,_that.decisionReason,_that.submittedAt,_that.decidedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String childId,  String childName,  DateTime startDate,  DateTime endDate,  String reason,  LeaveStatus status,  String className,  int durationDays,  String? decisionReason,  DateTime? submittedAt,  DateTime? decidedAt)?  $default,) {final _that = this;
switch (_that) {
case _LeaveRequest() when $default != null:
return $default(_that.id,_that.childId,_that.childName,_that.startDate,_that.endDate,_that.reason,_that.status,_that.className,_that.durationDays,_that.decisionReason,_that.submittedAt,_that.decidedAt);case _:
  return null;

}
}

}

/// @nodoc


class _LeaveRequest extends LeaveRequest {
  const _LeaveRequest({required this.id, required this.childId, required this.childName, required this.startDate, required this.endDate, required this.reason, required this.status, this.className = '', this.durationDays = 1, this.decisionReason, this.submittedAt, this.decidedAt}): super._();
  

@override final  String id;
@override final  String childId;
@override final  String childName;
@override final  DateTime startDate;
@override final  DateTime endDate;
@override final  String reason;
@override final  LeaveStatus status;
@override@JsonKey() final  String className;
/// Inclusive days, calculated by the server.
@override@JsonKey() final  int durationDays;
/// Why an admin approved / rejected it, when they said.
@override final  String? decisionReason;
@override final  DateTime? submittedAt;
@override final  DateTime? decidedAt;

/// Create a copy of LeaveRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LeaveRequestCopyWith<_LeaveRequest> get copyWith => __$LeaveRequestCopyWithImpl<_LeaveRequest>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LeaveRequest&&(identical(other.id, id) || other.id == id)&&(identical(other.childId, childId) || other.childId == childId)&&(identical(other.childName, childName) || other.childName == childName)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.endDate, endDate) || other.endDate == endDate)&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.status, status) || other.status == status)&&(identical(other.className, className) || other.className == className)&&(identical(other.durationDays, durationDays) || other.durationDays == durationDays)&&(identical(other.decisionReason, decisionReason) || other.decisionReason == decisionReason)&&(identical(other.submittedAt, submittedAt) || other.submittedAt == submittedAt)&&(identical(other.decidedAt, decidedAt) || other.decidedAt == decidedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,childId,childName,startDate,endDate,reason,status,className,durationDays,decisionReason,submittedAt,decidedAt);

@override
String toString() {
  return 'LeaveRequest(id: $id, childId: $childId, childName: $childName, startDate: $startDate, endDate: $endDate, reason: $reason, status: $status, className: $className, durationDays: $durationDays, decisionReason: $decisionReason, submittedAt: $submittedAt, decidedAt: $decidedAt)';
}


}

/// @nodoc
abstract mixin class _$LeaveRequestCopyWith<$Res> implements $LeaveRequestCopyWith<$Res> {
  factory _$LeaveRequestCopyWith(_LeaveRequest value, $Res Function(_LeaveRequest) _then) = __$LeaveRequestCopyWithImpl;
@override @useResult
$Res call({
 String id, String childId, String childName, DateTime startDate, DateTime endDate, String reason, LeaveStatus status, String className, int durationDays, String? decisionReason, DateTime? submittedAt, DateTime? decidedAt
});




}
/// @nodoc
class __$LeaveRequestCopyWithImpl<$Res>
    implements _$LeaveRequestCopyWith<$Res> {
  __$LeaveRequestCopyWithImpl(this._self, this._then);

  final _LeaveRequest _self;
  final $Res Function(_LeaveRequest) _then;

/// Create a copy of LeaveRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? childId = null,Object? childName = null,Object? startDate = null,Object? endDate = null,Object? reason = null,Object? status = null,Object? className = null,Object? durationDays = null,Object? decisionReason = freezed,Object? submittedAt = freezed,Object? decidedAt = freezed,}) {
  return _then(_LeaveRequest(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,childId: null == childId ? _self.childId : childId // ignore: cast_nullable_to_non_nullable
as String,childName: null == childName ? _self.childName : childName // ignore: cast_nullable_to_non_nullable
as String,startDate: null == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime,endDate: null == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as DateTime,reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as LeaveStatus,className: null == className ? _self.className : className // ignore: cast_nullable_to_non_nullable
as String,durationDays: null == durationDays ? _self.durationDays : durationDays // ignore: cast_nullable_to_non_nullable
as int,decisionReason: freezed == decisionReason ? _self.decisionReason : decisionReason // ignore: cast_nullable_to_non_nullable
as String?,submittedAt: freezed == submittedAt ? _self.submittedAt : submittedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,decidedAt: freezed == decidedAt ? _self.decidedAt : decidedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

/// @nodoc
mixin _$LeavePage {

 List<LeaveRequest> get items; int get pageNumber; int get totalCount; bool get hasNextPage;
/// Create a copy of LeavePage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LeavePageCopyWith<LeavePage> get copyWith => _$LeavePageCopyWithImpl<LeavePage>(this as LeavePage, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LeavePage&&const DeepCollectionEquality().equals(other.items, items)&&(identical(other.pageNumber, pageNumber) || other.pageNumber == pageNumber)&&(identical(other.totalCount, totalCount) || other.totalCount == totalCount)&&(identical(other.hasNextPage, hasNextPage) || other.hasNextPage == hasNextPage));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(items),pageNumber,totalCount,hasNextPage);

@override
String toString() {
  return 'LeavePage(items: $items, pageNumber: $pageNumber, totalCount: $totalCount, hasNextPage: $hasNextPage)';
}


}

/// @nodoc
abstract mixin class $LeavePageCopyWith<$Res>  {
  factory $LeavePageCopyWith(LeavePage value, $Res Function(LeavePage) _then) = _$LeavePageCopyWithImpl;
@useResult
$Res call({
 List<LeaveRequest> items, int pageNumber, int totalCount, bool hasNextPage
});




}
/// @nodoc
class _$LeavePageCopyWithImpl<$Res>
    implements $LeavePageCopyWith<$Res> {
  _$LeavePageCopyWithImpl(this._self, this._then);

  final LeavePage _self;
  final $Res Function(LeavePage) _then;

/// Create a copy of LeavePage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? items = null,Object? pageNumber = null,Object? totalCount = null,Object? hasNextPage = null,}) {
  return _then(_self.copyWith(
items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<LeaveRequest>,pageNumber: null == pageNumber ? _self.pageNumber : pageNumber // ignore: cast_nullable_to_non_nullable
as int,totalCount: null == totalCount ? _self.totalCount : totalCount // ignore: cast_nullable_to_non_nullable
as int,hasNextPage: null == hasNextPage ? _self.hasNextPage : hasNextPage // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [LeavePage].
extension LeavePagePatterns on LeavePage {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LeavePage value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LeavePage() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LeavePage value)  $default,){
final _that = this;
switch (_that) {
case _LeavePage():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LeavePage value)?  $default,){
final _that = this;
switch (_that) {
case _LeavePage() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<LeaveRequest> items,  int pageNumber,  int totalCount,  bool hasNextPage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LeavePage() when $default != null:
return $default(_that.items,_that.pageNumber,_that.totalCount,_that.hasNextPage);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<LeaveRequest> items,  int pageNumber,  int totalCount,  bool hasNextPage)  $default,) {final _that = this;
switch (_that) {
case _LeavePage():
return $default(_that.items,_that.pageNumber,_that.totalCount,_that.hasNextPage);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<LeaveRequest> items,  int pageNumber,  int totalCount,  bool hasNextPage)?  $default,) {final _that = this;
switch (_that) {
case _LeavePage() when $default != null:
return $default(_that.items,_that.pageNumber,_that.totalCount,_that.hasNextPage);case _:
  return null;

}
}

}

/// @nodoc


class _LeavePage implements LeavePage {
  const _LeavePage({required final  List<LeaveRequest> items, this.pageNumber = 1, this.totalCount = 0, this.hasNextPage = false}): _items = items;
  

 final  List<LeaveRequest> _items;
@override List<LeaveRequest> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

@override@JsonKey() final  int pageNumber;
@override@JsonKey() final  int totalCount;
@override@JsonKey() final  bool hasNextPage;

/// Create a copy of LeavePage
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LeavePageCopyWith<_LeavePage> get copyWith => __$LeavePageCopyWithImpl<_LeavePage>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LeavePage&&const DeepCollectionEquality().equals(other._items, _items)&&(identical(other.pageNumber, pageNumber) || other.pageNumber == pageNumber)&&(identical(other.totalCount, totalCount) || other.totalCount == totalCount)&&(identical(other.hasNextPage, hasNextPage) || other.hasNextPage == hasNextPage));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_items),pageNumber,totalCount,hasNextPage);

@override
String toString() {
  return 'LeavePage(items: $items, pageNumber: $pageNumber, totalCount: $totalCount, hasNextPage: $hasNextPage)';
}


}

/// @nodoc
abstract mixin class _$LeavePageCopyWith<$Res> implements $LeavePageCopyWith<$Res> {
  factory _$LeavePageCopyWith(_LeavePage value, $Res Function(_LeavePage) _then) = __$LeavePageCopyWithImpl;
@override @useResult
$Res call({
 List<LeaveRequest> items, int pageNumber, int totalCount, bool hasNextPage
});




}
/// @nodoc
class __$LeavePageCopyWithImpl<$Res>
    implements _$LeavePageCopyWith<$Res> {
  __$LeavePageCopyWithImpl(this._self, this._then);

  final _LeavePage _self;
  final $Res Function(_LeavePage) _then;

/// Create a copy of LeavePage
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? items = null,Object? pageNumber = null,Object? totalCount = null,Object? hasNextPage = null,}) {
  return _then(_LeavePage(
items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<LeaveRequest>,pageNumber: null == pageNumber ? _self.pageNumber : pageNumber // ignore: cast_nullable_to_non_nullable
as int,totalCount: null == totalCount ? _self.totalCount : totalCount // ignore: cast_nullable_to_non_nullable
as int,hasNextPage: null == hasNextPage ? _self.hasNextPage : hasNextPage // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
