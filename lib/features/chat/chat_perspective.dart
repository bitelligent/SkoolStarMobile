import 'package:flutter/widgets.dart';
import 'package:skoolstar_teacher_module/core/router/app_routes.dart';

/// Whose side of the conversation the chat screens are showing. The teacher
/// and parent modules share the same chat UI; this decides routes, which
/// messages are "mine" and which actions are available.
enum ChatPerspective {
  teacher,
  parent
  ;

  bool get isParent => this == ChatPerspective.parent;

  /// Route names for the pushed conversation screens.
  String get feedbackRouteName =>
      isParent ? AppRoutes.parentFeedbackChat : AppRoutes.feedbackChat;
  String get directRouteName =>
      isParent ? AppRoutes.parentDirectChat : AppRoutes.directChat;

  /// Whether a message sent by a teacher (`fromTeacher`) is the current
  /// user's own message.
  bool isMine({required bool fromTeacher}) =>
      isParent ? !fromTeacher : fromTeacher;

  /// Value to store as `fromTeacher` for a message sent from this side.
  bool get sendsAsTeacher => !isParent;

  /// Parents answer teachers' feedback; only teachers start threads and
  /// manage (resolve / delete) them.
  bool get canStartFeedback => !isParent;
  bool get canManageTopics => !isParent;

  String get composerHint =>
      isParent ? 'Reply to teacher…' : 'Reply to parent…';
}

/// Provides the [ChatPerspective] to the chat widgets below it. Defaults to
/// the teacher perspective, so existing teacher screens need no wrapper.
class ChatPerspectiveScope extends InheritedWidget {
  const ChatPerspectiveScope({
    required this.perspective,
    required super.child,
    super.key,
  });

  final ChatPerspective perspective;

  static ChatPerspective of(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<ChatPerspectiveScope>();
    return scope?.perspective ?? ChatPerspective.teacher;
  }

  /// Like [of] but without subscribing to changes: for one-off reads such as
  /// a provider's `create` callback, where listening is not allowed.
  static ChatPerspective read(BuildContext context) {
    final scope = context.getInheritedWidgetOfExactType<ChatPerspectiveScope>();
    return scope?.perspective ?? ChatPerspective.teacher;
  }

  @override
  bool updateShouldNotify(ChatPerspectiveScope old) =>
      old.perspective != perspective;
}
