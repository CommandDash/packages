/// Constants for the CLI
class CliConstants {
  /// Base URL for the API
  static String baseUrl = 'api.commanddash.dev';

  /// Path to authenticate via CLI
  static String authenticatePath = 'account/github/url/cli';

  /// Path to refresh token
  static String refreshTokenPath = '/account/github/refresh';

  /// Path to update email if not already present
  static String updateEmailPath = '/account/github/update/email';
}

enum AuthStatus { authenticated, authenticationExpired, notAuthenticated }
