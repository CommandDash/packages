import 'package:dash_agent/configuration/command.dart';
import 'package:dash_agent/data/datasource.dart';

abstract class AgentConfiguration {
  String get version => '0.0.1';
  List<DataSource> get registeredDataSources;
  List<Command> get registerSupportedCommands;
}

extension DeclarativeHelpers on List<DataSource> {
  List<DataSource> withIds(List<String> ids) {
    return [];
  }
}
