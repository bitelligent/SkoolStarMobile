// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'feedback_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_FeedbackMessage _$FeedbackMessageFromJson(Map<String, dynamic> json) =>
    _FeedbackMessage(
      id: json['id'] as String,
      sessionId: json['sessionId'] as String,
      studentIds: (json['studentIds'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      message: json['message'] as String,
      isPositive: json['isPositive'] as bool? ?? true,
      sentAt: json['sentAt'] == null
          ? null
          : DateTime.parse(json['sentAt'] as String),
    );

Map<String, dynamic> _$FeedbackMessageToJson(_FeedbackMessage instance) =>
    <String, dynamic>{
      'id': instance.id,
      'sessionId': instance.sessionId,
      'studentIds': instance.studentIds,
      'message': instance.message,
      'isPositive': instance.isPositive,
      'sentAt': instance.sentAt?.toIso8601String(),
    };

_AssignmentReview _$AssignmentReviewFromJson(Map<String, dynamic> json) =>
    _AssignmentReview(
      id: json['id'] as String,
      sessionId: json['sessionId'] as String,
      homeworkId: json['homeworkId'] as String,
      studentId: json['studentId'] as String,
      marks: (json['marks'] as num).toInt(),
      reviewText: json['reviewText'] as String,
      reviewedAt: json['reviewedAt'] == null
          ? null
          : DateTime.parse(json['reviewedAt'] as String),
    );

Map<String, dynamic> _$AssignmentReviewToJson(_AssignmentReview instance) =>
    <String, dynamic>{
      'id': instance.id,
      'sessionId': instance.sessionId,
      'homeworkId': instance.homeworkId,
      'studentId': instance.studentId,
      'marks': instance.marks,
      'reviewText': instance.reviewText,
      'reviewedAt': instance.reviewedAt?.toIso8601String(),
    };
