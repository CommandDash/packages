import 'package:commanddash/agent/input_model.dart';
import 'package:commanddash/agent/loader_model.dart';
import 'package:commanddash/agent/output_model.dart';
import 'package:commanddash/repositories/dash_repository.dart';
import 'package:commanddash/repositories/gemini_repository.dart';
import 'package:commanddash/server/task_assist.dart';
import 'package:commanddash/steps/append_to_chat/append_to_chat_step.dart';
import 'package:commanddash/steps/find_closest_files/search_in_sources_step.dart';
import 'package:commanddash/steps/find_closest_files/search_in_workspace_step.dart';
import 'package:commanddash/steps/prompt_query/prompt_query_step.dart';
import 'package:commanddash/steps/replace_in_file/replace_in_file_step.dart';
import 'package:commanddash/steps/steps_utils.dart';

abstract class Step {
  late StepType type;
  final Loader loader;
  List<String>? outputIds;
  // List<Output> outputs;
  Step({
    required this.type,
    required this.loader,
    required this.outputIds,
    // required this.outputs,
  });

  factory Step.fromJson(
      Map<String, dynamic> json,
      Map<String, Input> inputs,
      Map<String, Output> outputs,
      String agentName,
      String agentVersion,
      bool isTest) {
    switch (json['type']) {
      case 'search_in_workspace':
        return SearchInWorkspaceStep.fromJson(
          json,
          (json['query'] as String).replacePlaceholder(inputs, outputs),
        );
      case 'prompt_query':
        final outputsList = (json['outputs'] as List<dynamic>).map((e) {
          if (!outputs.containsKey(e)) {
            throw Exception("Output with outputId $e is not registered");
          }
          return outputs[e]!;
        }).toList();
        return PromptQueryStep.fromJson(
          json,
          agentName,
          (json['prompt'] as String),
          outputsList,
          inputs,
          outputs,
        );
      case 'append_to_chat':
        return AppendToChatStep.fromJson(json,
            (json['value'] as String).replacePlaceholder(inputs, outputs));
      case 'replace_in_file':
        final codeInput = inputs[json['replaceInFile']];
        if (codeInput == null) {
          throw Exception('File not found: ${json['replaceInFile']}');
        }
        if (codeInput is! CodeInput) {
          throw Exception(
              'Output is not a CodeInput: ${json['replaceInFile']}');
        }
        return ReplaceInFileStep.fromJson(
          json,
          codeInput,
          (json['query'] as String).replacePlaceholder(inputs, outputs),
        );
      case 'search_in_sources':
        return SearchInSourceStep.fromJson(
            json,
            (json['query'] as String).replacePlaceholder(inputs, outputs),
            agentName,
            agentVersion,
            isTest);
      default:
        throw Exception('Unknown step type: ${json['type']}');
    }
  }

  Future<List<Output>?> run(
      TaskAssist taskAssist, GeminiRepository generationRepository,
      [DashRepository? dashRepository]) async {
    await taskAssist.processStep(
        kind: 'loader_update',
        args: loader.toJson(),
        timeoutKind: TimeoutKind.sync);
    return null;
  }
}
