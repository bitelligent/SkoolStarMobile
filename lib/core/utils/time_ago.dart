import 'package:intl/intl.dart';

/// Short relative time for lists: "Just now", "5 min ago", "3 h ago",
/// "Yesterday", "Mon", "Oct 12", "Oct 12, 2025".
String timeAgo(DateTime at, DateTime now) {
  final diff = now.difference(at);
  // A device clock slightly behind the server must not show "in the future".
  if (diff.inSeconds < 60) return 'Just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';

  final today = DateTime(now.year, now.month, now.day);
  final day = DateTime(at.year, at.month, at.day);
  final days = today.difference(day).inDays;
  if (days <= 0) return '${diff.inHours} h ago';
  if (days == 1) return 'Yesterday';
  if (days < 7) return DateFormat('EEEE').format(at);
  if (at.year == now.year) return DateFormat('MMM d').format(at);
  return DateFormat('MMM d, y').format(at);
}

/// Section heading for a day in a grouped list: "Today", "Yesterday",
/// "Earlier this week", "Earlier".
String dayBucket(DateTime at, DateTime now) {
  final today = DateTime(now.year, now.month, now.day);
  final day = DateTime(at.year, at.month, at.day);
  final days = today.difference(day).inDays;
  if (days <= 0) return 'Today';
  if (days == 1) return 'Yesterday';
  if (days < 7) return 'Earlier this week';
  return 'Earlier';
}
