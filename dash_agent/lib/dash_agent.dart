import 'dart:convert';
import 'dart:io';

import 'package:dash_agent/configuration/dash_agent.dart';
import 'package:dash_agent/extension/map_extension.dart';
import 'package:dash_agent/helpers/agent_validation.dart';

import 'helpers/min_cli_version_helper.dart';

Future<void> processAgent(AgentConfiguration configuration) async {
  final json = <String, dynamic>{};

  try {
    json['metadata'] = await configuration.metadata.process();

    // validate metadata
    final avatarPath = json['metadata']['avatar_path'];
    if (avatarPath != null) {
      final avatarFile = File(avatarPath);
      if (avatarFile.existsSync()) {
        json['avatar_path'] = avatarFile.path;
      } else {
        final failureReason = {
          'Agent Validation Error':
              'Avatar path shared doesn\'t exist: $avatarPath'
        }.humanReadableString();
        _handleFailures(failureReason);
        return;
      }
    }

    json['data_sources'] = <Map<String, dynamic>>[];
    for (final source in configuration.registeredDataSources) {
      json['data_sources'].add(await source.process());
    }

    json['chat_mode'] = {
      'system_prompt': configuration.registerSystemPrompt,
      'data_sources': null,
      'version': '0.0.1'
    };

    json['supported_commands'] = <Map<String, dynamic>>[];

    for (final command in configuration.registerSupportedCommands) {
      json['supported_commands'].add(await command.process());
    }

    json['min_cli_version'] = getMinCLIVersion(json);

    // validate the commnads and data source registration
    final commandValidationReponses = <Map<String, Map<String, String>>>[];
    final dataSourcesValidationResponses = <Map<String, String>>[];
    final commands = json['supported_commands'] as List<Map<String, dynamic>>;
    for (final command in commands) {
      final dataSourceValidation =
          AgentValidation.validateCommandDataSourcesRegistration(command);
      final commandValidationResponse =
          AgentValidation.validateDashCommandVariableUsage(command);
      if (commandValidationResponse != null) {
        commandValidationReponses.add(commandValidationResponse);
      }
      if (dataSourceValidation != null) {
        dataSourcesValidationResponses.add(dataSourceValidation);
      }
    }
    if (commandValidationReponses.isNotEmpty &&
        dataSourcesValidationResponses.isNotEmpty) {
      final commandFailureReason = {
        'Agent Validation Error': commandValidationReponses
      }.humanReadableString();
      final dataSourceFailureReason = {
        'DataSource Registration Error': dataSourcesValidationResponses
      }.humanReadableString();
      final failureReason = '$commandFailureReason\n\n$dataSourceFailureReason';
      _handleFailures(failureReason);
      return;
    }

    if (commandValidationReponses.isNotEmpty) {
      final commandFailureReason = {
        'Agent Validation Error': commandValidationReponses
      }.humanReadableString();
      _handleFailures(commandFailureReason);
      return;
    }

    if (dataSourcesValidationResponses.isNotEmpty) {
      final dataSourceFailureReason = {
        'DataSource Registration Error': dataSourcesValidationResponses
      }.humanReadableString();
      _handleFailures(dataSourceFailureReason);
      return;
    }

    print(jsonEncode(json));
    print('END_OF_AGENT_JSON');
  } catch (error, stacktrace) {
    final failureReason = 'Runtime Error - $error\nStackTrace: $stacktrace';
    _handleFailures(failureReason);
    return;
  }
}

void _handleFailures(String failureReason) {
  print('PROCESS_AGENT_FAILURE');
  print(jsonEncode(failureReason));
  print('END_OF_AGENT_JSON');
}
