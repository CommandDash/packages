import 'package:args/command_runner.dart';
import 'package:dash/utils/commands/agent/create_agent.dart';
import 'package:dash/utils/commands/agent/publish_agent.dart';
import 'package:dash/utils/logger.dart';

Future<void> main(List<String> args) async {
  args = ['publish'];
  var runner = CommandRunner("dash_cli",
      "Dash enables you to generate your AI assisted developer agents.")
    ..addCommand(CreateAgentCommand())
    ..addCommand(PublishAgentCommand());
  try {
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
