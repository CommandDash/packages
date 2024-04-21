import 'package:args/command_runner.dart';
import 'package:commanddash/server/server.dart';
import 'package:commanddash/server/task_handler.dart';

class ProcessCommand extends Command {
  bool dryrun = false;
  bool testcases = false;
  bool testability = false;

  @override
  String get name => 'process';

  @override
  String get description => 'Initate task processing';

  @override
  Future<void> run() async {
    final server = Server();
    final TaskHandler handler = TaskHandler(server);
    handler.initProcessing();
  }
}

class VersionCommand extends Command {
  @override
  final String name = "version";

  @override
  final String description = "Print the current version of the CLI.";

  VersionCommand();

  @override
  void run() {
    /// It is not possible to fetch version from pubspec.yaml hence assigning manually
    print('0.0.2');
  }
}

class MinCLIVersionCommand extends Command {
  @override
  final String name = "min_cli_version";

  @override
  final String description = "Print the current minimum version of the CLI.";

  MinCLIVersionCommand();

  @override
  void run() {
    print('0.3.2');
  }
}
