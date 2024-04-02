import 'package:dash_agent/variables/dash_input.dart';
import 'package:dash_agent/steps/steps.dart';
import 'package:dash_agent/variables/dash_output.dart';

/// Base class for creating a command for your agent. For an agent, the command
/// can be understood as an task (such as refactoring, code generation, code
///  analysis, etc) the user can invoke via commanddash.
///
/// [Command] requires following arguments:
/// - `slug` - Unique identifier of the command
/// - `intent` - Brief description about the command
/// - `textFieldLayout` - Phrase that will be shown to user when the command is
/// invoked
/// - `registerInputs` - `DashInput`s that will be used in the command in its
/// lifecycle
/// - `steps` - Series of operation that needs to be performed for a command finish its
/// task. Steps can be of the following nature: Matching docs that are shared
/// with the command, performing a query in the user project, prompt that code/
/// info generation, appending the info/code at the right place in the project,
/// many more.
///
///
/// Sample example of [Command] for demonstration purpose:
/// ```dart
/// class AskCommand extends Command {
///   AskCommand({required this.docsSource});

///   final DataSource docsSource;

///   // Inputs
///   final userQuery = StringInput('Your query');
///   final codeAttachment = CodeInput('Code Attachment');

///   // Outputs
///  final matchingDocuments = MatchDocumentObject();
//   final matchingCode = MultiCodeObject();
//   final queryOutput = QueryOutput();

///   @override
///   String get slug => '/ask';

///   @override
///   String get intent => 'Ask me anything';

///   @override
///   List<DashInput> get registerInputs => [userQuery, codeAttachment];

///   @override
///   List<Step> get steps => [
///         MatchingDocumentStep(
///             query: '$userQuery$codeAttachment',
///             dataSources: [docsSource],
///             output: matchingDocuments),
///         WorkspaceQueryStep(query: '$matchingDocuments', output: matchingCode),
///         PromptQueryStep(
///             prompt:
///                 '''You are an X agent. Here is the $userQuery, here is the $matchingCode and the document references: $matchingDocuments. Answer the user's query.''',
///             postProcessKind: PostProcessKind.raw,
///             output: queryOutput),
///         AppendToChatStep(
///             value:
///                 'This was your query: $userQuery and here is your output: $queryOutput'),
///       ];

///   @override
///   String get textFieldLayout =>
///       "Hi, I'm here to help you. $userQuery $codeAttachment";
/// }
/// ```
abstract class Command {
  String get version => '0.0.1';
  Command();

  /// Unique identifier of the command. For an agent having multiple commands
  /// the slug for each command should be unique.
  ///
  /// Few examples: `/ask`, `/generate`, `/refactor`, etc
  String get slug;

  /// Intent is a brief description about the command which will be used for the
  /// purpose giving the end dev the idea about the capability and use case of
  /// the following command.
  ///
  /// Example: For a firebase agent, the intent for the command `/setup` can be:
  ///  `String get intent => 'Setup firebase in your project';`
  String get intent;

  /// Phrase to shown when the command is invoked by the end dev. Few provide the
  /// devs a good experiece and ease in command use. You can follow few of the good
  /// practises:
  /// - **Keep it Short** - Try to keep the phrase as short and precise much as
  ///  possible.
  /// - **Keep it Useful** - Don't try to include additional words or phrases
  ///  that are not required and don't serve any purpose.
  /// - **Mention Inputs Required by Command** - Make sure to ask all the inputs
  /// (such as the query, code, whatever is needed by the command). So that it
  /// is easier for the end dev to understand the futher inputs that is required
  /// to be shared
  ///
  /// Example:
  /// ```dart

  /// @override
  ///   String get textFieldLayout =>
  ///       "Hey, I'm here to help setting firebase in your project. Please share the firebase services you want to include $userRequirement";
  /// ```
  /// Here, `userRequirement` is DashInput variable whose value will be provided
  /// by the user at runtime
  String get textFieldLayout;

  /// List of `DashInput`s that will be used in the command in its lifecycle.
  /// Learn more about `DashInput` and available type by opening it definition.
  ///
  /// Example, `[StringInput('Your query'), CodeInput('Code Attachment')]`
  List<DashInput> get registerInputs;
  List<DashOutput> get registerOutputs;

  /// Series of operation that needs to be performed for a command finish its
  /// task.
  ///
  /// Supported Step Examples: [MatchDocumentStep], [WorkspaceQueryStep],
  /// [PromptQueryStep], [AppendToChatStep], [ReplaceCodeStep],
  /// [ContinueDecisionStep]
  ///
  /// While creating the series of steps, you may need to pass output of one or more
  /// past steps to a new step. You can achieve this my simply passing the `DashOutput`
  /// defined in the scope of `Command` and used as a object that will store the
  /// of the past steps.
  ///
  /// This is better demonstrated by the below example:
  /// ```dart
  /// // Outputs
  /// final matchingDocuments = MatchDocumentObject();
  /// final matchingCode = MultiCodeObject();
  /// final queryOutput = QueryOutput();
  ///
  /// List<Step> get steps => [
  /// MatchingDocumentStep(
  ///   query: '$userQuery$codeAttachment',
  ///   dataSources: [],
  ///   output: matchingDocuments),
  /// WorkspaceQueryStep(query: '$matchingDocuments', output: matchingCode),
  /// PromptQueryStep(
  ///    prompt:
  ///        '''You are an X agent. Here is the $userQuery, here is the $matchingCode and the document references: $matchingDocuments. Answer the user's query.''',
  ///    postProcessKind: PostProcessKind.raw,
  ///   output: queryOutput),
  /// AppendToChatStep(
  ///    value:
  ///    'This was your query: $userQuery and here is your output: $queryOutput'),
  /// ];
  /// ```
  List<Step> get steps;

  /// Internal method used by dash_agent to convert the shared `Commmand` to json
  /// formated cofiguration that is deployable.
  ///
  /// **Note**: Ideally, this method is not supposed to be overriden by the child
  /// objects and should not be altered. It is called automatically by the framework.
  Future<Map<String, dynamic>> process() async {
    final Map<String, dynamic> processedJson = {};
    List<DashOutput> registerOutputs = [];
    processedJson['slug'] = slug;
    processedJson['intent'] = intent;
    processedJson['text_field_layout'] = textFieldLayout;

    processedJson['steps'] = [];
    for (final step in steps()) {
      registerOutputs.addAll(step.dashOutputs.nonNulls);
      processedJson['steps'].add(await step.process());
    }

    processedJson['registered_inputs'] = [];
    for (final input in registerInputs) {
      processedJson['registered_inputs'].add(await input.process());
    }

    processedJson['registered_outputs'] = [];
    for (final output in registerOutputs.toSet().toList()) {
      processedJson['registered_outputs'].add(await output.process());
    }

    processedJson['version'] = version;
    return processedJson;
  }
}
