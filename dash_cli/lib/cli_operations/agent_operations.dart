import 'dart:io';

import 'package:dash_cli/parsers/pubspec_parser.dart';
import 'package:dash_cli/repository/agent_repository.dart';
import 'package:dash_cli/template/simple_agent_template.dart';
import 'package:dash_cli/utils/logger.dart';
import 'package:dash_cli/utils/paths/path_utils.dart';
import 'package:dash_cli/utils/spawn_isolate.dart';
import 'package:dash_cli/utils/terminal_commands/run_terminal_command.dart';

class AgentOperation {
  final _agentRepository = AgentRepository();

  Future<void> createAgentProject(String projectName) async {
    // create a sample dart project
    wtLog.startSpinner('creating dart project...');

    try {
      await runCommand('dart', ['create', projectName]);
    } catch (error) {
      wtLog.error('Run into error while creating the dart project: \n$error');
      return;
    }

    final projectPath = '${PathUtils.currentPath}/$projectName';

    // update the bin directory
    wtLog.log('Setting up the agent project');
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
    File('$binPath/main.dart').writeAsStringSync(
        SimpleAgentTemplate.main.replaceFirst('{project_name}', projectName));

    // update the lib directory
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
    File('$libPath/agent.dart').writeAsStringSync(SimpleAgentTemplate.myAgent);
    wtLog.log('✔︎ Agent configuration created');
    File('$libPath/data_sources.dart')
        .writeAsStringSync(SimpleAgentTemplate.dataSources);
    wtLog.log('✔︎ Added starter datasources');
    await Directory('$libPath/commands').create();
    File('$libPath/commands/ask.dart')
        .writeAsStringSync(SimpleAgentTemplate.askCommand);
    wtLog.log('✔︎ Added sample commands');

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
    wtLog.updateSpinnerMessage('updating the reamdme file...');
    final readmeFilePath = '$projectPath/README.md';
    File(readmeFilePath).writeAsStringSync(SimpleAgentTemplate.readme);

    // update the pubspec file
    wtLog.updateSpinnerMessage('updating the pubspec file..');

    try {
      await runCommand('dart', ['pub', 'add', 'dash_agent'],
          workingDirectory: projectPath);
    } catch (error) {
      wtLog.log(
          'Failed to update the pubspec file. Please add the dash_agent dependency manually. Error: \n$error');
      wtLog.stopSpinner();
      return;
    }
    wtLog.stopSpinner();
    wtLog.info('\nSuccessfully created the agent project $projectName');
  }

  Future<void> publishAgent() async {
    wtLog.startSpinner('Fetching agent configuration...');
    final projectDirectory = PathUtils.currentPath;
    try {
      final pubSpecData = await PubspecParser.forPath(projectDirectory);

      final agentJson = await IsolateFunction.getAgentJson(projectDirectory);

      final agentName = pubSpecData.packageName;
      final agentDescription = pubSpecData.packageDescription;
      final agentVersion = pubSpecData.packageVersion;

      agentJson['name'] = agentName;
      agentJson['description'] = agentDescription;
      agentJson['version'] = agentVersion;

      wtLog.log('- Agent configuration fetched');
      wtLog.updateSpinnerMessage('Publishing agent...');
      final status = await _agentRepository.publishAgent(agentJson);

      wtLog.log('- Published agent');
      wtLog.stopSpinner();
      wtLog.info(status);
      return;
    } catch (error) {
      wtLog.stopSpinner();
      wtLog.error(error.toString());
      return;
    }
  }
}
