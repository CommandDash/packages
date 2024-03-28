import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart';

import '../utils/consts.dart';
import '../utils/env.dart';
import '../utils/helpers.dart';
import '../utils/logger.dart';
import 'api.dart';

/// Auth class to handle authentication
class Auth {
  /// Check if user is authenticated
  static Future<bool> get isAuthenticated async {
    bool tokenExists = WelltestedEnv.instance.env.authToken != null &&
        WelltestedEnv.instance.env.authToken!.isNotEmpty;
    if (tokenExists) {
      bool tokenExpired = WelltestedEnv.instance.env.isAuthTokenExpired;
      return !tokenExpired;
    }
    return false;
  }

  /// Logout the user
  static bool logout() => deleteCredentials();

  /// Refresh the auth token
  static Future<bool> refreshToken() async {
    try {
      bool tokenExpired = WelltestedEnv.instance.env.isAuthTokenExpired;
      if (!tokenExpired) return true;
      wtLog.info('Refreshing token...');
      if (WelltestedEnv.instance.env.isRefreshTokenExpired) {
        wtLog.error('Session expired. Please login again');
        logout();
        return false;
      }
      Response res = await BaseApi.getInstance.post(
        Uri.https(CliConstants.baseUrl, CliConstants.refreshTokenPath),
        headers: <String, String>{
          HttpHeaders.authorizationHeader:
              'Bearer ${WelltestedEnv.instance.env.refreshToken}'
        },
      );
      if (res.statusCode >= 200 && res.statusCode < 300) {
        Map<String, dynamic> data =
            json.decode(res.body) as Map<String, dynamic>;
        WelltestedEnv.addNew('access_token', data['access_token']);
        WelltestedEnv.instance.env.authToken = data['access_token'];
        wtLog.log('Token refreshed successfully');
        return true;
      }
      return false;
    } catch (e) {
      wtLog.error(e.toString());
      return false;
    }
  }

  /// Login the user
  static Future<void> login(
      {required Function onSuccess,
      required Function(String) onFailure}) async {
    Uri? url = await getLoginUrl(onSuccess: onSuccess, onFailure: onFailure);
    if (url != null) {
      await createServer(url.toString());
      wtLog.stopSpinner();
      wtLog.updateSpinnerMessage('Logged-in successfully!');
    } else {
      wtLog.stopSpinner();
      wtLog.error('Failed to get login url');
    }
  }

  /// Get the login URL from the server
  static Future<Uri?> getLoginUrl(
      {required Function onSuccess,
      required Function(String) onFailure}) async {
    try {
      Response link = await BaseApi.getInstance
          .get(Uri.https(CliConstants.baseUrl, CliConstants.authenticatePath));
      if (link.statusCode >= 200 && link.statusCode < 300) {
        return Uri.parse(json.decode(link.body)['github_oauth_url']);
      } else {
        onFailure.call(link.reasonPhrase ?? link.body);
        return null;
      }
    } catch (e) {
      wtLog.error(e.toString());
      return null;
    }
  }

  /// Delete the credentials
  static bool deleteCredentials() {
    try {
      File file = WelltestedEnv.configFile;
      if (file.existsSync()) {
        file.writeAsStringSync('', mode: FileMode.write, encoding: utf8);
        WelltestedEnv.instance.env
          ..authToken = null
          ..refreshToken = null
          ..username = null
          ..email = null;
      } else {
        wtLog.warning('No API keys found');
      }
      return true;
    } catch (e) {
      rethrow;
    }
  }
}