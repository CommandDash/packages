import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

/// .dash_cli Config file model
class Config {
  /// Refresh token
  String? refreshToken;

  /// Access token
  String? authToken;

  /// Username (Optional, Need not to be present in the config file)
  String? username;

  /// User Email
  String? email;

  Config({
    this.authToken,
    this.refreshToken,
    this.username,
    this.email,
  });

  /// Check if the Auth token is expired
  bool get isAuthTokenExpired {
    if (authToken == null || authToken!.isEmpty) return false;

    JWT? jwt = JWT.tryDecode(authToken!);
    if (jwt == null) return false;

    return DateTime.now().isAfter(
        DateTime.fromMillisecondsSinceEpoch(0, isUtc: true)
            .add(Duration(seconds: jwt.payload['exp'])));
  }

  /// Check if the Refresh token is expired
  bool get isRefreshTokenExpired {
    if (refreshToken == null || refreshToken!.isEmpty) return false;

    JWT? jwt = JWT.tryDecode(refreshToken!);
    if (jwt == null) return false;

    return DateTime.now().isAfter(
        DateTime.fromMillisecondsSinceEpoch(0, isUtc: true)
            .add(Duration(seconds: jwt.payload['exp'])));
  }

  /// Create a Config object from a JSON object
  factory Config.fromJson(Map<String, dynamic> json) {
    return Config(
      authToken: json['access_token'] as String?,
      refreshToken: json['refresh_token'] as String?,
      username: json['username'] as String?,
      email: json['email'] as String?,
    );
  }

  /// Convert this Config object to a JSON object
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'access_token': authToken,
      'refresh_token': refreshToken,
      'username': username,
      'email': email,
    };
  }

  /// Copy this Config object with new values
  Config copyWith({
    String? authToken,
    String? refreshToken,
    String? username,
    String? email,
  }) =>
      Config(
        authToken: authToken ?? this.authToken,
        refreshToken: refreshToken ?? this.refreshToken,
        username: username ?? this.username,
        email: email ?? this.email,
      );
}
