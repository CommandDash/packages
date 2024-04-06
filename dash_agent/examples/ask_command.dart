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
