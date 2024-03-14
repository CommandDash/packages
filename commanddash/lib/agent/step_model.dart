import 'package:commanddash/agent/input_model.dart';
import 'package:commanddash/agent/output_model.dart';
import 'package:commanddash/repositories/generation_repository.dart';
import 'package:commanddash/server/task_assist.dart';
import 'package:commanddash/steps/append_to_chat/append_to_chat_step.dart';
import 'package:commanddash/steps/find_closest_files/search_in_workspace_step.dart';
import 'package:commanddash/steps/prompt_query/prompt_query_step.dart';
import 'package:commanddash/steps/steps_utils.dart';

abstract class Step {
  late StepType type;
  String? outputId;
  Step({
    required this.type,
    required this.outputId,
  });
  factory Step.fromJson(Map<String, dynamic> json, Map<String, Input> inputs,
      Map<String, Output> outputs) {
    switch (json['type']) {
      case 'search_in_sources':
      // return SearchInSourceStep.fromJson(json);
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
            (json['message'] as String).replacePlaceholder(inputs, outputs));
      default:
        throw Exception('Unknown step type: ${json['type']}');
    }
  }

  Future<Output?> run(
      TaskAssist taskAssist, GenerationRepository generationRepository);
}
