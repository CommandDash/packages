import 'package:args/command_runner.dart';
import 'package:commanddash/grpc/task_processor.dart';
import 'package:commanddash/utils/cli_utils.dart';
import 'package:grpc/grpc.dart';

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
    CLIUtils.terminateOnExit();

    final server = Server.create(services: [TaskProcessor()]);
    await server.serve(port: 50051);
    print('Server listening on port ${server.port}...');
  }
}
