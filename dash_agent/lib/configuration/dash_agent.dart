import 'package:dash_agent/configuration/command.dart';
import 'package:dash_agent/configuration/metadata.dart';
import 'package:dash_agent/data/datasource.dart';

/// Base class for creating agent. [AgentConfiguration] requires following
///  properties passed:
/// - `registerDataSources` - List of [DataSource]s that will be used by agent
/// commands to perform designated tasks
/// - `registerSupportedCommands` - List of [Command]s that will be supported by
/// the agent. This should contain atleast one `Command` for the agent to be
/// meanigful
///
/// Agents are like bots for IDE who can do tasks that predefined in the form of
/// [Command]s. This tasks can vary from code generation, code analysis, code
/// refactoring, and many more. Agent Configuration also requires the mention of
/// list of `DataSource` that can be used as a reference/knowledge for the agent
/// to perform the tasks with proper context knowledge.
///
/// Sample example of [AgentConfiguration] for demonstration purpose:
/// ```dart
/// class MyAgent extends AgentConfiguration {
///   final docsSource = DocsDataSource();
///   final blogsSource = BlogsDataSource();
///
///   @override
///   List<DataSource> get registerDataSources => [docsSource, blogsSource];
///
///   @override
///   List<Command> get registerSupportedCommands =>
///       [AskCommand(docsSource: docsSource)];
/// }
/// ```
abstract class AgentConfiguration {
  /// Metadata for agent like agent name and agent avatar can be provided
  /// using the getter. You can also share the tags related to agent that are
  /// related to agent's domain of use for better visibility in the marketplace.
  ///
  /// `name` of the agent is madatory while `avatarProfile` and `tags` are
  /// optional.
  ///
  /// Example:
  /// ```dart
  ///  @override
  ///  Metadata get metadata => Metadata(
  ///      name: 'My Agent',
  ///      avatarProfile: 'assets/images/agent_avatar.png',
  ///      tags: ['flutter', 'dart'],
  ///  );
  /// ```
  Metadata get metadata;

  /// List of [DataSource]s that will be used by agent commands to perform
  /// designated tasks.
  ///
  /// Example:
  /// ```dart
  /// class DocsDataSource extends DataSource {
  ///  @override
  ///  List<FileDataObject> get fileObjects => [
  ///        FileDataObject.fromFile(File(
  ///            'your_file_path'))
  ///      ];
  ///
  ///  @override
  ///  List<ProjectDataObject> get projectObjects => [];
  ///
  ///  @override
  ///  List<WebDataObject> get webObjects => [];
  /// }
  ///
  /// class BlogsDataSource extends DataSource {
  ///  @override
  ///  List<FileDataObject> get fileObjects => [];
  ///
  ///  @override
  ///  List<ProjectDataObject> get projectObjects => [];
  ///
  ///  @override
  ///  List<WebDataObject> get webObjects =>
  ///      [WebDataObject.fromWebPage('https://sampleurl.com')];
  /// }
  ///
  /// class MyAgent extends AgentConfiguration {
  ///   final docsSource = DocsDataSource();
  ///   final blogsSource = BlogsDataSource();
  ///
  ///   @override
  ///   List<DataSource> get registerDataSources => [docsSource, blogsSource];
  ///
  ///   // Rest of the code
  ///   ...
  /// }
  /// ```
  List<DataSource> get registerDataSources;

  /// Default chat mode (also known as the commandless mode) for the agent.
  /// This will be active by default when the agent is activated. It has two
  /// parameters - `systemPrompt` and `dataSources`:
  /// - `systemPrompt`: It is the instruction provided to agent that is used
  /// to set the context and guide the agent on how to respond to the user request.
  /// - `dataSources`: This is optional. Default the agent will use all the registered
  /// datasources to respond to user's queries but if provided explicitly the agent
  /// will only use the selective list of data sources mentioned to providing
  /// references to answer user queries.
  ///
  /// Example:
  /// ```dart
  ///  @override
  ///  ChatMode get registerAgentDefaultMode => ChatMode(
  ///     systemPrompt: '''You are a Flutter expert who answers user queries related to the framework.
  ///
  ///   Note:
  ///   1. If the references don't address the question, state that "I couldn't fetch your answer from the doc sources, but I'll try to answer from my own knowledge".
  ///   2. Be truthful, complete and detailed with your responses and include code snippets wherever required''',
  ///   dataSources: [DocsDataSource(), BlogsDataSource()]
  ///   );
  /// ```
  String get registerSystemPrompt;

  /// List of [Command]s that will be supported by
  /// the agent. This should contain atleast **one** `Command` for the agent to be
  /// meanigful. Learn more about `Command` by looking at its definition.
  List<Command> get registerSupportedCommands;
}

extension DeclarativeHelpers on List<DataSource> {
  /// Adds unique identifier to each [DataSource] in the list.
  ///
  /// Example:
  /// ```dart
  /// final dataSources = [
  ///   DocsDataSource(),
  ///   BlogsDataSource()
  /// ].withIds(['docs_source', 'blogs_source']);
  /// print(dataSources); // Outputs: [{id: docs_source}, {id: blogs_source}]
  /// ```
  List<DataSource> withIds(List<String> ids) {
    return [];
  }
}
