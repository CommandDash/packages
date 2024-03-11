import 'dart:io';
import 'package:commanddash/models/workspace_file.dart';
import 'package:commanddash/repositories/generation_repository.dart';
import 'package:commanddash/utils/embedding_utils.dart';

class EmbeddingGenerator {
  static List<WorkspaceFile> getDartFiles(String workspacePath) {
    final directory = Directory(workspacePath);
    const excludePattern =
        r"[/\\](android|ios|web|linux|macos|windows|.dart_tool)[\/\\]";
    final dartFiles = directory
        .listSync(recursive: true)
        .where((file) => file.path.endsWith('.dart'))
        .where((file) {
      return !RegExp(excludePattern).hasMatch(file.path);
    }).toList();
    final fileContents =
        dartFiles.map((file) => WorkspaceFile.fromPaths(file.path)).toList();
    return fileContents;
  }

  static List<WorkspaceFile> getFilesToUpdate(
      List<WorkspaceFile> files, Map<String, dynamic> codehashCache) {
    final filesToUpdate = files.where((element) {
      final cacheEntry = codehashCache[element.path];
      if (cacheEntry == null) {
        return true; // File not in cache, update required
      }
      return cacheEntry['codehash'] != element.codeHash;
    }).toList();
    return filesToUpdate;
  }

  static Future<List<WorkspaceFile>> updateEmbeddings(List<WorkspaceFile> files,
      GenerationRepository generationRepository) async {
    for (var file in files) {
      final embedding =
          await generationRepository.getCodeEmbeddings(file.content!);
      file.embedding = embedding;
    }
    return files;
  }

  static Future<List<double>> getQueryEmbedding(
      String query, GenerationRepository generationRepository) async {
    return await generationRepository.getStringEmbeddings(query);
  }

  static List<WorkspaceFile> getTop3NearestFiles(List<WorkspaceFile> files,
      List<double> queryEmbeddings, GenerationRepository generationRepository) {
    files.sort(((a, b) {
      final distanceA =
          calculateCosineSimilarity(queryEmbeddings, a.embedding!);
      final distanceB =
          calculateCosineSimilarity(queryEmbeddings, b.embedding!);
      return distanceA.compareTo(distanceB);
    }));
    return files;
  }
}
