import 'package:commanddash/agent/input_model.dart';
import 'package:commanddash/agent/loader_model.dart';
import 'package:commanddash/agent/output_model.dart';
import 'package:commanddash/models/workspace_file.dart';
import 'package:commanddash/repositories/dash_repository.dart';
import 'package:commanddash/repositories/generation_repository.dart';
import 'package:commanddash/server/task_assist.dart';

import 'package:commanddash/steps/steps_utils.dart';

import '../../agent/step_model.dart';

class ReplaceInFileStep extends Step {
  CodeInput file;
  String newContent;
  bool? continueIfDeclined;

  ReplaceInFileStep({
    String? outputId,
    required this.file,
    required this.newContent,
    this.continueIfDeclined = true,
    Loader loader = const NoneLoader(),
  }) : super(outputId: outputId, type: StepType.replaceInFile, loader: loader);

  @override
  String get name => 'replace_in_file';

  @override
  String get description => 'Replace a string in a file';

  @override
  Future<Output?> run(
      TaskAssist taskAssist, GenerationRepository generationRepository,
      [DashRepository? dashRepository]) async {
    await super.run(taskAssist, generationRepository);
    final response =
        await taskAssist.processStep(kind: 'replace_in_file', args: {
      'file': file.getReplaceFileJson(newContent),
    });
    final userChoice = response['value'] as bool;
    if (userChoice == false && continueIfDeclined == false) {
      return ContinueToNextStepOutput(false);
    }
    return ContinueToNextStepOutput(userChoice);
  }

  factory ReplaceInFileStep.fromJson(
    Map<String, dynamic> json,
    CodeInput file,
    String newContent,
  ) {
    return ReplaceInFileStep(
      outputId: json['output'],
      file: file,
      newContent: newContent,
      continueIfDeclined: json['continue_if_declined'],
    );
  }
}
