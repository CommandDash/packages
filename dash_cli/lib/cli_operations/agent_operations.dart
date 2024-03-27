import 'dart:io';

import 'package:dash/template/simple_agent_template.dart';
import 'package:dash/utils/logger.dart';
import 'package:dash/utils/paths/path_utils.dart';
import 'package:dash/utils/terminal_commands/run_terminal_command.dart';

class AgentOperation {
  Future<void> createAgentProject(String projectName) async {
    // create a sample dart project
    wtLog.log('\n');
    wtLog.startSpinner('creating dart project...');

    try {
      await runCommand('dart', ['create', projectName]);
    } catch (error) {
      wtLog.error('Run into error while creating the dart project: \n$error');
      return;
    }

    final projectPath = '${PathUtils.currentPath}/$projectName';

    // update the bin directory
    wtLog.log('- created dart project.');
    wtLog.updateSpinnerMessage('updating bin directory...');
    final binPath = '$projectPath/bin';
    final binDirectory = Directory(binPath);

    if (binDirectory.existsSync()) {
      final files = binDirectory.listSync().toList();

      // delete all the existing files
      for (final file in files) {
        file.deleteSync();
      }
    } else {
      binDirectory.createSync();
    }

    // add the main file from the template
    File('$binPath/main.dart').writeAsStringSync(SimpleAgentTemplate.main);

    // update the lib directory
    wtLog.log('- updated bin directory.');
    wtLog.updateSpinnerMessage('updating lib directory...');
    final libPath = '$projectPath/lib';
    final libDirectory = Directory(libPath);

    if (libDirectory.existsSync()) {
      final files = libDirectory.listSync().toList();

      // delete all the existing files
      for (final file in files) {
        file.deleteSync();
      }
    } else {
      libDirectory.createSync();
    }

    // add the lib files from the template
    File('$libPath/my_agent.dart')
        .writeAsStringSync(SimpleAgentTemplate.myAgent);
    File('$libPath/data_sources.dart')
        .writeAsStringSync(SimpleAgentTemplate.dataSources);
    File('$libPath/ask_command.dart')
        .writeAsStringSync(SimpleAgentTemplate.askCommand);

    // delete test directory content
    final testPath = '$projectPath/test';
    final testDirectory = Directory(testPath);

    if (testDirectory.existsSync()) {
      final files = testDirectory.listSync().toList();

      for (final file in files) {
        file.deleteSync();
      }
    } else {
      testDirectory.createSync();
    }

    // update readme file
    wtLog.log('- updated lib directory.');
    wtLog.updateSpinnerMessage('updating the reamdme file...');
    final readmeFilePath = '$projectPath/README.md';
    File(readmeFilePath).writeAsStringSync(SimpleAgentTemplate.readme);

    // update the pubspec file
    wtLog.log('- updated reamdme file.');
    wtLog.updateSpinnerMessage('updating the pubspec file..');

    try {
      await runCommand('dart', ['pub', 'add', 'welltested_annotation'],
          workingDirectory: projectPath);
    } catch (error) {
      wtLog.log(
          'Failed to update the pubspec file. Please add the dash_agent dependency manually. Error: \n$error');
      wtLog.stopSpinner();
      return;
    }
    wtLog.log('- updated pubspec file.');
    wtLog.stopSpinner();
    wtLog.info('\nSuccessfully created the project $projectName');
  }
}
