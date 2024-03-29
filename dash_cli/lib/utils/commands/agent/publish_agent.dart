import 'dart:async';

import 'package:args/command_runner.dart';

import '../../../cli_operations/agent_operations.dart';

class PublishAgentCommand extends Command{
  @override
  String get description => 'Publish the agent to command dash server';

  @override
  String get name => 'publish';


  @override
  Future<void> run() async {
    await AgentOperation().publishAgent();
  }
  
}