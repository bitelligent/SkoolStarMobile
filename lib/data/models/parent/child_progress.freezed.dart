// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'child_progress.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ChildProgress {

 String get childId;/// Homework handed in / given, completed or not (deleted ones excluded).
 int get completedAssignments; int get totalAssignments; int get totalResults;/// Mean of the exam scores; 0 when there are none.
 double get averageScore;
/// Create a copy of ChildProgress
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChildProgressCopyWith<ChildProgress> get copyWith => _$ChildProgressCopyWithImpl<ChildProgress>(this as ChildProgress, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChildProgress&&(identical(other.childId, childId) || other.childId == childId)&&(identical(other.completedAssignments, completedAssignments) || other.completedAssignments == completedAssignments)&&(identical(other.totalAssignments, totalAssignments) || other.totalAssignments == totalAssignments)&&(identical(other.totalResults, totalResults) || other.totalResults == totalResults)&&(identical(other.averageScore, averageScore) || other.averageScore == averageScore));
}


@override
int get hashCode => Object.hash(runtimeType,childId,completedAssignments,totalAssignments,totalResults,averageScore);

@override
String toString() {
  return 'ChildProgress(childId: $childId, completedAssignments: $completedAssignments, totalAssignments: $totalAssignments, totalResults: $totalResults, averageScore: $averageScore)';
}


}

/// @nodoc
abstract mixin class $ChildProgressCopyWith<$Res>  {
  factory $ChildProgressCopyWith(ChildProgress value, $Res Function(ChildProgress) _then) = _$ChildProgressCopyWithImpl;
@useResult
$Res call({
 String childId, int completedAssignments, int totalAssignments, int totalResults, double averageScore
});




}
/// @nodoc
class _$ChildProgressCopyWithImpl<$Res>
    implements $ChildProgressCopyWith<$Res> {
  _$ChildProgressCopyWithImpl(this._self, this._then);

  final ChildProgress _self;
  final $Res Function(ChildProgress) _then;

/// Create a copy of ChildProgress
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? childId = null,Object? completedAssignments = null,Object? totalAssignments = null,Object? totalResults = null,Object? averageScore = null,}) {
  return _then(_self.copyWith(
childId: null == childId ? _self.childId : childId // ignore: cast_nullable_to_non_nullable
as String,completedAssignments: null == completedAssignments ? _self.completedAssignments : completedAssignments // ignore: cast_nullable_to_non_nullable
as int,totalAssignments: null == totalAssignments ? _self.totalAssignments : totalAssignments // ignore: cast_nullable_to_non_nullable
as int,totalResults: null == totalResults ? _self.totalResults : totalResults // ignore: cast_nullable_to_non_nullable
as int,averageScore: null == averageScore ? _self.averageScore : averageScore // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [ChildProgress].
extension ChildProgressPatterns on ChildProgress {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChildProgress value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChildProgress() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChildProgress value)  $default,){
final _that = this;
switch (_that) {
case _ChildProgress():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChildProgress value)?  $default,){
final _that = this;
switch (_that) {
case _ChildProgress() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String childId,  int completedAssignments,  int totalAssignments,  int totalResults,  double averageScore)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChildProgress() when $default != null:
return $default(_that.childId,_that.completedAssignments,_that.totalAssignments,_that.totalResults,_that.averageScore);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String childId,  int completedAssignments,  int totalAssignments,  int totalResults,  double averageScore)  $default,) {final _that = this;
switch (_that) {
case _ChildProgress():
return $default(_that.childId,_that.completedAssignments,_that.totalAssignments,_that.totalResults,_that.averageScore);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String childId,  int completedAssignments,  int totalAssignments,  int totalResults,  double averageScore)?  $default,) {final _that = this;
switch (_that) {
case _ChildProgress() when $default != null:
return $default(_that.childId,_that.completedAssignments,_that.totalAssignments,_that.totalResults,_that.averageScore);case _:
  return null;

}
}

}

