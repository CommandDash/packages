import 'dart:convert';
import 'dart:io';

import 'package:dash_cli/src/core/api.dart';
import 'package:dash_cli/src/utils/consts.dart';
import 'package:dash_cli/src/utils/env.dart';

import '../utils/helpers.dart';
import '../utils/logger.dart';

class Auth {
  static String _userName = '';

  static Future<String> get userName async {
    try {
      if (_userName.isEmpty) {
        // var key = await apiKey;
        // var info = await UserRepository().getUserInfo(key);
        // _userName = info.firstName + ' ' + info.lastName;
        _userName = 'John Doe';
      }
      return _userName;
    } catch (e) {
      return '';
    }
  }

  // static Future<String> get apiKey async {
  //   try {
  //     final env = DotEnv(includePlatformEnvironment: false)..load();
  //     return env.getOrElse('WELLTESTED_API', () => '');
  //   } catch (e) {
  //     return '';
  //   }
  // }

  // static Future<void> register(RegisterForm form,
  //     {required Function onSuccess,
  //     required Function(String) onFailure}) async {
  //   var request = MultipartRequest(
  //       'POST', Uri.parse('https://api.welltested.ai/account/register'));
  //   request.fields.addAll({
  //     'first_name': form.firstName,
  //     'last_name': form.lastName,
  //     'company': form.company,
  //     'role': form.role.name,
  //     'email': form.email,
  //     'tenure': form.tenure.name,
  //     'account_plan': form.accountPlan.type,
  //   });

  //   StreamedResponse response = await request.send();

  //   if (response.statusCode >= 200 && response.statusCode < 300) {
  //     onSuccess.call();
  //   } else {
  //     stderr.writeln(response.reasonPhrase);
  //     stderr.writeln(request.fields);
  //     onFailure.call(
  //         response.reasonPhrase ?? (await response.stream.bytesToString()));
  //   }
  // }

  static bool logout() => deleteCredentials();

  static Future<void> login(
      {required Function onSuccess,
      required Function(String) onFailure}) async {
    var url = await getLoginUrl(onSuccess: onSuccess, onFailure: onFailure);
    if (url != null) {
      await createServer(url.toString());
      wtLog.stopSpinner();
      wtLog.updateSpinnerMessage('Logged-in successfully!');
      // wtLog.info('Opening browser for login...');
      // await openUrl(url.toString());
    } else {
      wtLog.stopSpinner();
      wtLog.error('Failed to get login url');
    }
  }

  static Future<Uri?> getLoginUrl(
      {required Function onSuccess,
      required Function(String) onFailure}) async {
    try {
      var link = await BaseApi.getInstance
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

  // static bool saveCredentials(UserInfo userInfo, String key) {
  //   var file = WelltestedEnv.configFile;
  //   try {
  //     if (!file.existsSync()) {
  //       file.createSync(recursive: true, exclusive: true);
  //     } else {
  //       var data = file.readAsStringSync();
  //       var jsonMap = data.isEmpty ? {} : json.decode(data);
  //       var tempkey = jsonMap['WELLTESTED_API'] ?? '';
  //       if (tempkey == null || tempkey.toString().isNotEmpty) {
  //         wtLog.stopSpinner();
  //         var confirm = Confirm(
  //           prompt: 'API Key already exists',
  //           defaultValue: false,
  //         ).interact();
  //         if (!confirm) {
  //           return false;
  //         }
  //         wtLog.startSpinner('Updating API Key...');
  //       }
  //     }
  //     file.writeAsStringSync(
  //         json.encode({
  //           'name': userInfo.firstName + ' ' + userInfo.lastName,
  //           'email': userInfo.mailId,
  //           'WELLTESTED_API': key,
  //         }),
  //         mode: FileMode.write,
  //         encoding: utf8,
  //         flush: true);
  //     return true;
  //   } catch (e) {
  //     wtLog.error(e.toString());
  //     return false;
  //   }
  // }

  static bool deleteCredentials() {
    try {
      File file = WelltestedEnv.configFile;
      if (file.existsSync()) {
        file.writeAsStringSync('', mode: FileMode.write, encoding: utf8);
      } else {
        wtLog.warning('No API keys found');
      }
      return true;
    } catch (e) {
      rethrow;
    }
  }
}
