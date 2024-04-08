import 'package:commanddash/agent/input_model.dart';
import 'package:commanddash/agent/loader_model.dart';
import 'package:commanddash/agent/output_model.dart';
import 'package:commanddash/models/chat_message.dart';
import 'package:commanddash/models/workspace_file.dart';
import 'package:commanddash/repositories/dash_repository.dart';
import 'package:commanddash/repositories/generation_repository.dart';
import 'package:commanddash/server/task_assist.dart';
import 'package:commanddash/steps/append_to_chat/append_to_chat_step.dart';
import 'package:commanddash/steps/chat/chat_step.dart';
import 'package:commanddash/steps/find_closest_files/search_in_sources_step.dart';
import 'package:commanddash/steps/find_closest_files/search_in_workspace_step.dart';
import 'package:commanddash/steps/prompt_query/prompt_query_step.dart';
import 'package:commanddash/steps/replace_in_file/replace_in_file_step.dart';
import 'package:commanddash/steps/steps_utils.dart';

abstract class Step {
  late StepType type;
  final Loader loader;
  String? outputId;
  Step({
    required this.type,
    required this.loader,
    required this.outputId,
  });

  factory Step.fromJson(Map<String, dynamic> json, Map<String, Input> inputs,
      Map<String, Output> outputs, String agentName, String agentVersion) {
    switch (json['type']) {
      case 'search_in_workspace':
        return SearchInWorkspaceStep.fromJson(
          json,
          (json['query'] as String).replacePlaceholder(inputs, outputs),
        );
      case 'prompt_query':
        return PromptQueryStep.fromJson(
          json,
          (json['query'] as String).replacePlaceholder(inputs, outputs),
        );
      case 'append_to_chat':
        return AppendToChatStep.fromJson(json,
            (json['value'] as String).replacePlaceholder(inputs, outputs));
      case 'chat':
        return ChatStep.fromJson(
            json,
            (json['messages'] != null && inputs[json['messages']] != null)
                ? ChatQueryInput.fromJson(
                        inputs[json['messages']] as Map<String, dynamic>)
                    .messages
                : [],
            (json['query'] as String).replacePlaceholder(inputs, outputs));
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
        );
      default:
        throw Exception('Unknown step type: ${json['type']}');
    }
  }

  Future<Output?> run(
      TaskAssist taskAssist, GenerationRepository generationRepository,
      [DashRepository? dashRepository]) async {
    await taskAssist.processStep(
        kind: 'loader_update',
        args: loader.toJson(),
        timeoutKind: TimeoutKind.sync);
    return null;
  }
}
