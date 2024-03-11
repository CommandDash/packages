import 'package:commanddash/agent/input_model.dart';
import 'package:commanddash/agent/output_model.dart';
import 'package:commanddash/agent/step_model.dart';
import 'package:commanddash/repositories/generation_repository.dart';
import 'package:commanddash/server/task_assist.dart';

class AgentHandler {
  final Map<String, Input> inputs;
  final Map<String, Output> outputs;
  final List<Step> steps;
  final GenerationRepository generationRepository;

  AgentHandler({
    required this.inputs,
    required this.outputs,
    required this.steps,
    required this.generationRepository,
  });

  factory AgentHandler.fromJson(Map<String, dynamic> json) {
    final inputs = <String, Input>{};
    for (Map<String, dynamic> input in (json['inputs'] as List)) {
      inputs.addAll({input['id']: Input.fromJson(input)});
    }
    final outputs = <String, Output>{};
    for (Map<String, dynamic> output in (json['outputs'] as List)) {
      outputs.addAll({output['id']: Output.fromJson(output)});
    }
    final steps = <Step>[];
    for (Map<String, dynamic> step in (json['steps'] as List)) {
      steps.add(Step.fromJson(step, inputs, outputs));
    }
    final GenerationRepository generationRepository =
        GenerationRepository.fromJson(json['authdetails']);
    return AgentHandler(
      inputs: inputs,
      outputs: outputs,
      steps: steps,
      generationRepository: generationRepository,
    );
  }

  // factory AgentHandler.fromJson(Map<String, dynamic> json) {
  //   // if authDetails are of gemini -> Gemini repo;
  // }

  void runTask(TaskAssist taskAssist) async {
    // Step is of type SearchInSources -> backend call
    // Step.run(taskAssist);
    for (Step step in steps) {
      await step.run(taskAssist, generationRepository);
    }
  }
}
