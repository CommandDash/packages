import 'package:commanddash/agent/input_model.dart';
import 'package:commanddash/agent/output_model.dart';
import 'package:commanddash/repositories/generation_repository.dart';
import 'package:commanddash/server/task_assist.dart';
import 'package:commanddash/steps/find_closest_files/search_in_workspace_step.dart';

abstract class Step {
  late String type;
  final Map<String, Input> inputs;
  final Map<String, Output> outputs;
  Step({
    required this.type,
    required this.inputs,
    required this.outputs,
  });

  factory Step.fromJson(Map<String, dynamic> json, Map<String, Input> inputs,
      Map<String, Output> outputs) {
    switch (json['type']) {
      case 'search_in_sources':
      // return SearchInSourceStep.fromJson(json);
      case 'search_in_workspace':
        return SearchInWorkspaceStep.fromJson(json, inputs, outputs);
      case 'prompt_query':
      // return PromptQueryStep.fromJson(json);
      case 'append_to_chat':
      // return AppendToChatStep.fromJson(json);
      default:
        throw Exception('Unknown step type: ${json['type']}');
    }
  }

  Future<void> run(
      TaskAssist taskAssist, GenerationRepository generationRepository);
}
