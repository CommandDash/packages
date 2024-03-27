import 'dart:io';

import '../logger.dart';

Future<void> runCommand(String command, List<String> arguments,
    {String? workingDirectory}) async {
  try {
    final result = await Process.run(command, arguments,
        workingDirectory: workingDirectory);
    if (result.exitCode != 0) {
      throw Exception(result.stderr);
    }
  } catch (e) {
    wtLog.error("Error running command: $command $arguments");
    rethrow;
  }
}
