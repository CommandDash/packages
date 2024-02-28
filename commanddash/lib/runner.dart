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
