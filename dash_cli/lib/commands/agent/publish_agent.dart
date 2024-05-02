import 'dart:async';

import 'package:args/command_runner.dart';
import 'package:dash_cli/utils/consts.dart';

import '../../cli_operations/agent_operations.dart';
import '../../core/auth.dart';
import '../../utils/logger.dart';

class PublishAgentCommand extends Command<Object> {
  late bool isTest;
  PublishAgentCommand() {
    argParser.addFlag('test', abbr: 't', callback: (p0) => isTest = p0);
  }
  @override
  String get description => 'Publish the agent to command dash server';

  @override
  String get name => 'publish';

  @override
  Future<void> run() async {
    AuthStatus isUserLoggedIn = await Auth.isAuthenticated;

    if (isUserLoggedIn == AuthStatus.notAuthenticated) {
      wtLog.info('You are not logged in');
      return;
    } else if (isUserLoggedIn == AuthStatus.authenticationExpired) {
      final tokenRefreshed = await Auth.refreshToken();

      // token refreshed failed. Stopping the further command execution
      if (!tokenRefreshed) {
        return;
      }
    }

    await AgentOperation().publishAgent(isTest);
  }
}
