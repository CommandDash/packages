import 'package:args/command_runner.dart';
import 'package:dash/utils/commands/agent/create_agent.dart';
import 'package:dash/utils/logger.dart';

Future<void> main(List<String> args) async {
  var runner = CommandRunner(
      "dash", "Dash enables you to generate your AI assisted developer agents.")
    ..addCommand(CreateAgentCommand());
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
