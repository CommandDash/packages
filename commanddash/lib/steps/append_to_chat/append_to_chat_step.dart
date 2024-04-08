import 'package:commanddash/agent/loader_model.dart';
import 'package:commanddash/agent/output_model.dart';
import 'package:commanddash/agent/step_model.dart';
import 'package:commanddash/repositories/dash_repository.dart';
import 'package:commanddash/repositories/generation_repository.dart';
import 'package:commanddash/server/task_assist.dart';
import 'package:commanddash/steps/steps_utils.dart';

class AppendToChatStep extends Step {
  final String message;

  AppendToChatStep({
    List<String>? outputIds,
    required this.message,
    Loader loader = const NoneLoader(),
  }) : super(outputIds: outputIds, type: StepType.appendToChat, loader: loader);

  factory AppendToChatStep.fromJson(
    Map<String, dynamic> json,
    String message,
  ) {
    return AppendToChatStep(
      outputIds: null,
      message: message,
    );
  }

  @override
  Future<List<Output>?> run(
      TaskAssist taskAssist, GenerationRepository generationRepository,
      [DashRepository? dashRepository]) async {
    await super.run(taskAssist, generationRepository);
    final response = await taskAssist
        .processStep(kind: 'append_to_chat', args: {'message': message});
    if (response['error'] != null) {
      throw Exception(response['error']['message']);
    }
    return null;
  }
}
