import 'package:dash_agent/configuration/command.dart';
import 'package:dash_agent/data/datasource.dart';
import 'package:dash_agent/steps/steps.dart';
import 'package:dash_agent/variables/dash_input.dart';
import 'package:dash_agent/variables/dash_output.dart';

class AskCommand extends Command {
  AskCommand({required this.docsSource});

  final DataSource docsSource;

  /// Inputs
  final userQuery = StringInput('Your query');
  final codeAttachment = CodeInput('Code Attachment');

  // Outputs
  final matchingDocuments = MatchDocumentOuput();
  final matchingCode = MultiCodeObject();
  final queryOutput = PromptOutput();

  @override
  String get slug => '/ask';

  @override
  String get intent => 'Ask me anything';

  @override
  List<DashInput> get registerInputs => [userQuery, codeAttachment];

  @override
  List<DashOutput> get registerOutputs =>
      [matchingDocuments, matchingCode, queryOutput];

  @override
  List<Step> get steps => [
        MatchDocumentStep(
            query: '$userQuery$codeAttachment',
            dataSources: [docsSource],
            output: matchingDocuments),
        WorkspaceQueryStep(query: '$matchingDocuments', output: matchingCode),
        PromptQueryStep(
            prompt:
                '''You are an X agent. Here is the $userQuery, here is the $matchingCode and the document references: $matchingDocuments. Answer the user's query.''',
            postProcessKind: PostProcessKind.raw,
            output: queryOutput),
        AppendToChatStep(
            value:
                'This was your query: $userQuery and here is your output: $queryOutput'),
      ];
  // valid interpolation (distintion between input, output and datasources at right places) [use it for command strings as well]
  @override
  String get textFieldLayout =>
      "Hi, I'm here to help you. $userQuery $codeAttachment";
}
