import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:skoolstar_teacher_module/data/datasources/local_json_data_source.dart';
import 'package:skoolstar_teacher_module/data/repositories/chat_repository.dart';
import 'package:skoolstar_teacher_module/data/repositories/mock_chat_repository.dart';
import 'package:skoolstar_teacher_module/features/chat/chat_perspective.dart';
import 'package:skoolstar_teacher_module/features/chat/view/direct_chat_screen.dart';
import 'package:skoolstar_teacher_module/features/chat/view/feedback_chat_screen.dart';

import '../../helpers/test_fonts.dart';

/// Reads the bundled JSON straight from disk: asset-bundle futures do not
/// complete under the widget-test clock.
class _FileJsonDataSource implements JsonDataSource {
  const _FileJsonDataSource();

  @override
  Future<Map<String, dynamic>> readJsonObject(String assetPath) async =>
      jsonDecode(File(assetPath).readAsStringSync()) as Map<String, dynamic>;

  @override
  Future<List<dynamic>> readJsonArray(String assetPath) async =>
      jsonDecode(File(assetPath).readAsStringSync()) as List<dynamic>;
}

Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 8; i++) {
    await tester.pump(const Duration(milliseconds: 150));
  }
}

Widget _app(ChatPerspective perspective, Widget child) {
  return MaterialApp(
    home: RepositoryProvider<ChatRepository>(
      create: (_) => MockChatRepository(
        const _FileJsonDataSource(),
        assetPath: perspective.isParent
            ? 'assets/json/parent_chats.json'
            : 'assets/json/chats.json',
      ),
      child: ChatPerspectiveScope(perspective: perspective, child: child),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(loadTestFonts);

  group('parent perspective', () {
    testWidgets(
      'feedback thread opens, reads as a parent, hides teacher tools',
      (tester) async {
        await tester.pumpWidget(
          _app(
            ChatPerspective.parent,
            const FeedbackChatScreen(threadId: 'pfb_01'),
          ),
        );
        await _settle(tester);

        expect(tester.takeException(), isNull);
        expect(find.text('Mr. Tahir Mughal'), findsWidgets);
        // Parents can't start threads or manage them.
        expect(find.text('New feedback'), findsNothing);
        expect(find.byIcon(Icons.more_vert_rounded), findsNothing);
        // They can answer the teacher.
        expect(find.text('English — needs attention'), findsOneWidget);
      },
    );

    testWidgets('direct thread opens and shows the conversation', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(
          ChatPerspective.parent,
          const DirectChatScreen(threadId: 'po2o_02'),
        ),
      );
      await _settle(tester);

      expect(tester.takeException(), isNull);
      expect(find.textContaining('extra practice sheet'), findsOneWidget);
      expect(
        find.textContaining('Thank you, I will make sure'),
        findsOneWidget,
      );
    });

    test('replying as a parent stores a parent message', () async {
      final repo = MockChatRepository(
        const _FileJsonDataSource(),
        assetPath: 'assets/json/parent_chats.json',
      );
      final sent = await repo.sendDirectMessage(
        threadId: 'po2o_02',
        content: 'Hello',
        fromTeacher: ChatPerspective.parent.sendsAsTeacher,
      );
      expect(sent.fromTeacher, isFalse); // a parent message
      expect(
        ChatPerspective.parent.isMine(fromTeacher: sent.fromTeacher),
        isTrue,
      );
    });
  });

  group('teacher perspective is unchanged', () {
    testWidgets('feedback thread still offers New feedback', (tester) async {
      await tester.pumpWidget(
        _app(
          ChatPerspective.teacher,
          const FeedbackChatScreen(threadId: 'fb_01'),
        ),
      );
      await _settle(tester);
      expect(tester.takeException(), isNull);
      expect(find.text('New feedback'), findsOneWidget);
      expect(find.byIcon(Icons.more_vert_rounded), findsWidgets);
    });
  });

  test('perspective helpers', () {
    expect(ChatPerspective.parent.isMine(fromTeacher: false), isTrue);
    expect(ChatPerspective.parent.isMine(fromTeacher: true), isFalse);
    expect(ChatPerspective.teacher.isMine(fromTeacher: true), isTrue);
    expect(ChatPerspective.parent.canStartFeedback, isFalse);
    expect(ChatPerspective.teacher.canManageTopics, isTrue);
    expect(ChatPerspective.parent.feedbackRouteName, 'parentFeedbackChat');
    expect(ChatPerspective.teacher.directRouteName, 'directChat');
  });
}
