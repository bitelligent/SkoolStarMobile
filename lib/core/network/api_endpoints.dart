/// Every backend path lives here so call sites never hand-build URLs.
class ApiEndpoints {
  ApiEndpoints._();

  static const String _users = '/api/Users';

  static const String enhancedLogin = '$_users/enhanced-login';
}
