import 'package:dash_agent/data/datasource.dart';

class ChatMode {
  /// System prompt is the instruction provided to agent and used to set the
  /// context and guide the agent on how to respond to the user request.
  ///
  /// Example:
  /// ```dart
  /// final chatMode = ChatMode(
  ///   systemPrompt: '''
  /// You are an Flutter expert who answers user's queries related
  /// to the framework based on the references shared.
  ///
  /// Note:
  /// 1. If the references don't address the question, state that "I couldn't fetch your answer from the doc sources, but I'll try to answer from my own knowledge".
  /// 2. Be truthful, complete and detailed with your responses and include code snippets wherever required
  /// ''',
  /// );
  /// ```
  final String systemPrompt;

  /// List of data sources that the agent can access to provide more relevant
  /// information.
  ///
  /// Data sources can be used to provide the agent with access to
  /// documentation, code examples, or other relevant information that can
  /// help it understand the context of the conversation and provide better
  /// responses.
  ///
  /// **Example:**
  /// ```dart
  /// final chatMode = ChatMode(
  ///   systemPrompt: '...', // System prompt
  ///   dataSources: [
  ///     DocsDataSource(), // Provide the Flutter documentation
  ///     CodeExamplesDataSource(), // Provide code examples
  ///   ],
  /// );
  /// ```
  final List<DataSource>? dataSources;

  /// Creates a new instance of [ChatMode] with the provided [systemPrompt]
  /// and optional [dataSources].
  ChatMode({required this.systemPrompt, this.dataSources});

  /// Internal method used by dash_agent to convert the shared `Commmand` to json
  /// formated cofiguration that is deployable.
  ///
  /// **Note**: Ideally, this method is not supposed to be overriden by the child
  /// objects and should not be altered. It is called automatically by the framework.
  Future<Map<String, dynamic>> process() async {
    final dataSources = this.dataSources;
    final Map<String, dynamic> processedJson = {
      'system_prompt': systemPrompt,
      'data_sources': dataSources != null
          ? [for (final dataSource in dataSources) '$dataSource']
          : null,
      'version': version
    };
    return processedJson;
  }

  final String version = '0.0.1';
}
