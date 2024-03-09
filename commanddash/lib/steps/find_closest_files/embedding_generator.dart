import 'dart:io';
import 'dart:convert';
import 'package:commanddash/repositories/generation_repository.dart';
import 'package:commanddash/server/task_assist.dart';
import 'package:commanddash/utils/embedding_utils.dart';

class EmbeddingGenerator {
  Future<void> findClosesResults(
    TaskAssist taskAssist,
    String query,
    String workspacePath,
    GenerationRepository generationRepository,
  ) async {
    // Find all Dart files in the workspace
    final directory = Directory(workspacePath);
    const excludePattern =
        r"[/\\](android|ios|web|linux|macos|windows|.dart_tool)[\/\\]";
    final dartFiles = directory
        .listSync(recursive: true)
        .where((file) => file.path.endsWith('.dart'))
        .where((file) {
      return !RegExp(excludePattern).hasMatch(file.path);
    }).toList();
    final fileContents = dartFiles.map((file) {
      // get the code hash
      final codeHash = computeCodeHash(File(file.path).readAsStringSync());
      // get the embedding
      final content = File(file.path).readAsStringSync();
      return <String, dynamic>{
        'path': file.path,
        'codeHash': codeHash,
        'content': content,
      };
    });
    // request for the chache from embedding
    final codehashCache = jsonDecode(
        (await taskAssist.processStep(kind: 'cache', args: {}))['value']);
    taskAssist.sendLogMessage(message: "Cache recieved successfully", data: {});
    final filesToUpdate = fileContents.where((element) {
      final cacheEntry = codehashCache[element['path']];
      if (cacheEntry == null) {
        return true; // File not in cache, update required
      }
      return cacheEntry['codehash'] != element['codehash'];
    });

    // update the embeddings
    for (var element in filesToUpdate) {
      final embedding = await generationRepository
          .getCodeEmbeddings(element['content'] ?? '');
      if (codehashCache[element['path']] != null) {
        codehashCache[element['path']]['embedding'] = embedding;
      } else {
        codehashCache[element['path']!] = element;
        codehashCache[element['path']]['embedding'] = embedding;
      }
    }
    // save to cache by sending message to ide
    // TODO: Send message to ide according to requirements

    final queryEmbedding =
        await generationRepository.getStringEmbeddings(query);

    final distances = fileContents.map((file) {
      final embedding = codehashCache[file['path']]['embedding'];
      final distance = calculateCosineSimilarity(queryEmbedding, embedding);
      return {
        'path': file['path'],
        'distance': distance,
      };
    }).toList()
      ..sort((a, b) =>
          (a['distance'] as double).compareTo(b['distance'] as double))
      ..take(3);

    taskAssist.sendResultMessage(message: "TASK_COMPLETED", data: {
      "result": distances,
    });
  }
}
