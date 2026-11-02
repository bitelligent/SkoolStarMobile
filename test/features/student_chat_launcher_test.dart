import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:skoolstar_teacher_module/core/network/api_exception.dart';
import 'package:skoolstar_teacher_module/core/router/app_routes.dart';
import 'package:skoolstar_teacher_module/data/models/chat_thread.dart';
import 'package:skoolstar_teacher_module/data/models/feedback_topic.dart';
import 'package:skoolstar_teacher_module/data/models/student_model.dart';
import 'package:skoolstar_teacher_module/data/repositories/chat_repository.dart';
import 'package:skoolstar_teacher_module/features/session_detail/widgets/student_chat_launcher.dart';

import '../helpers/test_fonts.dart';
import 'chat/chat_fakes.dart';

class _Repo extends FakeChatRepository {
  _Repo({this.hasThread = true});

  bool hasThread;
  Object? lookupError;
  final List<String> created = [];

  @override
  Future<ChatThread?> getThreadById(String id) async {
    if (lookupError != null) throw lookupError!;
    return hasThread ? thread : null;
  }

  @override
  Future<FeedbackTopic> createFeedbackTopic({
    required String threadId,
    required String subject,
    required FeedbackTone tone,
    required String message,
  }) {
    created.add('$threadId|$message');
    return super.createFeedbackTopic(
      threadId: threadId,
      subject: subject,
      tone: tone,
      message: message,
    );
  }
}

const _student = Student(
  id: '7',
  firstName: 'Ali',
  lastName: 'Khan',
  classGroupId: '1',
);

void main() {
  setUpAll(loadTestFonts);

  Future<List<String>> pump(
    WidgetTester tester,
    _Repo repo, {
    Student student = _student,
  }) async {
    final opened = <String>[];
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, __) => Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () => openStudentChat(context, student),
                child: const Text('chat'),
              ),
            ),
          ),
        ),
        GoRoute(
          path: AppRoutes.feedbackChatPath,
          name: AppRoutes.feedbackChat,
          builder: (_, state) {
            opened.add(state.pathParameters['id']!);
            return const Scaffold(body: Text('thread'));
          },
        ),
      ],
    );
    await tester.pumpWidget(
      RepositoryProvider<ChatRepository>.value(
        value: repo,
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    return opened;
  }

  testWidgets('opens the existing thread of the student', (tester) async {
    final opened = await pump(tester, _Repo());
    await tester.tap(find.text('chat'));
    await tester.pumpAndSettle();
    expect(opened, ['fb_7']);
  });

  testWidgets('no thread yet: starts one with the feedback sheet', (
    tester,
  ) async {
    final repo = _Repo(hasThread: false);
    final opened = await pump(tester, repo);
    await tester.tap(find.text('chat'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Ali’s parent'), findsOneWidget);
    expect(opened, isEmpty);

    await tester.enterText(find.byType(TextField).last, 'Great work today');
    await tester.pump();
    await tester.tap(find.text('Send feedback'));
    await tester.pumpAndSettle();
    expect(repo.created, ['fb_7|Great work today']);
    expect(opened, ['fb_7']);
  });

  testWidgets('dismissing the sheet sends nothing', (tester) async {
    final repo = _Repo(hasThread: false);
    final opened = await pump(tester, repo);
    await tester.tap(find.text('chat'));
    await tester.pumpAndSettle();
    await tester.tapAt(const Offset(10, 10)); // scrim
    await tester.pumpAndSettle();
    expect(repo.created, isEmpty);
    expect(opened, isEmpty);
  });

  testWidgets('a failure is explained, not swallowed', (tester) async {
    final repo = _Repo()..lookupError = const NetworkException();
    final opened = await pump(tester, repo);
    await tester.tap(find.text('chat'));
    await tester.pumpAndSettle();
    expect(opened, isEmpty);
    expect(find.byType(SnackBar), findsOneWidget);
  });

  testWidgets('a student without a numeric id cannot be messaged', (
    tester,
  ) async {
    final opened = await pump(
      tester,
      _Repo(),
      student: _student.copyWith(id: 'abc'),
    );
    await tester.tap(find.text('chat'));
    await tester.pumpAndSettle();
    expect(opened, isEmpty);
    expect(find.text('This student cannot be messaged.'), findsOneWidget);
  });
}
