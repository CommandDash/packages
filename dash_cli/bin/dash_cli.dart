import 'package:args/command_runner.dart';
import 'package:dash_cli/src/commands/auth/auth.dart';
import 'package:dash_cli/src/utils/logger.dart';

Future<void> main(List<String> args) async {
  var runner = CommandRunner("welltested",
      "Welltested auto generate tests for your code using AI within minutes.")
    ..addCommand(LoginCommand());
  try {
    await runner.run(args);
  } catch (e, stackTrace) {
    // wtTelemetry.trackError(
    //     severity: Severity.critical, error: e, stackTrace: stackTrace);
    if (e is UsageException) {
      wtLog.error(e.message);
      wtLog.log(e.usage);
      return;
    }
    wtLog.error(e.toString());
    wtLog.info(stackTrace.toString(), verbose: true);
  } finally {
    // await wtTelemetry.flush();
    wtLog.warning('Thank you for using welltested');
  }
}
