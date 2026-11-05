import 'package:skoolstar_teacher_module/core/network/api_client.dart';
import 'package:skoolstar_teacher_module/core/network/api_endpoints.dart';
import 'package:skoolstar_teacher_module/core/network/api_exception.dart';
import 'package:skoolstar_teacher_module/core/utils/json_utils.dart';
import 'package:skoolstar_teacher_module/data/mappers/parent_mappers.dart';
import 'package:skoolstar_teacher_module/data/models/parent/leave_request.dart';

abstract interface class LeaveRepository {
  static const pageSize = 25;

  /// The signed-in parent's requests, newest first. [childId] / [status]
  /// narrow the list; page numbers start at 1.
  Future<LeavePage> list({
    String? childId,
    LeaveStatus? status,
    int page = 1,
  });

  /// Asks for leave for [childId]. The server answers with the new Pending
  /// request, or a 400 whose message says why not (overlap, too long…).
  Future<LeaveRequest> create({
    required String childId,
    required DateTime start,
    required DateTime end,
    required String reason,
  });

  /// Cancels a Pending request and returns it as Cancelled.
  Future<LeaveRequest> cancel(String id);
}

class LeaveRepositoryImpl implements LeaveRepository {
  const LeaveRepositoryImpl(this._api);

  final ApiClient _api;

  @override
  Future<LeavePage> list({
    String? childId,
    LeaveStatus? status,
    int page = 1,
  }) async => leavePageFromJson(
    await _api.get(
      ApiEndpoints.leaveMine,
      query: {
        'studentId': childId,
        'statusId': status?.id,
        'pageNumber': page,
        'pageSize': LeaveRepository.pageSize,
      },
    ),
  );

  @override
  Future<LeaveRequest> create({
    required String childId,
    required DateTime start,
    required DateTime end,
    required String reason,
  }) async => _single(
    await _api.post(
      ApiEndpoints.leaveApplications,
      body: {
        'studentId': int.tryParse(childId),
        'startDate': dateOnly(start),
        'endDate': dateOnly(end),
        'reason': reason.trim(),
      },
    ),
  );

  @override
  Future<LeaveRequest> cancel(String id) async =>
      _single(await _api.post(ApiEndpoints.leaveCancel(id)));

  LeaveRequest _single(Object? json) =>
      leaveFromJson(json) ?? (throw const ParseException());
}
