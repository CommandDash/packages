class SimpleAgentTemplate {
  static String get main => r'''
import 'package:dash_agent/dash_agent.dart';
import 'package:{project_name}/agent.dart';

/// Entry point used by the [dash-cli] to extract your agent configuration during publishing.
Future<void> main() async {
  await processAgent(MyAgent());
}
''';

  static String get myAgent => r'''
import 'package:dash_agent/configuration/metadata.dart';
import 'package:dash_agent/data/datasource.dart';
import 'package:dash_agent/configuration/command.dart';
import 'package:dash_agent/configuration/dash_agent.dart';
import 'commands/ask.dart';
import 'data_sources.dart';

/// [MyAgent] consists of all your agent configuration.
///
/// This includes:
/// [DataSource] - For providing additional data to commands to process.
/// [Command] - Actions available to the user in the IDE, like "/ask", "/generate" etc
class MyAgent extends AgentConfiguration {
  final docsDataSource = DocsDataSource();

  @override
  Metadata get metadata => Metadata(
      name: 'Your Agent Name', avatarProfile: 'assets/logo.png', tags: []);

  @override
  String get registerSystemPrompt => {system_prompt};

  @override
  List<DataSource> get registerDataSources => [docsDataSource];

  @override
  List<Command> get registerSupportedCommands => [
        // AskCommand(docsSource: docsDataSource)
      ];
}
'''
      .replaceAll('{system_prompt}',
          "'''You are an X assistant. Help users in doing Y'''");

  static String get dataSources => r'''
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
  List<WebDataObject> get webObjects => [WebDataObject.fromSiteMap('https://sampleurl.com/sitemap.xml')];
}
''';

  static String get askCommand => r"""
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
  final userQuery = StringInput('Query');
  final codeAttachment = CodeInput(
    'Code Reference',
    optional: true
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
            '''You are a X agent. Here is the user query: $userQuery, here is a reference code snippet: $codeAttachment and some relevant documents for your reference: $matchingDocuments. 
            
            Answer the user's query.''',
        promptOutput: promptOutput,
      ),
      AppendToChatStep(value: '$promptOutput')
    ];
  }
}
""";

  static String get readme => '''
# Agent Reamde File

This is a sample readme file for agent. You add description about the agent and any other instruction or information.
''';
}