/// @nodoc


class _ChildProgress extends ChildProgress {
  const _ChildProgress({required this.childId, this.completedAssignments = 0, this.totalAssignments = 0, this.totalResults = 0, this.averageScore = 0}): super._();
  

@override final  String childId;
/// Homework handed in / given, completed or not (deleted ones excluded).
@override@JsonKey() final  int completedAssignments;
@override@JsonKey() final  int totalAssignments;
@override@JsonKey() final  int totalResults;
/// Mean of the exam scores; 0 when there are none.
@override@JsonKey() final  double averageScore;

/// Create a copy of ChildProgress
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChildProgressCopyWith<_ChildProgress> get copyWith => __$ChildProgressCopyWithImpl<_ChildProgress>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChildProgress&&(identical(other.childId, childId) || other.childId == childId)&&(identical(other.completedAssignments, completedAssignments) || other.completedAssignments == completedAssignments)&&(identical(other.totalAssignments, totalAssignments) || other.totalAssignments == totalAssignments)&&(identical(other.totalResults, totalResults) || other.totalResults == totalResults)&&(identical(other.averageScore, averageScore) || other.averageScore == averageScore));
}


@override
int get hashCode => Object.hash(runtimeType,childId,completedAssignments,totalAssignments,totalResults,averageScore);

@override
String toString() {
  return 'ChildProgress(childId: $childId, completedAssignments: $completedAssignments, totalAssignments: $totalAssignments, totalResults: $totalResults, averageScore: $averageScore)';
}


}

