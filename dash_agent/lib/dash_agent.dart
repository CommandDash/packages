import 'package:dash_agent/configuration/dash_agent.dart';

Future<Map<String, dynamic>> processAgent(
    AgentConfiguration configuration) async {
  final json = <String, dynamic>{};

  json['datasources'] = [];
  for (final source in configuration.registeredDataSources) {
    json['datasources'].add(await source.process());
  }

  json['supported_commands'] = [];

  for (final command in configuration.registerSupportedCommands) {
    json['supported_commands'].add(await command.process());
  }
  // TODO: Implement the min version determining logic
  json['version'] = '1.0.0';
  return json;
}
