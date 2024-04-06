import 'dart:convert';
import 'dart:io';

import 'package:dash_cli/utils/terminal_commands/run_terminal_command.dart';

class IsolateFunction {
  static Future<void> _createExecutable(String projectPath) async {
    await runCommand('dart', [
      'compile',
      'exe',
      '$projectPath/bin/main.dart',
      '-o',
      '$projectPath/.dart_tool/temp_executable.exe'
    ]);
  }

  static Future<Map> getAgentJson(String projectPath) async {
    // create the executable file that can be spawned later on
    await _createExecutable(projectPath);

    // get the agent json data
    final executablePath = '$projectPath/.dart_tool/temp_executable.exe';
    //  Launch the external project executable as a subprocess
    Process process = await Process.start(executablePath, []);

    // Set up communication channels using stdin/stdout
    final agentString = await process.stdout.transform(utf8.decoder).first;

    // before closing the function dispose
    await _dispose(projectPath);

    return jsonDecode(agentString);
  }

  static Future<void> _dispose(String projectPath) async {
    await runCommand('rm', ['$projectPath/.dart_tool/temp_executable.exe']);
  }
}