/// @nodoc
abstract mixin class _$ChildProgressCopyWith<$Res> implements $ChildProgressCopyWith<$Res> {
  factory _$ChildProgressCopyWith(_ChildProgress value, $Res Function(_ChildProgress) _then) = __$ChildProgressCopyWithImpl;
@override @useResult
$Res call({
 String childId, int completedAssignments, int totalAssignments, int totalResults, double averageScore
});




}
/// @nodoc
class __$ChildProgressCopyWithImpl<$Res>
    implements _$ChildProgressCopyWith<$Res> {
  __$ChildProgressCopyWithImpl(this._self, this._then);

  final _ChildProgress _self;
  final $Res Function(_ChildProgress) _then;

/// Create a copy of ChildProgress
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? childId = null,Object? completedAssignments = null,Object? totalAssignments = null,Object? totalResults = null,Object? averageScore = null,}) {
  return _then(_ChildProgress(
childId: null == childId ? _self.childId : childId // ignore: cast_nullable_to_non_nullable
as String,completedAssignments: null == completedAssignments ? _self.completedAssignments : completedAssignments // ignore: cast_nullable_to_non_nullable
as int,totalAssignments: null == totalAssignments ? _self.totalAssignments : totalAssignments // ignore: cast_nullable_to_non_nullable
as int,totalResults: null == totalResults ? _self.totalResults : totalResults // ignore: cast_nullable_to_non_nullable
as int,averageScore: null == averageScore ? _self.averageScore : averageScore // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

/// @nodoc
mixin _$ExamResult {

 String get examId; String get examName; double get score; String? get remarks; DateTime? get createdAt;
/// Create a copy of ExamResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ExamResultCopyWith<ExamResult> get copyWith => _$ExamResultCopyWithImpl<ExamResult>(this as ExamResult, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ExamResult&&(identical(other.examId, examId) || other.examId == examId)&&(identical(other.examName, examName) || other.examName == examName)&&(identical(other.score, score) || other.score == score)&&(identical(other.remarks, remarks) || other.remarks == remarks)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}


@override
int get hashCode => Object.hash(runtimeType,examId,examName,score,remarks,createdAt);

@override
String toString() {
  return 'ExamResult(examId: $examId, examName: $examName, score: $score, remarks: $remarks, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $ExamResultCopyWith<$Res>  {
  factory $ExamResultCopyWith(ExamResult value, $Res Function(ExamResult) _then) = _$ExamResultCopyWithImpl;
@useResult
$Res call({
 String examId, String examName, double score, String? remarks, DateTime? createdAt
});




}
/// @nodoc
class _$ExamResultCopyWithImpl<$Res>
    implements $ExamResultCopyWith<$Res> {
  _$ExamResultCopyWithImpl(this._self, this._then);

  final ExamResult _self;
  final $Res Function(ExamResult) _then;

/// Create a copy of ExamResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? examId = null,Object? examName = null,Object? score = null,Object? remarks = freezed,Object? createdAt = freezed,}) {
  return _then(_self.copyWith(
examId: null == examId ? _self.examId : examId // ignore: cast_nullable_to_non_nullable
as String,examName: null == examName ? _self.examName : examName // ignore: cast_nullable_to_non_nullable
as String,score: null == score ? _self.score : score // ignore: cast_nullable_to_non_nullable
as double,remarks: freezed == remarks ? _self.remarks : remarks // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [ExamResult].
extension ExamResultPatterns on ExamResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ExamResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ExamResult() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ExamResult value)  $default,){
final _that = this;
switch (_that) {
case _ExamResult():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ExamResult value)?  $default,){
final _that = this;
switch (_that) {
case _ExamResult() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String examId,  String examName,  double score,  String? remarks,  DateTime? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ExamResult() when $default != null:
return $default(_that.examId,_that.examName,_that.score,_that.remarks,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String examId,  String examName,  double score,  String? remarks,  DateTime? createdAt)  $default,) {final _that = this;
switch (_that) {
case _ExamResult():
return $default(_that.examId,_that.examName,_that.score,_that.remarks,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String examId,  String examName,  double score,  String? remarks,  DateTime? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _ExamResult() when $default != null:
return $default(_that.examId,_that.examName,_that.score,_that.remarks,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc


class _ExamResult implements ExamResult {
  const _ExamResult({required this.examId, required this.examName, required this.score, this.remarks, this.createdAt});
  

@override final  String examId;
@override final  String examName;
@override final  double score;
@override final  String? remarks;
@override final  DateTime? createdAt;

/// Create a copy of ExamResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ExamResultCopyWith<_ExamResult> get copyWith => __$ExamResultCopyWithImpl<_ExamResult>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ExamResult&&(identical(other.examId, examId) || other.examId == examId)&&(identical(other.examName, examName) || other.examName == examName)&&(identical(other.score, score) || other.score == score)&&(identical(other.remarks, remarks) || other.remarks == remarks)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}


@override
int get hashCode => Object.hash(runtimeType,examId,examName,score,remarks,createdAt);

@override
String toString() {
  return 'ExamResult(examId: $examId, examName: $examName, score: $score, remarks: $remarks, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$ExamResultCopyWith<$Res> implements $ExamResultCopyWith<$Res> {
  factory _$ExamResultCopyWith(_ExamResult value, $Res Function(_ExamResult) _then) = __$ExamResultCopyWithImpl;
@override @useResult
$Res call({
 String examId, String examName, double score, String? remarks, DateTime? createdAt
});




}
/// @nodoc
class __$ExamResultCopyWithImpl<$Res>
    implements _$ExamResultCopyWith<$Res> {
  __$ExamResultCopyWithImpl(this._self, this._then);

  final _ExamResult _self;
  final $Res Function(_ExamResult) _then;

/// Create a copy of ExamResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? examId = null,Object? examName = null,Object? score = null,Object? remarks = freezed,Object? createdAt = freezed,}) {
  return _then(_ExamResult(
examId: null == examId ? _self.examId : examId // ignore: cast_nullable_to_non_nullable
as String,examName: null == examName ? _self.examName : examName // ignore: cast_nullable_to_non_nullable
as String,score: null == score ? _self.score : score // ignore: cast_nullable_to_non_nullable
as double,remarks: freezed == remarks ? _self.remarks : remarks // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
