import 'package:dash_agent/data/datasource.dart';
import 'package:dash_agent/extension/list_extension.dart';
import 'package:dash_agent/variables/dash_input.dart';
import 'package:dash_agent/variables/dash_output.dart';
import 'package:meta/meta.dart';

/// [Step] is a single operation in a series for a command.
///
/// Supported Step Examples: [MatchDocumentStep], [WorkspaceQueryStep], [PromptQueryStep], [AppendToChatStep]  etc
abstract class Step {
  String get version;

  Future<Map<String, dynamic>> process();

  List<DashOutput> get dashOutputs;
}

/// Find matching documents from provided datasources.
///
/// Example:
/// ```
/// // Datasources
/// final DataSource docsSource;
///
/// // Inputs
/// final userQuery = StringInput('Your query', optional: false);
/// final codeAttachment = CodeInput('Primary method');
///
/// // Output
/// final matchingDocuments = MatchDocumentOuput()
///
/// return [MatchDocumentStep(query: '$userQuery$codeAttachment', dataSources: [docsSource], output: matchingDocuments)]
/// ```
class MatchDocumentStep extends Step {
  MatchDocumentStep(
      {required this.query, required this.dataSources, required this.output});

  /// String interpolated query with mix of inputs and outputs.
  ///
  /// Examples:
  /// ```
  /// final userInstruction = StringInput();
  /// query = "$userInstruction";
  /// // or
  /// final codeAttachment = CodeInput();
  /// query = "Tests similar to $codeAttachment";
  /// ```
  final String query;

  /// List of datasources to query relevant documents from.
  final List<DataSource> dataSources;

  /// Stores matching documents to be used in the further steps.
  final MatchDocumentOuput output;

  @override
  Future<Map<String, dynamic>> process() async {
    final Map<String, dynamic> processedJson = {
      'type': 'search_in_sources',
      'query': query,
      'data_sources': [for (final dataSource in dataSources) '$dataSource'],
      'outputs': [for (final dashOutput in dashOutputs) '$dashOutput'],
      'version': version
    };
    return processedJson;
  }

  @override
  String get version => '0.0.1';

  @override
  List<DashOutput> get dashOutputs => [output];
}

/// Find matching code snippets from user's workspace.
///
/// For (X) query or code input, semantically matching snippets (x1), (x2), (x3) etc are extracted.
///
/// Examples of (x):
/// - 'Bloc files of $codeAttachment' => will return all top files (state, event, controller) from user's workspace relevant to the code attachment.
/// - 'Repository Tests` => will return the top tests for repository object's from user's workspace.
///
/// These come in handy as context to be passed in the prompt. Remember this is semantic embedding matching and is not 100% accurate.
///
/// Usage:
/// ```
/// final userQuery = StringInput('Your query');
/// final matchingDocuments = MatchDocumentOuput();
///
/// return [
///   WorkspaceQueryStep(query: '$userQuery', output: matchingCode)
/// ];
/// ```
class WorkspaceQueryStep extends Step {
  WorkspaceQueryStep({required this.query, required this.output});

  final String query;
  final MultiCodeObject output;
  @override
  Future<Map<String, dynamic>> process() async {
    final Map<String, dynamic> processedJson = {
      'type': 'search_in_workspace',
      'query': query,
      'outputs': [for (final dashOutput in dashOutputs) '$dashOutput'],
      'version': version
    };
    return processedJson;
  }

  @override
  String get version => '0.0.1';

  @override
  List<DashOutput> get dashOutputs => [output];
}

/// Perform a message request to the model with your customized prompt.
///
/// Example:
/// ```
/// final promptOutput = PromptOutput();
/// return [
///   PromptQueryStep(
///     prompt: '''You are an X agent. Here is the $userQuery, here is the $codeAttachment $matchingCode and the document references: $matchingDocuments. Answer the user's query.''',
///     promptOutput: promptOutput,
///   )
/// ];
/// ```
class PromptQueryStep extends Step {
  PromptQueryStep({required this.prompt, this.promptOutput, this.codeOutput})
      : assert(!(promptOutput == null && codeOutput == null),
            'Both Prompt and Code Outputs cannot be null');

