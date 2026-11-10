import 'package:freezed_annotation/freezed_annotation.dart';

part 'leave_request.freezed.dart';

/// Where a leave request stands. [id] is the backend `statusId`.
enum LeaveStatus {
  pending(1, 'Pending'),
  approved(2, 'Approved'),
  rejected(3, 'Rejected'),
  cancelled(4, 'Cancelled'),
  unknown(0, 'Unknown')
  ;

  const LeaveStatus(this.id, this.label);

  final int id;
  final String label;

  static LeaveStatus fromId(int? id) =>
      values.firstWhere((s) => s.id == id, orElse: () => unknown);
}

/// Limits the backend enforces on a request (mirrored here so the form can
/// say so before sending; the server stays the authority).
abstract final class LeaveRules {
  static const maxDays = 31;
  static const maxPastDays = 7;
  static const maxReasonLength = 1000;

  /// Today's date on the server's clock: it checks the *UTC* date, not the
  /// phone's local one.
  static DateTime serverToday([DateTime? now]) {
    final utc = (now ?? DateTime.now()).toUtc();
    return DateTime(utc.year, utc.month, utc.day);
  }

  /// Earliest start the server accepts.
  static DateTime firstStart([DateTime? now]) {
    final t = serverToday(now);
    return DateTime(t.year, t.month, t.day - maxPastDays);
  }

  /// Latest end the server accepts (one year ahead).
  static DateTime lastEnd([DateTime? now]) {
    final t = serverToday(now);
    return DateTime(t.year + 1, t.month, t.day);
  }

  /// Inclusive number of days from [start] to [end] (4 → 6 Nov is 3).
  static int daysBetween(DateTime start, DateTime end) =>
      DateTime.utc(
        end.year,
        end.month,
        end.day,
      ).difference(DateTime.utc(start.year, start.month, start.day)).inDays +
      1;

  /// First problem with the chosen dates, or `null` when they are fine.
  static String? validateDates(DateTime start, DateTime end, {DateTime? now}) {
    if (end.isBefore(start)) return 'End date must be on or after the start.';
    if (daysBetween(start, end) > maxDays) {
      return 'Leave cannot be longer than $maxDays days.';
    }
    if (start.isBefore(firstStart(now))) {
      return 'Start date cannot be more than $maxPastDays days in the past.';
    }
    if (end.isAfter(lastEnd(now))) {
      return 'End date cannot be more than a year ahead.';
    }
    return null;
  }
}

/// One leave request a parent made for a child.
@freezed
abstract class LeaveRequest with _$LeaveRequest {
  const LeaveRequest._();

  const factory LeaveRequest({
    required String id,
    required String childId,
    required String childName,
    required DateTime startDate,
    required DateTime endDate,
    required String reason,
    required LeaveStatus status,
    @Default('') String className,

    /// Inclusive days, calculated by the server.
    @Default(1) int durationDays,

    /// Why an admin approved / rejected it, when they said.
    String? decisionReason,
    DateTime? submittedAt,
    DateTime? decidedAt,
  }) = _LeaveRequest;

  /// Only a pending request can still be cancelled.
  bool get canCancel => status == LeaveStatus.pending;

  bool get isSingleDay => durationDays <= 1;
}

/// One page of the parent's requests, newest first.
@freezed
abstract class LeavePage with _$LeavePage {
  const factory LeavePage({
    required List<LeaveRequest> items,
    @Default(1) int pageNumber,
    @Default(0) int totalCount,
    @Default(false) bool hasNextPage,
  }) = _LeavePage;
}
