import 'dart:convert';

import 'package:commanddash/agent/loader_model.dart';
import 'package:commanddash/agent/output_model.dart';
import 'package:commanddash/agent/step_model.dart';
import 'package:commanddash/repositories/dash_repository.dart';
import 'package:commanddash/repositories/generation_repository.dart';
import 'package:commanddash/server/task_assist.dart';
import 'package:commanddash/steps/find_closest_files/embedding_generator.dart';
import 'package:commanddash/steps/steps_utils.dart';

class SearchInWorkspaceStep extends Step {
  final String workspaceObjectType;
  final String
      query; // QueryInput -> Find similar to [code] -> references from it -> embedding

  SearchInWorkspaceStep(
      {required List<String> outputIds,
      required this.workspaceObjectType,
      required this.query,
      Loader loader = const MessageLoader('Finding relevant files')})
      : super(
            outputIds: outputIds,
            type: StepType.searchInWorkspace,
            loader: loader);

  factory SearchInWorkspaceStep.fromJson(
    Map<String, dynamic> json,
    String query,
  ) {
    return SearchInWorkspaceStep(
      outputIds:
          (json['outputs'] as List<dynamic>).map((e) => e.toString()).toList(),
      workspaceObjectType: json['workspace_object_type'],
      query: query,
    );
  }

  @override
  Future<List<MultiCodeOutput>?> run(
      TaskAssist taskAssist, GenerationRepository generationRepository,
      [DashRepository? dashRepository]) async {
    await super.run(taskAssist, generationRepository);
    final workspacePath = (await taskAssist.processStep(
        kind: 'workspace_details',
        args: {},
        timeoutKind: TimeoutKind.sync))['path'];
    if (workspacePath == null || workspacePath == '') {
      taskAssist.sendErrorMessage(message: "No open workspace found", data: {});
      throw Exception("No open workspace found");
    }
    final dartFiles = EmbeddingGenerator.getProjectFiles(workspacePath);
    final codeCacheHash = jsonDecode((await taskAssist.processStep(
        kind: 'cache', args: {}, timeoutKind: TimeoutKind.sync))['value']);
    final filesToUpdate =
        EmbeddingGenerator.getFilesToUpdate(dartFiles, codeCacheHash);

    final embeddedFiles = await EmbeddingGenerator.updateEmbeddings(
        filesToUpdate, generationRepository);

    final queryEmbeddings =
        await EmbeddingGenerator.getQueryEmbedding(query, generationRepository);

    taskAssist.processStep(
        kind: "update_cache",
        args: {
          "embeddings":
              json.encode(embeddedFiles.map((e) => e.getCacheMap()).toList()),
        },
        timeoutKind: TimeoutKind
            .async); // Theres logic on the Ide which may take more than 6 seconds for huge workspaces.

    // This logic is include the newly generated embeddings in the embedding matching
    for (var file in dartFiles) {
      var newEmbeddings =
          embeddedFiles.where((element) => element.path == file.path);
      if (newEmbeddings.isNotEmpty) {
        file.embedding = newEmbeddings.first.embedding;
      } else {
        file.embedding =
            ((codeCacheHash[file.path]['embedding']['values']) as List)
                .map<double>((dynamic value) => double.parse(value))
                .toList();
      }
    }

    final top3Files = EmbeddingGenerator.getTop3NearestFiles(
        dartFiles, queryEmbeddings, generationRepository);

    return [MultiCodeOutput(top3Files)];
  }
}
