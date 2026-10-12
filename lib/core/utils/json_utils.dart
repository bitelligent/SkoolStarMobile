/// Defensive JSON readers. API payloads are parsed by hand-written mappers
/// (not generated code) so a missing/odd field degrades gracefully instead of
/// failing the whole screen.
typedef Json = Map<String, dynamic>;

extension JsonReader on Map<String, dynamic> {
  String? strOrNull(String key) {
    final v = this[key];
    if (v == null) return null;
    final s = v.toString();
    return s.isEmpty ? null : s;
  }

  String str(String key, [String fallback = '']) => strOrNull(key) ?? fallback;

  int? intOrNull(String key) {
    final v = this[key];
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v);
    return null;
  }

  int integer(String key, [int fallback = 0]) => intOrNull(key) ?? fallback;

  bool boolean(String key, {bool fallback = false}) {
    final v = this[key];
    return v is bool ? v : fallback;
  }

  DateTime? dateOrNull(String key) {
    final v = this[key];
    return v is String ? DateTime.tryParse(v) : null;
  }

  List<Json> objects(String key) => asObjects(this[key]);
}

/// `[ {..}, {..} ]` → typed list; anything else (null, wrong shape) → empty.
List<Json> asObjects(Object? value) =>
    value is List ? value.whereType<Json>().toList() : const [];

/// `"2026-10-08"`-style date for query strings and bodies.
String dateOnly(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-'
    '${d.day.toString().padLeft(2, '0')}';

/// `"15:24:00"` → `"15:24"`; passes through values already in `HH:mm`.
String hhmm(String? time) {
  if (time == null || time.length < 5) return time ?? '';
  return time.substring(0, 5);
}
