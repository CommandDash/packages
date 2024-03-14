import 'package:commanddash/agent/agent_exceptions.dart';
import 'package:commanddash/agent/input_model.dart';
import 'package:commanddash/agent/output_model.dart';
import 'package:commanddash/agent/step_model.dart';
import 'package:commanddash/repositories/generation_repository.dart';
import 'package:commanddash/server/task_assist.dart';
import 'package:commanddash/steps/find_closest_files/embedding_generator.dart';
import 'package:commanddash/steps/steps_utils.dart';

class SearchInWorkspaceStep extends Step {
  final String workspacePath;
  final String workspaceObjectType;
  final String
      query; // QueryInput -> Find similar to [code] -> references from it -> embedding

  SearchInWorkspaceStep({
    required String outputId,
    required this.workspaceObjectType,
    required this.workspacePath,
    required this.query,
  }) : super(
          outputId: outputId,
          type: StepType.searchInWorkspace,
        );

  factory SearchInWorkspaceStep.fromJson(
    Map<String, dynamic> json,
    String query,
  ) {
    return SearchInWorkspaceStep(
      outputId: json['output'],
      workspaceObjectType: json['workspace_object_type'],
      workspacePath: json['workspacePath'],
      query: query,
    );
  }

  @override
  Future<MultiCodeOutput?> run(
      TaskAssist taskAssist, GenerationRepository generationRepository) async {
    final dartFiles = EmbeddingGenerator.getDartFiles(workspacePath);
    final codeCacheHash = await taskAssist.processStep(kind: 'cache', args: {});
    final filesToUpdate =
        EmbeddingGenerator.getFilesToUpdate(dartFiles, codeCacheHash);
    final embeddedFiles = await EmbeddingGenerator.updateEmbeddings(
        filesToUpdate, generationRepository);
    final queryEmbeddings =
        await EmbeddingGenerator.getQueryEmbedding(query, generationRepository);
    final top3Files = EmbeddingGenerator.getTop3NearestFiles(
        embeddedFiles, queryEmbeddings, generationRepository);
    // taskAssist.sendLogMessage(message: "completed", data: {});
    // taskAssist.sendResultMessage(
    //     message: 'NEAREST_FILES_SUCCESS',
    //     data: <String, List<String>>{
    //       "result": top3Files.map((e) => e.path).toList()
    //     });

    return MultiCodeOutput(top3Files);
  }
}
