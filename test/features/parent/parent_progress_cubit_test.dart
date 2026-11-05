import 'package:flutter_test/flutter_test.dart';
import 'package:skoolstar_teacher_module/core/network/api_exception.dart';
import 'package:skoolstar_teacher_module/core/storage/key_value_store.dart';
import 'package:skoolstar_teacher_module/data/models/auth/auth_context.dart';
import 'package:skoolstar_teacher_module/data/models/parent/child.dart';
import 'package:skoolstar_teacher_module/data/models/parent/child_progress.dart';
import 'package:skoolstar_teacher_module/features/parent/common/children_cubit.dart';
import 'package:skoolstar_teacher_module/features/parent/progress/parent_progress_cubit.dart';
import 'package:skoolstar_teacher_module/features/parent/progress/progress_report.dart';

import '../../fixtures/fixtures.dart' as fx;
import '../../helpers/fakes.dart';
import 'progress_fakes.dart';

void main() {
  late ChildrenCubit children;
  late FakeAtt att;
  late FakeHw hw;
  late FakeProgress progress;
  late FakeFeedbackChat chat;
  late ParentProgressCubit cubit;

  ParentProgressLoaded loaded() => cubit.state as ParentProgressLoaded;

  setUp(() async {
    children = ChildrenCubit(
      repository: FakeKids(),
      store: InMemoryKeyValueStore(),
      auth: FakeAuthRepository(
        context: AuthContext.fromJson(fx.parentContext),
      ),
    );
    await children.stream.firstWhere((s) => s is ChildrenLoaded);
    att = FakeAtt();
    hw = FakeHw();
    progress = FakeProgress();
    chat = FakeFeedbackChat();
    cubit = ParentProgressCubit(
      children: children,
      attendance: att,
      assignments: hw,
      progress: progress,
      chat: chat,
      clock: () => progressNow,
    );
  });

  tearDown(() async {
    await cubit.close();
    await children.close();
  });

  test('loads data and feedback for the selected child only', () async {
    await cubit.load();
    expect(loaded().child.id, '3');
    expect(loaded().attendance.length, 4);
    expect(loaded().assignments.length, 1);
    expect(chat.topicRequests, ['fb_3_Tahir']); // not Jannat's thread
    expect(loaded().feedback.single.topic.id, 'fb_3_Tahir');
    expect(loaded().partial, isFalse);
  });

  test('report is derived from the state', () async {
    await cubit.load();
    final r = cubit.report!;
    expect(r.attendance.current.part, 3);
    expect(r.attendance.current.whole, 4);
    expect(r.score.current.percent, 80);
    expect(r.attention.first.kind, AttentionKind.newFeedback);
  });

  test('changing the period recomputes without reloading', () async {
    await cubit.load();
    final fetches = att.requested.length;
    cubit.setPeriod(ProgressPeriod.week);
    expect(loaded().period, ProgressPeriod.week);
    expect(att.requested.length, fetches);
    expect(cubit.report!.period, ProgressPeriod.week);
  });

  test('a failing feedback source does not break the report', () async {
    chat.error = const ServerException();
    await cubit.load();
    expect(loaded().partial, isTrue);
    expect(loaded().feedback, isEmpty);
    expect(loaded().attendance, isNotEmpty);
  });

  test('losing attendance alone still shows homework', () async {
    att.error = const NetworkException();
    await cubit.load();
    expect(loaded().partial, isTrue);
    expect(loaded().attendance, isEmpty);
    expect(loaded().assignments, isNotEmpty);
  });

  test('losing both attendance and homework is an error', () async {
    att.error = const NetworkException();
    hw.error = const NetworkException();
    await cubit.load();
    expect(cubit.state, isA<ParentProgressError>());
  });

  test('refresh keeps the chosen period', () async {
    await cubit.load();
    cubit.setPeriod(ProgressPeriod.quarter);
    final error = await cubit.refresh();
    expect(error, isNull);
    expect(loaded().period, ProgressPeriod.quarter);
  });

  test('refresh failure returns the message and keeps the data', () async {
    await cubit.load();
    att.error = const NetworkException();
    hw.error = const NetworkException();
    final error = await cubit.refresh();
    expect(error, isNotNull);
    expect(cubit.state, isA<ParentProgressLoaded>());
  });

  test('switching child reloads for that child', () async {
    await cubit.load();
    await children.select(
      const Child(id: '2', name: 'Jannat', className: 'Class 1'),
    );
    await Future<void>.delayed(const Duration(milliseconds: 50));
    expect(loaded().child.id, '2');
    expect(att.requested.last, '2');
    expect(chat.topicRequests.last, 'fb_2_Tahir');
  });

  test('loads exam results and the school\'s totals', () async {
    progress
      ..summary = const ChildProgress(
        childId: '3',
        completedAssignments: 6,
        totalAssignments: 8,
        totalResults: 1,
        averageScore: 82,
      )
      ..results = [
        const ExamResult(examId: '5', examName: 'Mid term', score: 82),
      ];
    await cubit.load();
    expect(loaded().results.single.examName, 'Mid term');
    expect(loaded().summary!.completedAssignments, 6);
    expect(loaded().hasSchoolFigures, isTrue);
    expect(loaded().partial, isFalse);
  });

  test('exam results failing does not hide the rest, but is flagged', () async {
    progress.resultsError = const NetworkException();
    await cubit.load();
    expect(cubit.state, isA<ParentProgressLoaded>());
    expect(loaded().attendance, isNotEmpty);
    expect(loaded().results, isEmpty);
    expect(loaded().partial, isTrue);
  });

  test('the summary failing is flagged too, results still show', () async {
    progress
      ..summaryError = const NetworkException()
      ..results = [const ExamResult(examId: '5', examName: 'Quiz', score: 7)];
    await cubit.load();
    expect(loaded().summary, isNull);
    expect(loaded().results, hasLength(1));
    expect(loaded().partial, isTrue);
  });
}
