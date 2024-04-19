import 'dart:convert';

import 'package:dash_agent/configuration/dash_agent.dart';
import 'package:dash_agent/extension/map_extension.dart';
import 'package:dash_agent/helpers/agent_validation.dart';

import 'helpers/min_cli_version_helper.dart';

Future<void> processAgent(AgentConfiguration configuration) async {
  final json = <String, dynamic>{};

  json['data_sources'] = <Map<String, dynamic>>[];
  for (final source in configuration.registeredDataSources) {
    json['data_sources'].add(await source.process());
  }

  json['supported_commands'] = <Map<String, dynamic>>[];

  for (final command in configuration.registerSupportedCommands) {
    json['supported_commands'].add(await command.process());
  }

  json['min_cli_version'] = getMinCLIVersion(json);

  // validate the commnads
  final commandValidationReponse = <Map<String, Map<String, String>>>[];
  final commands = json['supported_commands'] as List<Map<String, dynamic>>;
  for (final command in commands) {
    final validationResponse =
        AgentValidation.validateDashCommandVariableUsage(command);
    if (validationResponse != null) {
      commandValidationReponse.add(validationResponse);
    }
  }
  if (commandValidationReponse.isNotEmpty) {
    throw {'Issues with Agent Configuration': commandValidationReponse}
        .humanReadableString();
  }
  
  print(jsonEncode(json));
}
