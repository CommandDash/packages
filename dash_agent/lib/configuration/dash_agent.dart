import 'package:dash_agent/configuration/command.dart';
import 'package:dash_agent/data/datasource.dart';

/// Base class for creating agent. [AgentConfiguration] requires following
///  properties passed:
/// - `registeredDataSources` - List of [DataSource]s that will be used by agent
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
///   List<DataSource> get registeredDataSources => [docsSource, blogsSource];
///
///   @override
///   List<Command> get registerSupportedCommands =>
///       [AskCommand(docsSource: docsSource)];
/// }
/// ```
abstract class AgentConfiguration {
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
  ///   List<DataSource> get registeredDataSources => [docsSource, blogsSource];
  ///
  ///   // Rest of the code
  ///   ...
  /// }
  /// ```
  List<DataSource> get registeredDataSources;

  /// List of [Command]s that will be supported by
  /// the agent. This should contain atleast **one** `Command` for the agent to be
  /// meanigful. Learn more about `Command` by looking at its definition.
  List<Command> get registerSupportedCommands;
}

extension DeclarativeHelpers on List<DataSource> {
  List<DataSource> withIds(List<String> ids) {
    return [];
  }
}
