import 'package:dash_agent/data/datasource.dart';
import 'package:dash_agent/variables/dash_input.dart';
import 'package:dash_agent/variables/dash_output.dart';

enum PostProcessKind {
  raw,
  code,
}

abstract class Step {
  String get version;
  Future<Map<String, dynamic>> process();
}

class MatchDocumentStep extends Step {
  MatchDocumentStep(
      {required this.query,
      required this.dataSources,
      required this.output,
      this.totalMatchingDocument});

  final String query;
  final List<DataSource> dataSources;
  final int? totalMatchingDocument;
  final MatchDocumentOuput output;

  @override
  Future<Map<String, dynamic>> process() async {
    final Map<String, dynamic> processedJson = {
      'type': 'search_in_sources',
      'query': query,
      'data_sources': [for (final dataSource in dataSources) '$dataSource'],
      'total_matching_document': totalMatchingDocument ?? 0,
      'output': '$output',
      'version': version
    };
    return processedJson;
  }

  @override
  String get version => '0.0.1';
}

enum WorkspaceObjectType { all, file, classes, methods }

class WorkspaceQueryStep extends Step {
  WorkspaceQueryStep(
      {required this.query,
      required this.output,
      this.workspaceObjectType = WorkspaceObjectType.all});

  final String query;
  final WorkspaceObjectType workspaceObjectType;
  final MultiCodeObject output;
  @override
  Future<Map<String, dynamic>> process() async {
    final Map<String, dynamic> processedJson = {
      'type': 'search_in_workspace',
      'query': query,
      'workspace_object_type': workspaceObjectType.name,
      'output': '$output',
      'version': version
    };
    return processedJson;
  }

  @override
  String get version => '0.0.1';
}

class PromptQueryStep extends Step {
  PromptQueryStep({
    required this.prompt,
    required this.output,
    this.postProcessKind = PostProcessKind.raw,
  });
  final String prompt;
  final PostProcessKind postProcessKind;
  final DashOutput? output;
  @override
  Future<Map<String, dynamic>> process() async {
    final Map<String, dynamic> processedJson = {
      'type': 'prompt_query',
      'prompt': prompt,
      'post_process': {
        'type': postProcessKind.name,
      },
      'output': '$output',
      'version': version
    };

    return processedJson;
  }

  @override
  String get version => '0.0.1';
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
}

class ReplaceCodeStep extends Step {
  ReplaceCodeStep({required this.previousCode, required this.updatedCode});
  final CodeInput previousCode;
  final CodeObject updatedCode;
  @override
  Future<Map<String, dynamic>> process() async {
    final Map<String, dynamic> processedJson = {
      'type': 'replace_code',
      'previous_code': '$previousCode',
      'updated_code': '$updatedCode',
      'version': version
    };
    return processedJson;
  }

  @override
  String get version => '0.0.1';
}
