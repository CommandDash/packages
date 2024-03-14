import 'package:commanddash/agent/output_model.dart';
import 'package:commanddash/agent/step_model.dart';
import 'package:commanddash/repositories/generation_repository.dart';
import 'package:commanddash/server/task_assist.dart';
import 'package:commanddash/steps/steps_utils.dart';

class PromptQueryStep extends Step {
  final String query;
  PromptQueryStep({
    required String outputId,
    required this.query,
  }) : super(
          outputId: outputId,
          type: StepType.searchInWorkspace,
        );

  factory PromptQueryStep.fromJson(
    Map<String, dynamic> json,
    String query,
  ) {
    return PromptQueryStep(
      outputId: json['output'],
      query: query,
    );
  }

  @override
  Future<DefaultOutput> run(
      TaskAssist taskAssist, GenerationRepository generationRepository) async {
    final response = await generationRepository.getCompletion(query);
    // TODO: Handle parsing here
    return DefaultOutput(response);
  }
}
