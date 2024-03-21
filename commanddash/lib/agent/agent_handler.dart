import 'package:commanddash/agent/input_model.dart';
import 'package:commanddash/agent/output_model.dart';
import 'package:commanddash/agent/step_model.dart';
import 'package:commanddash/repositories/generation_repository.dart';
import 'package:commanddash/server/task_assist.dart';

class AgentHandler {
  final Map<String, Input> inputs;
  final Map<String, Output> outputs;
  final List<Map<String, dynamic>> steps;
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
    final List<Map<String, dynamic>> steps =
        (json['steps'] as List).cast<Map<String, dynamic>>();

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
    try {
      for (Map<String, dynamic> stepJson in steps) {
        final step = Step.fromJson(stepJson, inputs, outputs);
        final output = await step.run(taskAssist, generationRepository);
        if (output != null &&
            output is ContinueToNextStepOutput &&
            !output.value) {
          break;
        }
        if (step.outputId != null) {
          if (output == null) {
            taskAssist.sendErrorMessage(
                message:
                    'No output received from the step where output was expected.',
                data: {});
          } else {
            outputs[step.outputId!] = output;
          }
        }
      }
      taskAssist.sendResultMessage(message: "TASK_COMPLETE", data: {});
    } catch (e) {
      taskAssist.sendErrorMessage(message: e.toString(), data: {});
    }
  }
}
