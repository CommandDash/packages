import 'package:commanddash/agent/input_model.dart';
import 'package:commanddash/agent/output_model.dart';
import 'package:commanddash/agent/step_model.dart';
import 'package:commanddash/repositories/dash_repository.dart';
import 'package:commanddash/repositories/generation_repository.dart';
import 'package:commanddash/server/task_assist.dart';

class AgentHandler {
  final Map<String, Input> inputs;
  final Map<String, Output> outputs;
  final List<Map<String, dynamic>> steps;
  final GenerationRepository generationRepository;
  final String? githubAccessToken;
  final String agentName;
  final String agentVersion;

  AgentHandler({
    required this.inputs,
    required this.outputs,
    required this.steps,
    required this.generationRepository,
    required this.agentName,
    required this.agentVersion,
    this.githubAccessToken,
  });

  factory AgentHandler.fromJson(Map<String, dynamic> json) {
    final inputs = <String, Input>{};
    for (Map<String, dynamic> input in (json['registered_inputs'] as List)) {
      inputs.addAll({input['id']: Input.fromJson(input)});
    }
    final outputs = <String, Output>{};
    for (Map<String, dynamic> output in (json['registered_outputs'] as List)) {
      outputs.addAll({output['id']: Output.fromJson(output)});
    }
    final List<Map<String, dynamic>> steps =
        (json['steps'] as List).cast<Map<String, dynamic>>();

    final GenerationRepository generationRepository =
        GenerationRepository.fromJson(json['auth_details']);

    return AgentHandler(
      inputs: inputs,
      outputs: outputs,
      steps: steps,
      generationRepository: generationRepository,
      githubAccessToken: json['auth_details']['github_token'],
      agentName: json['agent_name'],
      agentVersion: json['agent_version'],
    );
  }

  Future<void> runTask(TaskAssist taskAssist) async {
    DashRepository? dashRepository;
    if (githubAccessToken != null) {
      dashRepository = DashRepository.fromKeys(githubAccessToken!, taskAssist);
    }
    try {
      for (Map<String, dynamic> stepJson in steps) {
        try {
          final step =
              Step.fromJson(stepJson, inputs, outputs, agentName, agentVersion);
          final results = await step.run(
                  taskAssist, generationRepository, dashRepository) ??
              [];
          if (step.outputIds != null) {
            if (results.isEmpty) {
              taskAssist.sendErrorMessage(
                  message:
                      'No output received from the step where output was expected.',
                  data: {});
            }
            for (int i = 0; i < results.length; i++) {
              final output = results[i];
              if (output is ContinueToNextStepOutput && !output.value) {
                break;
              } else {
                outputs[step.outputIds![i]] = output;
              }
            }
          }
        } catch (e, stackTrace) {
          taskAssist.sendErrorMessage(
              message:
                  'Error processing step ${stepJson['type']}: ${e.toString()}',
              data: {},
              stackTrace: stackTrace);
        }
      }
      taskAssist.sendResultMessage(message: "TASK_COMPLETE", data: {});
    } catch (e, stackTrace) {
      taskAssist.sendErrorMessage(
          message: 'Error processing request: ${e.toString()}',
          data: {},
          stackTrace: stackTrace);
    }
  }
}
