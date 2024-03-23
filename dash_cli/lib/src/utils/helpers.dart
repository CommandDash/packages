import 'dart:io';

import 'package:dash_cli/src/core/api.dart';
import 'package:dash_cli/src/utils/env.dart';

import 'logger.dart';

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
    url = url.replaceAllMapped(RegExp('([^^])&'), (m) => '${m[1]}^&');
  }
  return Process.run(command(), [url], runInShell: true);
}

Future<void> createServer(String url) async {
  var file = await BaseApi.getInstance.get(Uri.parse(
      'https://gist.githubusercontent.com/yahu1031/02cb413fcacb1a0b8a8bcffdfd120ffd/raw/b370eeaa49ff87cd83f6edca6f1798c1e47f4e8e/index.html'));
  var contents = file.body;
  final address = InternetAddress.loopbackIPv4;
  const port = 8092;
  var server = await HttpServer.bind(address, port);
  await openUrl(url.toString());
  await for (var request in server) {
    print(request.uri.queryParametersAll);
    var accessToken = request.uri.queryParameters['access_token'];
    var refreshToken = request.uri.queryParameters['refresh_token'];
    if (accessToken != null) WelltestedEnv.addNew('access_token', accessToken);
    if (refreshToken != null) {
      WelltestedEnv.addNew('refresh_token', refreshToken);
    }
    if (request.uri.pathSegments.isEmpty) {
      // Handle callback
      var code = request.uri.queryParameters['code'];
      accessToken = request.uri.queryParameters['access_token'];
      if (code != null && accessToken != null) {
        WelltestedEnv.addNew('access_token', accessToken);
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
      var a = request.response
        ..statusCode = accessToken == null ? 404 : 200
        ..headers.contentType = ContentType.html
        ..write(contents.replaceAll(
            '{{{AUTHORIZED_MSG}}}',
            accessToken == null
                ? 'Failed to Authorize'
                : 'Authorized Successfully!'));
      wtLog.info('closing server...');
      await a.close();
      break;
    } else {
      // Handle other requests
      var s = request.response
        ..statusCode = 404
        ..write('Not Found');
      await s.close();
      break;
    }
  }
  wtLog.info('closing server.....');
  await server.close(force: true);
  return;
}
