// End-to-end check of the chat stack against a real backend (teacher and
// parent online at once). Skipped unless the environment provides logins:
//
//   LIVE_API=http://host:port \
//   LIVE_TEACHER_EMAIL=... LIVE_PARENT_EMAIL=... LIVE_PASSWORD=... \
//   flutter test test/live/live_chat_test.dart
//
// It sends a few clearly-marked "[live-test]" messages (1-to-1 messages cannot
// be deleted through the API); feedback it creates is deleted again.
import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:skoolstar_teacher_module/core/network/api_client.dart';
import 'package:skoolstar_teacher_module/core/utils/json_utils.dart';
import 'package:skoolstar_teacher_module/data/models/chat_thread.dart';
import 'package:skoolstar_teacher_module/data/models/feedback_topic.dart';
import 'package:skoolstar_teacher_module/data/models/message_status.dart';
import 'package:skoolstar_teacher_module/data/realtime/chat_realtime.dart';
import 'package:skoolstar_teacher_module/data/repositories/api_chat_repository.dart';
import 'package:skoolstar_teacher_module/features/chat/cubit/direct_chat_cubit.dart';
import 'package:skoolstar_teacher_module/features/chat/cubit/direct_chat_state.dart';
import 'package:skoolstar_teacher_module/features/chat/cubit/feedback_chat_cubit.dart';
import 'package:skoolstar_teacher_module/features/chat/cubit/feedback_chat_state.dart';

class _Side {
  _Side(this.api, this.realtime, this.repo);
  final ApiClient api;
  final ChatRealtime realtime;
  final ApiChatRepository repo;
}

Future<void> until(
  bool Function() cond, {
  int ms = 8000,
  String? why,
}) async {
  final end = DateTime.now().add(Duration(milliseconds: ms));
  while (!cond()) {
    if (DateTime.now().isAfter(end)) fail('timed out: ${why ?? 'condition'}');
    await Future<void>.delayed(const Duration(milliseconds: 50));
  }
}

