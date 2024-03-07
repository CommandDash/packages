import 'package:dash_agent/configuration/command.dart';
import 'package:dash_agent/configuration/dash_agent.dart';
import 'package:dash_agent/dash_agent.dart';
import 'package:dash_agent/data/datasource.dart';

import 'ask_command.dart';
import 'data_sources.dart';

void main() {
  processAgent(MyAgent());
}

class MyAgent extends AgentConfiguration {
  final docsSource = DocsDataSource();
  final blogsSource = BlogsDataSource();

  @override
  List<DataSource> get registeredDataSources => [docsSource, blogsSource];

  @override
  List<Command> get registerSupportedCommands =>
      [AskCommand(docsSource: docsSource)];
}
