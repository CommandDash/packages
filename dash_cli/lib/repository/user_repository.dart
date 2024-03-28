import 'dart:convert';
import 'dart:io';

import 'package:dash_cli/core/api.dart';
import 'package:dash_cli/utils/consts.dart';

import '../utils/env.dart';

class UserRepository {
  final baseUrl = CliConstants.baseUrl;

  Future<void> updateEmail(String mailId) async {
    final requestBody = {'email': mailId};

    final response = await BaseApi.getInstance.post(
        Uri.https(baseUrl, CliConstants.updateEmailPath),
        body: jsonEncode(requestBody),
        headers: {
          HttpHeaders.authorizationHeader:
              'Bearer ${DashCliEnv.instance.env.authToken}',
          "Content-Type": "application/json"
        });

    if (response.statusCode <= 200 || response.statusCode > 300) {
      throw 'Failed to update mail id. Please try again or contact commanddash team!\nDetails: ${response.statusCode}: ${response.body}';
    }
  }
}