void main() {
  final env = Platform.environment;
  final base = env['LIVE_API'];
  final teacherEmail = env['LIVE_TEACHER_EMAIL'];
  final parentEmail = env['LIVE_PARENT_EMAIL'];
  final password = env['LIVE_PASSWORD'];
  final enabled =
      base != null &&
      teacherEmail != null &&
      parentEmail != null &&
      password != null;

  late _Side teacher;
  late _Side parent;

  Future<_Side> signIn(String email, {String? contextKey}) async {
    final bootstrap = ApiClient(baseUrl: base!);
    var json =
        await bootstrap.post(
              '/api/Users/enhanced-login',
              body: {'email': email, 'password': password},
              authenticated: false,
            )
            as Json;
    var token = json.str('accessToken');
    if (contextKey != null) {
      final authed = ApiClient(baseUrl: base, accessToken: () => token);
      json =
          await authed.post(
                '/api/Users/select-context',
                body: {'contextKey': contextKey},
              )
              as Json;
      token = json.str('accessToken');
    }
    final api = ApiClient(baseUrl: base, accessToken: () => token);
    final realtime = ChatRealtime.forServer(
      baseUrl: base,
      accessToken: () => token,
    );
    final isParent = contextKey != null;
    return _Side(
      api,
      realtime,
      ApiChatRepository(apiClient: api, realtime: realtime, asParent: isParent),
    );
  }

  setUpAll(() async {
    if (!enabled) return;
    teacher = await signIn(teacherEmail);
    parent = await signIn(parentEmail, contextKey: 'Parent:8');
    teacher.realtime.start();
    parent.realtime.start();
    await until(
      () => teacher.realtime.isLive.value && parent.realtime.isLive.value,
      why: 'both realtime links up',
    );
  });

  tearDownAll(() async {
    if (!enabled) return;
    teacher.repo.dispose();
    parent.repo.dispose();
    await teacher.realtime.dispose();
    await parent.realtime.dispose();
  });

  test(
    '1-to-1: live delivery both ways, no duplicates, read ticks',
    () async {
      final tThreads = await teacher.repo.getByCategory(ChatCategory.oneToOne);
      final pThreads = await parent.repo.getByCategory(ChatCategory.oneToOne);
      expect(tThreads, isNotEmpty);
      expect(pThreads, isNotEmpty);
      final id = tThreads.first.id; // same server thread for both

      final t = DirectChatCubit(threadId: id, repository: teacher.repo);
      final p = DirectChatCubit(
        threadId: pThreads.first.id,
        repository: parent.repo,
        asParent: true,
      );
      addTearDown(t.close);
      addTearDown(p.close);
      await t.load();
      await p.load();

      DirectChatLoaded ts() => t.state as DirectChatLoaded;
      DirectChatLoaded ps() => p.state as DirectChatLoaded;
      final stamp = DateTime.now().millisecondsSinceEpoch;
      final fromTeacher = '[live-test] teacher→parent $stamp';
      final fromParent = '[live-test] parent→teacher $stamp';

      // Teacher sends; the parent sees it by push (no refresh).
      expect(await t.send(fromTeacher), isTrue);
      expect(ts().messages.last.status, MessageStatus.sending);
      await until(
        () => ps().messages.any((m) => m.content == fromTeacher),
        why: 'parent receives teacher message live',
      );
      await until(
        () => ts().messages.any(
          (m) => m.content == fromTeacher && m.status == MessageStatus.sent,
        ),
        why: 'teacher message confirmed',
      );
      expect(
        ts().messages.where((m) => m.content == fromTeacher).length,
        1,
        reason: 'teacher must not see their own message twice',
      );
      expect(
        ps().messages.where((m) => m.content == fromTeacher).length,
        1,
      );
      // It is the other side's message for the parent.
      expect(
        ps().messages.firstWhere((m) => m.content == fromTeacher).fromTeacher,
        isTrue,
      );

      // Parent replies; the teacher sees it live.
      expect(await p.send(fromParent), isTrue);
      await until(
        () => ts().messages.any((m) => m.content == fromParent),
        why: 'teacher receives parent message live',
      );
      expect(ts().messages.where((m) => m.content == fromParent).length, 1);
      expect(
        ts().messages.firstWhere((m) => m.content == fromParent).fromTeacher,
        isFalse,
      );

      // Both screens are open: the teacher's message gets read by the parent.
      await until(
        () => ts().messages.firstWhere((m) => m.content == fromTeacher).isRead,
        why: 'read receipt reaches the teacher',
      );

      // Same order on both devices.
      List<String> tail(DirectChatLoaded s) => [
        for (final m in s.messages)
          if (m.content.contains('$stamp')) m.content,
      ];
      expect(tail(ts()), tail(ps()));
    },
    skip: enabled ? false : 'set LIVE_* environment variables',
    timeout: const Timeout(Duration(seconds: 60)),
  );

  test(
    'feedback: create, live replies both ways, resolve, cleanup',
    () async {
      final fb = await teacher.repo.getByCategory(ChatCategory.feedback);
      final student2 = fb.firstWhere((t) => t.id == 'fb_2');
      final tc = FeedbackChatCubit(
        threadId: student2.id,
        repository: teacher.repo,
        pollInterval: const Duration(seconds: 2),
      );
      addTearDown(tc.close);
      await tc.load();
      FeedbackChatLoaded ts() => tc.state as FeedbackChatLoaded;

      final stamp = DateTime.now().millisecondsSinceEpoch;
      expect(
        await tc.createTopic(
          subject: 'Live test $stamp',
          tone: FeedbackTone.positive,
          message: '[live-test] feedback $stamp',
        ),
        isTrue,
      );
      final created = ts().topics.firstWhere(
        (t) => t.subject == 'Live test $stamp',
      );

      // Parent opens the matching thread and sees the new topic.
      final pFb = await parent.repo.getByCategory(ChatCategory.feedback);
      final pThread = pFb.firstWhere((t) => t.id.startsWith('fb_2'));
      final pc = FeedbackChatCubit(
        threadId: pThread.id,
        repository: parent.repo,
        asParent: true,
        pollInterval: const Duration(seconds: 2),
      );
      addTearDown(pc.close);
      await pc.load();
      FeedbackChatLoaded ps() => pc.state as FeedbackChatLoaded;
      expect(ps().topics.any((t) => t.id == created.id), isTrue);

      try {
        // Teacher follow-up arrives at the parent by push.
        await tc.replyToTopic(created.id, '[live-test] teacher follow-up');
        await until(
          () => ps().topics
              .firstWhere((t) => t.id == created.id)
              .messages
              .any((m) => m.content == '[live-test] teacher follow-up'),
          why: 'parent receives follow-up live',
        );

        // Parent reply arrives at the teacher by push, once.
        await pc.replyToTopic(created.id, '[live-test] parent reply');
        await until(
          () => ts().topics
              .firstWhere((t) => t.id == created.id)
              .messages
              .any((m) => m.content == '[live-test] parent reply'),
          why: 'teacher receives parent reply live',
        );
        expect(
          ts().topics
              .firstWhere((t) => t.id == created.id)
              .messages
              .where((m) => m.content == '[live-test] parent reply')
              .length,
          1,
        );
        expect(
          ts().topics
              .firstWhere((t) => t.id == created.id)
              .messages
              .every((m) => m.status == MessageStatus.sent),
          isTrue,
        );

        // Resolve is not pushed by the backend: the parent's periodic
        // refresh may or may not show it (parent rows lack isResolved).
        await tc.toggleResolved(created.id);
        expect(
          ts().topics.firstWhere((t) => t.id == created.id).isResolved,
          isTrue,
        );
      } finally {
        await tc.deleteTopic(created.id);
      }
      expect(ts().topics.any((t) => t.id == created.id), isFalse);
    },
    skip: enabled ? false : 'set LIVE_* environment variables',
    timeout: const Timeout(Duration(seconds: 90)),
  );
}
