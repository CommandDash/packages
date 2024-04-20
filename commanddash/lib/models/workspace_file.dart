import 'dart:convert';
import 'dart:io';

import 'package:commanddash/utils/embedding_utils.dart';

class WorkspaceFile {
  final String path;
  String? content;
  String? codeHash;
  List<double>? embedding;
  Range? range;

  WorkspaceFile.fromPaths(this.path) {
    content = File(path).readAsStringSync();
    if (File(path).existsSync() && content != null) {
      codeHash = computeCodeHash(content!);
    }
  }

  WorkspaceFile(this.path, {this.content, this.codeHash, this.embedding});

  Map<String, dynamic> toJson() {
    return {
      "path": path,
      "content": content,
      "codeHash": codeHash,
      "embedding": embedding,
      "range": range?.toJson(),
    };
  }

  Map<String, Map<String, dynamic>> getCacheMap() {
    return {
      path: {
        "codeHash": codeHash,
        "embedding": {
          "values": embedding?.map((e) => e.toString()).toList(),
        },
      }
    };
  }

  Map<String, dynamic> getReplaceFileJson(
      String newContent, String oldContent) {
    return {
      "path": path,
      "optimizedCode": newContent,
      "originalCode": oldContent,
      "range": range?.toJson(),
    };
  }
}

// Range similar to vscode.Range
class Position {
  final int line;
  final int character;

  Position({required this.line, required this.character});

  // Convert Position to JSON map
  Map<String, dynamic> toJson() {
    return {
      'line': line,
      'character': character,
    };
  }
}

class Range {
  final Position start;
  final Position end;

  Range({required this.start, required this.end});

  factory Range.fromJson(Map<String, dynamic> json) {
    return Range(
      start: Position(
        line: json['start']['line'],
        character: json['start']['character'],
      ),
      end: Position(
        line: json['end']['line'],
        character: json['end']['character'],
      ),
    );
  }

  // Convert Range to JSON map
  Map<String, dynamic> toJson() {
    return {
      'start': start.toJson(),
      'end': end.toJson(),
    };
  }
}
