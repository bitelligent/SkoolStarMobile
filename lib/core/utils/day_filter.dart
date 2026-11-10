/// Day filter values shared by the teacher and parent home screens.
///
/// `''` = all days, `'today'`, `'week'` (current Monday–Sunday) and
/// `'month'` (current calendar month).
const defaultDayFilter = 'today';

bool sameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

/// Whether [date] falls in the relative range named by [filter].
bool matchesDayFilter(DateTime date, String filter, DateTime now) {
  final d = DateTime(date.year, date.month, date.day);
  final today = DateTime(now.year, now.month, now.day);
  switch (filter) {
    case 'today':
      return d == today;
    case 'week':
      final monday = today.subtract(Duration(days: today.weekday - 1));
      final sunday = monday.add(const Duration(days: 6));
      return !d.isBefore(monday) && !d.isAfter(sunday);
    case 'month':
      return d.year == today.year && d.month == today.month;
    default:
      return true; // '' = all days
  }
}
