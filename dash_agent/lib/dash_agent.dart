import 'dart:convert';

import 'package:dash_agent/configuration/dash_agent.dart';

import 'helpers/min_cli_version_helper.dart';

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

  json['version'] = configuration.version;

  json['cli_version'] = getMinCLIVersion(json);
  print(jsonEncode(json));
}
