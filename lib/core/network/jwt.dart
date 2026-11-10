import 'dart:convert';

/// Expiry (`exp` claim) of a JWT, or `null` if [token] is not a readable JWT.
///
/// Only reads the payload; it does not (and cannot) verify the signature. It
/// exists so the app can skip requests that are certain to fail.
DateTime? jwtExpiry(String token) {
  final parts = token.split('.');
  if (parts.length != 3) return null;
  try {
    final payload = utf8.decode(
      base64Url.decode(base64Url.normalize(parts[1])),
    );
    final json = jsonDecode(payload);
    final exp = json is Map<String, dynamic> ? json['exp'] : null;
    if (exp is! num) return null;
    return DateTime.fromMillisecondsSinceEpoch(
      exp.toInt() * 1000,
      isUtc: true,
    );
  } on FormatException {
    return null;
  }
}

/// `true` only when [token] is a readable JWT that has expired. An unreadable
/// token is left for the server to judge. [skew] expires it slightly early so
/// a token about to lapse is not used for a burst of requests.
bool isJwtExpired(
  String? token, {
  DateTime? now,
  Duration skew = const Duration(seconds: 30),
}) {
  if (token == null || token.isEmpty) return false;
  final exp = jwtExpiry(token);
  if (exp == null) return false;
  return !(now ?? DateTime.now().toUtc()).add(skew).isBefore(exp);
}
