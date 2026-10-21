import 'package:skoolstar_teacher_module/core/utils/json_utils.dart';
import 'package:skoolstar_teacher_module/data/models/chat_thread.dart';
import 'package:skoolstar_teacher_module/data/models/direct_message.dart';
import 'package:skoolstar_teacher_module/data/models/feedback_topic.dart';

/// Thread ids are prefixed so the feedback and 1-to-1 id spaces never clash
/// (both are used in routes).
const _feedbackPrefix = 'fb_';
const _directPrefix = 'dm_';

String directThreadId(int serverId) => '$_directPrefix$serverId';

/// `dm_12` → 12.
int? serverDirectThreadId(String id) => id.startsWith(_directPrefix)
    ? int.tryParse(id.substring(_directPrefix.length))
    : null;

/// `fb_<studentId>` (teacher) or `fb_<studentId>_<teacher name>` (parent).
String feedbackThreadId(int studentId, {String? teacherKey}) =>
    teacherKey == null || teacherKey.isEmpty
    ? '$_feedbackPrefix$studentId'
    : '$_feedbackPrefix${studentId}_${Uri.encodeComponent(teacherKey)}';

({int studentId, String? teacherKey})? parseFeedbackThreadId(String id) {
  if (!id.startsWith(_feedbackPrefix)) return null;
  final rest = id.substring(_feedbackPrefix.length);
  final split = rest.indexOf('_');
  final studentId = int.tryParse(split == -1 ? rest : rest.substring(0, split));
  if (studentId == null) return null;
  return (
    studentId: studentId,
    teacherKey: split == -1
        ? null
        : Uri.decodeComponent(rest.substring(split + 1)),
  );
}

/// The API sends UTC instants, some without a `Z`. A bare ISO string would
/// be read as local time and shift every timestamp, so treat it as UTC.
DateTime parseServerTime(Object? value, {DateTime? fallback}) {
  if (value is String && value.isNotEmpty) {
    final hasZone = RegExp(r'(Z|[+-]\d{2}:?\d{2})$').hasMatch(value);
    final parsed = DateTime.tryParse(hasZone ? value : '${value}Z');
    if (parsed != null) return parsed.toLocal();
  }
  return fallback ?? DateTime.fromMillisecondsSinceEpoch(0);
}

// ─── 1-to-1 ───────────────────────────────────────────────────────────

ChatThread? directThreadFromJson(Json j) {
  final id = j.intOrNull('threadId');
  if (id == null) return null;
  final student = j.str('studentName');
  final tag = j.str('relationshipTag');
  return ChatThread(
    id: directThreadId(id),
    name: j.str('peerName', 'Chat'),
    category: ChatCategory.oneToOne,
    role: tag.isNotEmpty ? tag : student,
    avatarUrl: j.str('peerAvatarUrl'),
    lastMessage: j.str('lastMessageSnippet'),
    lastMessageAt: parseServerTime(j['lastMessageAt']),
    unreadCount: j.integer('unreadCount'),
    isOnline: j.boolean('peerOnline'),
    // "Peer has read my last message" drives the read tick on the tile.
    outgoingLast: j.boolean('lastOutboundRead'),
    peerUserId: j.str('peerUserId'),
  );
}

/// [asParent] is the perspective of the signed-in user. `fromTeacher` is
/// stored from the teacher's point of view, as in the rest of the chat UI.
DirectMessage? directMessageFromJson(
  Json j, {
  required String threadId,
  required String peerUserId,
  required bool asParent,
  bool isRead = true,
}) {
  final id = j.strOrNull('id');
  final body = j.strOrNull('body');
  if (id == null || body == null) return null;
  final mine = peerUserId.isNotEmpty && j.str('senderUserId') != peerUserId;
  return DirectMessage(
    id: id,
    threadId: threadId,
    fromTeacher: asParent ? !mine : mine,
    content: body,
    sentAt: parseServerTime(j['sentAt'], fallback: DateTime.now()),
    isRead: isRead,
  );
}

// ─── Feedback ─────────────────────────────────────────────────────────

FeedbackMessage? feedbackMessageFromJson(Json j, {bool isRead = true}) {
  final id = j.strOrNull('id');
  final body = j.strOrNull('body') ?? j.strOrNull('message');
  if (id == null || body == null) return null;
  return FeedbackMessage(
    id: id,
    // senderRole: 1 = teacher, 2 = parent.
    fromTeacher: j.intOrNull('senderRole') != 2,
    content: body,
    sentAt: parseServerTime(j['sentAt'], fallback: DateTime.now()),
    isRead: isRead,
    senderName: j.str('senderName'),
  );
}

