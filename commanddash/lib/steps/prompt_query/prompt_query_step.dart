import 'package:commanddash/agent/input_model.dart';
import 'package:commanddash/agent/loader_model.dart';
import 'package:commanddash/agent/output_model.dart';
import 'package:commanddash/agent/step_model.dart';
import 'package:commanddash/repositories/dash_repository.dart';
import 'package:commanddash/repositories/generation_repository.dart';
import 'package:commanddash/server/task_assist.dart';
import 'package:commanddash/steps/prompt_query/prompt_response_parsers.dart';
import 'package:commanddash/steps/steps_utils.dart';

class PromptQueryStep extends Step {
  final String query;
  final List<Output> outputs;
  final List<Input> inputs;
  PromptQueryStep(
      {required List<String>? outputIds,
      required this.outputs,
      required this.query,
      required this.inputs,
      Loader loader = const MessageLoader('Preparing Result')})
      : super(outputIds: outputIds, type: StepType.promptQuery, loader: loader);

  factory PromptQueryStep.fromJson(
    Map<String, dynamic> json,
    String query,
    List<Output> outputs,
    List<Input> inputs,
  ) {
    return PromptQueryStep(
      outputIds:
          (json['outputs'] as List<dynamic>).map((e) => e.toString()).toList(),
      outputs: outputs,
      query: query,
      inputs: inputs,
    );
  }

  @override
  Future<List<Output>> run(
      TaskAssist taskAssist, GenerationRepository generationRepository,
      [DashRepository? dashRepository]) async {
    await super.run(taskAssist, generationRepository);
    List<CodeInput> currentlyAdded = [];
    currentlyAdded.addAll(inputs.whereType<CodeInput>());

    for (CodeInput code in inputs.whereType<CodeInput>()) {
      taskAssist.sendLogMessage(message: "context-requrest", data: {
        "filePath": code.filePath,
        "range": code.range!.toJson(),
      });
      final context = await taskAssist.processStep(
          kind: "context",
          args: {
            "filePath": code.filePath,
            "range": code.range!.toJson(),
          },
          timeoutKind: TimeoutKind.async);
      taskAssist.sendLogMessage(message: "context-recieved", data: context);
    }

    final response = await generationRepository.getCompletion(query);
    final result = <Output>[];
    for (Output output in outputs) {
      if (output is CodeOutput) {
        final parsedResponse =
            CodeExtractPromptResponseParser().parse(response);
        result.add(CodeOutput(parsedResponse));
      } else if (output is DefaultOutput) {
        final parsedResponse = RawPromptResponseParser().parse(response);
        result.add(DefaultOutput(parsedResponse));
      }
    }
    return result;
  }
}
