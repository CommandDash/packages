import 'dart:io';
import 'package:commanddash/models/workspace_file.dart';
import 'package:commanddash/repositories/generation_repository.dart';
import 'package:commanddash/utils/embedding_utils.dart';

class EmbeddingGenerator {
  static List<WorkspaceFile> getProjectFiles(String workspacePath) {
    final directory = Directory(workspacePath);
    final gitIgnore = File('${workspacePath}/.gitignore');
    String excludePattern = '';
    if (gitIgnore.existsSync()) {
      final ignorePatterns = gitIgnore.readAsLinesSync();
      excludePattern = ignorePatterns
          .map((pattern) =>
              pattern.replaceAll('/', r"[/\\]").replaceAll('*', '.*'))
          .join('|');
    }
    final dartFiles = directory.listSync(recursive: true).where((file) {
      return !RegExp(excludePattern).hasMatch(file.path);
    }).toList();
    final fileContents = dartFiles.map((file) {
      return WorkspaceFile.fromPath(file.path);
    }).toList();
    fileContents.removeWhere((element) => (element.fileContent).isEmpty);
    return fileContents;
  }

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
    final fileContents = dartFiles.map((file) {
      return WorkspaceFile.fromPath(file.path);
    }).toList();
    fileContents.removeWhere((element) => (element.fileContent).isEmpty);
    return fileContents;
  }

  static List<WorkspaceFile> getFilesToUpdate(
      List<WorkspaceFile> files, Map<String, dynamic> codehashCache) {
    final filesToUpdate = files.where((element) {
      final cacheEntry = codehashCache[element.path];
      if (cacheEntry == null) {
        return true; // File not in cache, update required
      }
      return cacheEntry['codeHash'] != element.codeHash;
    }).toList();
    return filesToUpdate;
  }

  static Future<List<WorkspaceFile>> updateEmbeddings(List<WorkspaceFile> files,
      GenerationRepository generationRepository) async {
    // Batch the files in batches of 100s
    const batchSize = 100;
    final batches = <List<WorkspaceFile>>[];
    for (var i = 0; i < files.length; i += batchSize) {
      batches.add(files.sublist(
          i, i + batchSize < files.length ? i + batchSize : files.length));
    }

    // Use the batches API to update the embeddings
    final embeddings = await Future.wait(batches.map((batch) async {
      final code = batch
          .map((file) => {'content': file.fileContent, 'title': file.path})
          .toList();
      final embeddings =
          await generationRepository.getCodeBatchEmbeddings(code);
      return embeddings;
    }));

    for (var i = 0; i < files.length; i++) {
      files[i].embedding = embeddings[i ~/ batchSize][i % batchSize];
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
      return distanceB.compareTo(distanceA);
    }));
    if (files.length > 3) {
      return files.sublist(0, 3);
    } else {
      return files;
    }
  }
}