/// One feedback record (`feedback/history` for teachers,
/// `feedback/conversations` for parents; same shape).
FeedbackTopic? feedbackTopicFromJson(
  Json j, {
  required String threadId,
  required bool asParent,
}) {
  final id = j.strOrNull('feedbackId') ?? j.strOrNull('id');
  if (id == null) return null;

  final raw = <FeedbackMessage>[
    for (final m in j.objects('messages')) ?feedbackMessageFromJson(m),
  ]..sort((a, b) => a.sentAt.compareTo(b.sentAt));

  final createdAt = parseServerTime(
    j['teacherSentAt'] ?? j['createdAt'],
    fallback: raw.isEmpty ? DateTime.now() : raw.first.sentAt,
  );

  final messages = raw.isNotEmpty
      ? raw
      : [
          FeedbackMessage(
            id: 'seed_$id',
            fromTeacher: true,
            content: j.str('teacherMessage', j.str('content')),
            sentAt: createdAt,
          ),
        ];

  // The API gives one unread count per record: the unseen messages are the
  // newest ones from the *other* side.
  final unread = j.integer('unreadCount');
  final flagged = <FeedbackMessage>[];
  var remaining = unread;
  for (final m in messages.reversed) {
    final fromOtherSide = asParent ? m.fromTeacher : !m.fromTeacher;
    if (remaining > 0 && fromOtherSide) {
      flagged.add(m.copyWith(isRead: false));
      remaining--;
    } else {
      flagged.add(m);
    }
  }

  final positive = j.boolean('isPositive', fallback: true);
  final subject = j.str('subject').trim();
  return FeedbackTopic(
    id: id,
    threadId: threadId,
    subject: subject.isNotEmpty
        ? subject
        : (positive ? 'Positive feedback' : 'Feedback'),
    tone: positive ? FeedbackTone.positive : FeedbackTone.needsAttention,
    createdAt: createdAt,
    messages: flagged.reversed.toList(),
    isResolved: j.boolean('isResolved'),
  );
}

/// Server tone for a UI tone. The backend only knows "Positive" and "Note"
/// (anything else is stored as Positive) and derives `isPositive` from it.
String toneToServer(FeedbackTone tone) =>
    tone == FeedbackTone.positive ? 'Positive' : 'Note';

/// Groups feedback rows into one thread per student (teacher) or per
/// student + teacher (parent), newest activity first.
List<ChatThread> feedbackThreadsFromRows(
  List<Json> rows, {
  required bool asParent,
}) {
  final groups = <String, List<Json>>{};
  final meta = <String, Json>{};
  for (final row in rows) {
    final studentId = row.intOrNull('studentId');
    if (studentId == null) continue;
    final teacher = asParent ? teacherNameOf(row) : null;
    final key = feedbackThreadId(studentId, teacherKey: teacher);
    groups.putIfAbsent(key, () => []).add(row);
    meta[key] = row;
  }

  final threads = <ChatThread>[];
  groups.forEach((key, group) {
    final topics = [
      for (final r in group)
        ?feedbackTopicFromJson(r, threadId: key, asParent: asParent),
    ];
    if (topics.isEmpty) return;
    topics.sort((a, b) => b.lastActivityAt.compareTo(a.lastActivityAt));
    final latest = topics.first;
    final last = latest.messages.last;
    final sample = meta[key]!;
    final student = sample.str('studentName', 'Student');

    final String name;
    final String role;
    if (asParent) {
      name = teacherNameOf(sample).isEmpty ? 'Teacher' : teacherNameOf(sample);
      role = 'Teacher · $student';
    } else {
      final parent = group
          .map((r) => r.str('parentName'))
          .firstWhere((n) => n.isNotEmpty, orElse: () => '');
      name = parent.isEmpty ? '$student’s parent' : parent;
      role = 'Parent · $student';
    }

    threads.add(
      ChatThread(
        id: key,
        name: name,
        category: ChatCategory.feedback,
        role: role,
        lastMessage: last.content,
        lastMessageAt: latest.lastActivityAt,
        unreadCount: [
          for (final t in topics)
            asParent ? t.unreadFromTeacher : t.unreadFromParent,
        ].fold(0, (a, b) => a + b),
        outgoingLast: asParent ? !last.fromTeacher : last.fromTeacher,
      ),
    );
  });

  threads.sort((a, b) => b.lastMessageAt.compareTo(a.lastMessageAt));
  return threads;
}

/// A parent's feedback rows carry no teacher id, only the name on the
/// teacher's messages.
String teacherNameOf(Json row) {
  for (final m in row.objects('messages')) {
    if (m.intOrNull('senderRole') == 1) {
      final n = m.str('senderName');
      if (n.isNotEmpty) return n;
    }
  }
  return row.str('teacherName');
}
