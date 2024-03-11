import 'package:commanddash/agent/input_model.dart';
import 'package:commanddash/agent/output_model.dart';
import 'package:commanddash/agent/step_model.dart';
import 'package:commanddash/repositories/generation_repository.dart';
import 'package:commanddash/server/task_assist.dart';
import 'package:commanddash/steps/find_closest_files/embedding_generator.dart';

class SearchInWorkspaceStep extends Step {
  final String workspacePath;
  final String workspaceObjectType;
  final String queryId;

  SearchInWorkspaceStep({
    required this.workspaceObjectType,
    required this.workspacePath,
    required this.queryId,
    required inputs,
    required outputs,
  }) : super(
          type: 'search_in_workspace',
          inputs: inputs,
          outputs: outputs,
        );

  factory SearchInWorkspaceStep.fromJson(Map<String, dynamic> json,
      Map<String, Input> inputs, Map<String, Output> outputs) {
    return SearchInWorkspaceStep(
        workspaceObjectType: json['workspace_object_type'],
        workspacePath: json['workspacePath'],
        inputs: inputs,
        outputs: outputs,
        queryId: json['query']);
  }

  @override
  Future<void> run(
      TaskAssist taskAssist, GenerationRepository generationRepository) async {
    final dartFiles = EmbeddingGenerator.getDartFiles(workspacePath);
    final codeCacheHash = await taskAssist.processStep(kind: 'cache', args: {});
    final filesToUpdate =
        EmbeddingGenerator.getFilesToUpdate(dartFiles, codeCacheHash);
    final embeddedFiles = await EmbeddingGenerator.updateEmbeddings(
        filesToUpdate, generationRepository);
    final query = inputs[queryId] as StringInput;
    final queryEmbeddings = await EmbeddingGenerator.getQueryEmbedding(
        query.value, generationRepository);
    final top3Files = EmbeddingGenerator.getTop3NearestFiles(
        embeddedFiles, queryEmbeddings, generationRepository);
    // taskAssist.sendLogMessage(message: "completed", data: {});
    taskAssist.sendResultMessage(
        message: 'NEAREST_FILES_SUCCESS',
        data: <String, List<String>>{
          "result": top3Files.map((e) => e.path).toList()
        });
  }
}
