import 'dart:async';

import 'package:args/command_runner.dart';
import 'package:dash_cli/cli_operations/agent_operations.dart';
import 'package:dash_cli/utils/logger.dart';

class CreateAgentCommand extends Command<Object> {
  @override
  String get description => 'Create an agent project';

  @override
  String get name => 'create';

  @override
  Future<void> run() async {
    late final String? projectName;
    if (argResults == null || argResults!.arguments.isEmpty) {
      projectName = null;
    } else {
      projectName = argResults!.arguments.last;
    }

    if (projectName == null) {
      wtLog.error('Project name is required');
      return;
    }

    await AgentOperation().createAgentProject(projectName);
  }
}
