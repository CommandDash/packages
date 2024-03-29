import 'dart:convert';

import 'package:dash_agent/configuration/dash_agent.dart';

Future<void> processAgent(AgentConfiguration configuration) async {
  final json = <String, dynamic>{};

  json['data_sources'] = [];
  for (final source in configuration.registeredDataSources) {
    json['data_sources'].add(await source.process());
  }

  json['supported_commands'] = [];

  for (final command in configuration.registerSupportedCommands) {
    json['supported_commands'].add(await command.process());
  }
  // TODO: Implement the min version determining logic
  json['version'] = '1.0.0';

  print(jsonEncode(json));
}
