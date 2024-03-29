import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/http.dart';

class AgentRepository {
  final baseUrl = 'http://127.0.0.1:5000';

  Future<String> publishAgent(Map agentJson) async {
    agentJson['testing'] = true;
    final response = await http.post(Uri.parse('$baseUrl/agent/deploy-agent'),
        body: jsonEncode(agentJson),
        headers: {"Content-Type": "application/json"});

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['status'];
    } else {
      throw (_handleErrorStatusCodes(response));
    }
  }

  String _handleErrorStatusCodes(Response response) {
    final responseResult = response.body;

    if (response.statusCode == 403 && responseResult.isEmpty) {
      return '🚨 Error: Unable to connect to commanddash. Please check the network connectivity';
    }

    if (responseResult.isEmpty) {
      return "Unknown Exception. Please reach out to team@commanddash.dev for resolution.";
    }

    final errorMessage = jsonDecode(responseResult)['error'];
    if (response.statusCode == 500) {
      return "🚨 Error: $errorMessage";
    } else if (response.statusCode == 503) {
      return "🚨 Error: $errorMessage";
    } else {
      return "Unknown Exception. Please reach out to team@commanddash.dev for resolution. Details: ${response.body}";
    }
  }
}
