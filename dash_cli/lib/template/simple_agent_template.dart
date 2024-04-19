class SimpleAgentTemplate {
  static const main = r'''
import 'package:dash_agent/dash_agent.dart';

import '../lib/my_agent.dart';

// Boiler plate code to processes your agent
Future<void> main() async {
  await processAgent(MyAgent());
}
''';

  static const myAgent = r'''
import 'package:dash_agent/data/datasource.dart';
import 'package:dash_agent/configuration/command.dart';
import 'package:dash_agent/configuration/dash_agent.dart';

import 'ask_command.dart';
import 'data_sources.dart';

/// Your agent configurations
class MyAgent extends AgentConfiguration {
  final docsSource = DocsDataSource();
  final blogsSource = BlogsDataSource();

  @override
  List<DataSource> get registeredDataSources => [docsSource, blogsSource];

  @override
  List<Command> get registerSupportedCommands =>
      [AskCommand(docsSource: docsSource)];
}
''';

  static const dataSources = r'''
import 'dart:io';

import 'package:dash_agent/data/datasource.dart';
import 'package:dash_agent/data/objects/project_data_object.dart';
import 'package:dash_agent/data/objects/system_data_object.dart';
import 'package:dash_agent/data/objects/web_data_object.dart';

class DocsDataSource extends DataSource {
  @override
  List<FileDataObject> get fileObjects => [
        SystemDataObject.fromFile(File(
            'your_file_path'))
      ];

  @override
  List<ProjectDataObject> get projectObjects =>
      [ProjectDataObject.fromText('Data in form of raw text')];

  @override
  List<WebDataObject> get webObjects => [];
}

class BlogsDataSource extends DataSource {
  @override
  List<FileDataObject> get fileObjects => [
        DirectoryFiles(
            Directory(
                'directory_path_to_data_source'),
            relativeTo:
                'parent_directory_path')
      ];

  @override
  List<ProjectDataObject> get projectObjects => [];

  @override
  List<WebDataObject> get webObjects =>
      [WebDataObject.fromWebPage('https://sampleurl.com')];
}

''';

static const askCommand = r"""
import 'package:dash_agent/configuration/command.dart';
import 'package:dash_agent/data/datasource.dart';
import 'package:dash_agent/steps/steps.dart';
import 'package:dash_agent/variables/dash_input.dart';
import 'package:dash_agent/variables/dash_output.dart';

class AskCommand extends Command {
  AskCommand({required this.docsSource});

  final DataSource docsSource;

  /// Inputs
  final userQuery = StringInput('Your query', optional: false);
  final codeAttachment = CodeInput(
    'Primary method',
  );

  final testMethod = CodeInput(
    'Test Method',
  );
  final references = CodeInput('Existing References', optional: true);
  @override
  String get slug => '/ask';

  @override
  String get intent => 'Ask me anything';

  @override
  String get textFieldLayout =>
      "Hi, I'm here to help you. $userQuery $codeAttachment";

  @override
  List<DashInput> get registerInputs => [userQuery, codeAttachment];

  @override
  List<Step> get steps {
    // Outputs
    final matchingDocuments = MatchDocumentOuput();
    final matchingCode = MultiCodeObject();
    final promptOutput = PromptOutput();
    return [
      MatchDocumentStep(
          query: '$userQuery$codeAttachment',
          dataSources: [docsSource],
          output: matchingDocuments),
      WorkspaceQueryStep(query: '$matchingDocuments', output: matchingCode),
      PromptQueryStep(
        prompt:
            '''You are an X agent. Here is the $userQuery, here is the $codeAttachment $matchingCode and the document references: $matchingDocuments. Answer the user's query.''',
        promptOutput: promptOutput,
      ),
      AppendToChatStep(
          value:
              'This was your query: $userQuery and here is your output: $promptOutput')
    ];
  }
}
""";

static const readme = '''
# Agent Reamde File

This is a sample readme file for agent. You add description about the agent and any other instruction or information.
''';
}
