import 'dart:io';

import 'env.dart';
import 'logger.dart';

/// Open the URL in the default browser.
Future<ProcessResult> openUrl(String url) {
  String command() {
    if (Platform.isWindows) {
      return 'start';
    } else if (Platform.isLinux) {
      return 'xdg-open';
    } else if (Platform.isMacOS) {
      return 'open';
    } else {
      throw UnsupportedError('Operating system not supported by the open_url '
          'package: ${Platform.operatingSystem}');
    }
  }

  if (Platform.isWindows) {
    /// This is needed because ampersand has to be escaped with carret on Windows shell,
    /// otherwise opened URL will be trimmed by first ampersand
    url = url.replaceAllMapped(RegExp('([^^])&'), (Match m) => '${m[1]}^&');
  }
  return Process.run(command(), <String>[url], runInShell: true);
}

/// Create a server to handle the OAuth2 callback.
Future<void> createServer(String url) async {
  try {
    InternetAddress address = InternetAddress.loopbackIPv4;
    const int port = 8080;
    HttpServer server = await HttpServer.bind(address, port);
    await openUrl(url.toString());
    await for (HttpRequest request in server) {
      String? accessToken = request.uri.queryParameters['access_token'];
      String? refreshToken = request.uri.queryParameters['refresh_token'];
      if (accessToken != null) {
        DashCliEnv.addNew('access_token', accessToken);
      }
      if (refreshToken != null) {
        DashCliEnv.addNew('refresh_token', refreshToken);
      }
      if (request.uri.pathSegments.isEmpty) {
        // Handle callback
        String? code = request.uri.queryParameters['code'];
        accessToken = request.uri.queryParameters['access_token'];
        if (code != null && accessToken != null) {
          DashCliEnv.addNew('access_token', accessToken);
        } else {
          wtLog.updateSpinnerMessage('Failed to retrieve authorization code.');
        }
        wtLog.stopSpinner(
            message: accessToken == null
                ? 'Failed to Authorize'
                : 'Authorization successful!',
            severity: accessToken == null
                ? MessageSeverity.error
                : MessageSeverity.success);

        // Respond to the request
        HttpResponse a = request.response
          ..statusCode = accessToken == null ? 404 : 200
          ..headers.contentType = ContentType.html
          ..write(accessToken == null
              ? 'Failed to Authorize'
              : 'Authorized Successfully!');
        wtLog.info('closing server...', verbose: true);
        await a.close();
        break;
      } else {
        // Handle other requests
        HttpResponse s = request.response
          ..statusCode = 404
          ..write('Not Found');
        await s.close();
        break;
      }
    }
    await server.close(force: true);
    return;
  } catch (e) {
    wtLog.error(e.toString());
    return;
  }
}
