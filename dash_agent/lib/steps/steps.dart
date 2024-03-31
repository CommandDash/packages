import 'package:dash_agent/data/datasource.dart';
import 'package:dash_agent/variables/dash_input.dart';
import 'package:dash_agent/variables/dash_output.dart';

/// A single operation in a series of steps for a command.
///
/// Supported Step Examples: [MatchDocumentStep], [WorkspaceQueryStep] etc
abstract class Step {
  String get version;

  Future<Map<String, dynamic>> process();

  List<DashOutput?> get dashOutputs;
}

/// Find Matching Documents from provided datasources.
class MatchDocumentStep extends Step {
  MatchDocumentStep(
      {required this.query, required this.dataSources, required this.output});

  /// String interpolated query with mix of inputs and outputs.
  ///
  /// Examples:
  /// ```
  /// final userInstruction = StringInput();
  /// final codeAttachment = CodeInput();
  /// query = "Apply the user's instruction: $userInstruction on the following code: $codeAttachment";
  /// // or
  /// final workspaceFiles = MultiCodeObject()
  /// query = "Tests similar to $workspaceFiles";
  /// ```
  final String query;

  /// List of registered datasources to run the query match and return relevant documents.
  final List<DataSource> dataSources;

  /// All matching documents are stored as [output] and can be used in the further steps.
  final MatchDocumentOuput output;

  @override
  Future<Map<String, dynamic>> process() async {
    final Map<String, dynamic> processedJson = {
      'type': 'search_in_sources',
      'query': query,
      'data_sources': [for (final dataSource in dataSources) '$dataSource'],
      'output': '$output',
      'version': version
    };
    return processedJson;
  }

  @override
  String get version => '0.0.1';

  @override
  List<DashOutput?> get dashOutputs => [output];
}

class WorkspaceQueryStep extends Step {
  WorkspaceQueryStep({required this.query, required this.output});

  final String query;
  final MultiCodeObject output;
  @override
  Future<Map<String, dynamic>> process() async {
    final Map<String, dynamic> processedJson = {
      'type': 'search_in_workspace',
      'query': query,
      'output': '$output',
      'version': version
    };
    return processedJson;
  }

  @override
  String get version => '0.0.1';

  @override
  List<DashOutput?> get dashOutputs => [output];
}

/// Perform a Message Request to the LLM with your customized prompt.
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

  /// Extract the last inline code snippet from the [promptOutput].
  final CodeOutput? codeOutput;

  @override
  Future<Map<String, dynamic>> process() async {
    final Map<String, dynamic> processedJson = {
      'type': 'prompt_query',
      'prompt': prompt,
      'prompt_output': '$promptOutput',
      'code_output': '$codeOutput',
      'version': version
    };

    return processedJson;
  }

  @override
  String get version => '0.0.1';

  @override
  List<DashOutput?> get dashOutputs => [promptOutput, codeOutput];
}

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
  List<DashOutput?> get dashOutputs => [];
}

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
  List<DashOutput?> get dashOutputs => [userAcceptDecision];
}

/// Use to decide if the steps should continue ahead.
///
/// No, if [boolean] value is false.
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
  List<DashOutput?> get dashOutputs => [];

  @override
  String get version => '0.0.1';
}
