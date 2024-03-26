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
  final PromptResponseParser responseParser;
  PromptQueryStep(
      {required String outputId,
      required this.query,
      required this.responseParser,
      Loader loader = const MessageLoader('Preparing Result')})
      : super(outputId: outputId, type: StepType.promptQuery, loader: loader);

  factory PromptQueryStep.fromJson(
    Map<String, dynamic> json,
    String query,
  ) {
    return PromptQueryStep(
      outputId: json['output'],
      query: query,
      responseParser: PromptResponseParser.fromJson(json['post_process']),
    );
  }

  @override
  Future<DefaultOutput> run(
      TaskAssist taskAssist, GenerationRepository generationRepository,
      [DashRepository? dashRepository]) async {
    await super.run(taskAssist, generationRepository);
    final response = await generationRepository.getCompletion(query);
    final parsedResponse = responseParser.parse(response);
    return DefaultOutput(parsedResponse);
  }
}
