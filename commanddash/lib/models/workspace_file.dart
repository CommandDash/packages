import 'dart:io';

import 'package:commanddash/utils/embedding_utils.dart';

class WorkspaceFile {
  final String path;
  String? content;
  String? codeHash;
  List<double>? embedding;

  WorkspaceFile.fromPaths(this.path) {
    content = File(path).readAsStringSync();
    if (File(path).existsSync() && content != null) {
      codeHash = computeCodeHash(content!);
    }
  }
  Map<String, dynamic> toJson() {
    return {
      "path": path,
      "content": content,
      "codeHash": codeHash,
      "embedding": embedding,
    };
  }
}
