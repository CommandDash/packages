import 'package:args/command_runner.dart';
import 'package:dash_cli/commands/auth/auth.dart';
import 'package:dash_cli/core/auth.dart';
import 'package:dash_cli/utils/env.dart';
import 'package:dash_cli/utils/logger.dart';
import 'package:dash_cli/commands/agent/create_agent.dart';
import 'package:dash_cli/commands/agent/publish_agent.dart';

Future<void> main(List<String> args) async {
  CommandRunner<Object> runner = CommandRunner<Object>('dash_cli',
      'Dash enables you to generate your AI assisted developer agents.')
    ..addCommand(LoginCommand())
    ..addCommand(LogoutCommand())
    ..addCommand(CreateAgentCommand())
    ..addCommand(PublishAgentCommand());
  ;
  try {
    DashCliEnv.instance.load();
    await Auth.refreshToken();
    await runner.run(args);
  } catch (e, stackTrace) {
    // wtTelemetry.trackError(
    //     severity: Severity.critical, error: e, stackTrace: stackTrace);
    print(e);
    if (e is UsageException) {
      wtLog.error(e.message);
      wtLog.log(e.usage);
      return;
    }
    wtLog.error(e.toString());
    wtLog.info(stackTrace.toString(), verbose: true);
  } finally {
    // await wtTelemetry.flush();
    wtLog.warning('Thank you for using dash');
  }
}