  /// String interpolated prompt with mix of inputs and outputs.
  ///
  /// Examples:
  /// ```
  /// final userInstruction = StringInput();
  /// final codeAttachment = CodeInput();
  /// final workspaceFiles = MultiCodeObject()
  /// prompt = "Apply the user's instruction: $userInstruction on the following code: $codeAttachment. Here are the relevant workspace files: ${workspaceFiles}";
  /// ```
  final String prompt;

  /// Response received from the message request.
  ///
  /// Append to chat or use in other steps.
  final PromptOutput? promptOutput;

  /// [codeOutput] is experimental and is not adviced for usage. 🚨
  ///
  /// Extract the last inline code snippet from the [promptOutput].
  ///
  /// Returns prompt output string itself if no code snippets between ``` <code snippet> ``` are found. Happens when the model returns the code directly as string without code blocks.
  @experimental
  final CodeOutput? codeOutput;

  @override
  Future<Map<String, dynamic>> process() async {
    final Map<String, dynamic> processedJson = {
      'type': 'prompt_query',
      'prompt': prompt,
      'outputs': [for (final dashOutput in dashOutputs) '$dashOutput'],
      'version': version
    };

    return processedJson;
  }

  @override
  String get version => '0.0.1';

  @override
  List<DashOutput> get dashOutputs =>
      [promptOutput, codeOutput].nonNull();
}

/// Appends the value to the chat.
///
/// This is the recommended way of sending response back to the user.
///
/// [value] could be string interpolated mix of inputs and outputs.
///
/// Example:
/// ```
/// final promptOutput = PromptOutput();
/// return [
///   PromptQueryStep(prompt:'Hi, what is the best way to add a List View in Flutter?', promptOutput: promptOutput),
///   AppendToChatStep(value: '$promptOutput')
/// ]
/// ```
class AppendToChatStep extends Step {
  AppendToChatStep({required this.value});
  final String value;

  @override
  Future<Map<String, dynamic>> process() async {
    final Map<String, dynamic> processedJson = {
      'type': 'append_to_chat',
      'value': value,
      'version': version
    };
    return processedJson;
  }

  @override
  String get version => '0.0.1';

  @override
  List<DashOutput> get dashOutputs => [];
}

/// [ReplaceCodeStep] is experimental and is not adviced for usage. 🚨
///
/// Replaces the user's [CodeInput] with a resulting [CodeOutput].
///
/// A diff view of the changes is displayed within the editor with an option to accept or decline.
@experimental
class ReplaceCodeStep extends Step {
  ReplaceCodeStep(
      {required this.previousCode,
      required this.updatedCode,
      required this.userAcceptDecision});
  final CodeInput previousCode;
  final CodeOutput updatedCode;
  final BooleanOutput userAcceptDecision;
  @override
  Future<Map<String, dynamic>> process() async {
    final Map<String, dynamic> processedJson = {
      'type': 'replace_code',
      'previous_code': '$previousCode',
      'updated_code': '$updatedCode',
      'user_accept_decision': '$userAcceptDecision',
      'version': version
    };
    return processedJson;
  }

  @override
  String get version => '0.0.1';

  @override
  List<DashOutput> get dashOutputs => [userAcceptDecision];
}

/// [ContinueDecisionStep] is experimental and is not adviced for usage. 🚨
///
/// Acts as a decision maker if to continue with the next steps.
///
/// If [boolean] is false, terminates the steps and marks the agent process as done.
@experimental
class ContinueDecisionStep extends Step {
  final BooleanOutput boolean;
  ContinueDecisionStep({required this.boolean});

  @override
  Future<Map<String, dynamic>> process() async {
    return {
      'type': 'continue_decision',
      'boolean': '$boolean',
      'version': version
    };
  }

  @override
  List<DashOutput> get dashOutputs => [];

  @override
  String get version => '0.0.1';
}
