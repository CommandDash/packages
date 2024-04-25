class SimpleAgentTemplate {
  static const main = r'''
import 'package:dash_agent/dash_agent.dart';
import 'package:{project_name}/agent.dart';

/// Entry point used by the [dash-cli] to extract your agent configuration during publishing.
Future<void> main() async {
  await processAgent(MyAgent());
}
''';

  static const myAgent = r'''
import 'package:dash_agent/data/datasource.dart';
import 'package:dash_agent/configuration/command.dart';
import 'package:dash_agent/configuration/dash_agent.dart';
import 'package:riverpod/commands/ask.dart';
import 'data_sources.dart';

/// [MyAgent] consists of all your agent configuration.
///
/// This includes:
/// [DataSource] - For providing additional data to commands to process.
/// [Command] - Actions available to the user in the IDE, like "/ask", "/generate" etc
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
import 'package:dash_agent/data/objects/file_data_object.dart';
import 'package:dash_agent/data/objects/web_data_object.dart';

/// [DocsDataSource] indexes all the documentation related data and provides it to commands.
class DocsDataSource extends DataSource {
  @override
  List<FileDataObject> get fileObjects =>
      [FileDataObject.fromFile(File('your_file_path'))];

  @override
  List<ProjectDataObject> get projectObjects =>
      [ProjectDataObject.fromText('Data in form of raw text')];

  @override
  List<WebDataObject> get webObjects => [];
}

/// [BlogsDataSource] is a specific data source indexing blogs stored in filesystem or on web.
///
/// We are not using it in any of the commands.
class BlogsDataSource extends DataSource {
  @override
  List<FileDataObject> get fileObjects => [
        DirectoryFiles(Directory('directory_path_to_data_source'),
            relativeTo: 'parent_directory_path')
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

/// [AskCommand] accepts a [CodeInput] from the user with their query [StringInput] and provides the with a suitable answer taking reference from your provided [docsSource].
class AskCommand extends Command {
  AskCommand({required this.docsSource});

  final DataSource docsSource;

  /// Inputs to be provided by the user in the text field
  final userQuery = StringInput('Your query', optional: false);
  final codeAttachment = CodeInput(
    'Primary method',
  );

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
    // Temporary outputs generated during processing command.
    final matchingDocuments = MatchDocumentOuput();
    final promptOutput = PromptOutput();

    return [
      MatchDocumentStep(
          query: '$userQuery$codeAttachment',
          dataSources: [docsSource],
          output: matchingDocuments),
      PromptQueryStep(
        prompt:
            '''You are an X agent. Here is the $userQuery, here is the $codeAttachment and some relevant documents for your reference: $matchingDocuments. 
            
            Answer the user's query.''',
        promptOutput: promptOutput,
      ),
      AppendToChatStep(value: '$promptOutput')
    ];
  }
}
""";

  static const readme = '''
# Agent Reamde File

This is a sample readme file for agent. You add description about the agent and any other instruction or information.
''';
}
