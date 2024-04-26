import 'dart:io';

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
Future<void> createServer(
    String url,
    Future<bool> Function(
            {required String? accessToken,
            required String? refreshToken,
            required String? emailFound})
        serverCallback) async {
  try {
    InternetAddress address = InternetAddress.loopbackIPv4;
    const int port = 8080;
    HttpServer server = await HttpServer.bind(address, port);
    await openUrl(url.toString());
    await for (HttpRequest request in server) {
      if (request.uri.pathSegments.isEmpty) {
        // Handle callback
        String? accessToken = request.uri.queryParameters['access_token'];
        String? refreshToken = request.uri.queryParameters['refresh_token'];
        String? emailFound = request.uri.queryParameters['email_found'];

        final successfullLogin = await serverCallback(
            accessToken: accessToken,
            refreshToken: refreshToken,
            emailFound: emailFound);

        // Respond to the request
        final postRequestReponse = request.response
          ..statusCode = accessToken == null ? 404 : 200
          ..headers.contentType = ContentType.html
          ..write(successfullLogin
              ? 'Authorized Successfully!'
              : 'Failed to Authorize')
          ..write('<script>window.close();</script>');
        await postRequestReponse.close();

        break;
      }
    }

    wtLog.info('closing server...', verbose: true);
    await server.close(force: true);
    return;
  } catch (e) {
    wtLog.error(e.toString());
    return;
  }
}
