import 'package:args/command_runner.dart';
import 'package:dash_cli/src/commands/auth/auth.dart';
import 'package:dash_cli/src/core/auth.dart';
import 'package:dash_cli/src/utils/env.dart';
import 'package:dash_cli/src/utils/logger.dart';

Future<void> main(List<String> args) async {
  CommandRunner<Object> runner = CommandRunner<Object>('dash_cli',
      'Dash enables you to generate your AI assisted developer agents.')
    ..addCommand(LoginCommand())
    ..addCommand(LogoutCommand());
  try {
    DashCliEnv.instance.load();
    await Auth.refreshToken();
    await runner.run(args);
  } catch (e, stackTrace) {
    if (e is UsageException) {
      wtLog.error(e.message);
      wtLog.log(e.usage);
      return;
    }
    wtLog.error(e.toString());
    wtLog.info(stackTrace.toString(), verbose: true);
  }
}
