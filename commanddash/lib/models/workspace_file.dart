import 'dart:io';

import 'package:commanddash/utils/embedding_utils.dart';

class WorkspaceFile {
  WorkspaceFile(this.path,
      {required this.contentLines,
      required this.codeHash,
      required this.selectedRanges,
      this.embedding});
  final String path;
  final List<String> contentLines;
  final String codeHash;
  final List<Range> selectedRanges;
  List<double>? embedding;

  factory WorkspaceFile.fromPath(String path, {List<Range>? selectedRanges}) {
    if (!File(path).existsSync()) {
      throw Exception('No file found in workspace for path: $path');
    }
    final contentLines = File(path).readAsLinesSync();
    final codeHash = computeCodeHash(contentLines.join('\n'));
    selectedRanges = selectedRanges ??
        [
          Range(
              start: Position(line: 0, character: 0),
              end: Position(
                  line: contentLines.length - 1,
                  character: contentLines.last.length - 1))
        ];
    return WorkspaceFile(path,
        contentLines: contentLines,
        codeHash: codeHash,
        selectedRanges: selectedRanges);
  }

  String get fileContent => contentLines.join('\n');

  List<Range> get mergeOverlappingRanges {
    if (selectedRanges.isEmpty) return [];

    // Sort ranges based on start position
    selectedRanges.sort((a, b) => a.start.compareTo(b.start));

    List<Range> mergedRanges = [];
    Range currentRange = selectedRanges[0];

    for (int i = 1; i < selectedRanges.length; i++) {
      Range nextRange = selectedRanges[i];

      if (currentRange.end.compareTo(nextRange.start) >= 0) {
        // Overlapping ranges, merge them
        currentRange = Range(
          start: currentRange.start,
          end: nextRange.end.compareTo(currentRange.end) > 0
              ? nextRange.end
              : currentRange.end,
        );
      } else {
        // Non-overlapping range, add the current range to the result
        mergedRanges.add(currentRange);
        currentRange = nextRange;
      }
    }

    // Add the last range
    mergedRanges.add(currentRange);

    return mergedRanges;
  }

  String get selectedContent {
    String selectedContent = '';

    for (Range range in mergeOverlappingRanges) {
      int startLine = range.start.line;
      int startChar = range.start.character;
      int endLine = range.end.line;
      int endChar = range.end.character;

      for (int i = startLine; i <= endLine; i++) {
        if (i == startLine && i == endLine) {
          // Single line selection
          selectedContent += contentLines[i].substring(startChar, endChar);
        } else if (i == startLine) {
          // First line of multi-line selection
          selectedContent += contentLines[i].substring(startChar);
          selectedContent += '\n';
        } else if (i == endLine) {
          // Last line of multi-line selection
          selectedContent += contentLines[i].substring(0, endChar);
        } else {
          // Middle lines of multi-line selection
          selectedContent += contentLines[i];
          selectedContent += '\n';
        }
      }
    }

    return selectedContent;
  }

  String? get surroundingContent {
    final int totalLines = contentLines.length;
    final int selectedLinesCount = mergeOverlappingRanges.fold(
        0, (prev, range) => prev + (range.end.line - range.start.line + 1));

    if (selectedLinesCount / totalLines >= 0.8) {
      return null; // Selected content covers 80% or more of the lines
    }

    List<String> surroundingLines = [];
    int previousEndLine = -1;

    for (Range range in mergeOverlappingRanges) {
      int startLine = range.start.line;
      int endLine = range.end.line;

      // Add lines before the start of the selection
      for (int i = previousEndLine + 1; i < startLine; i++) {
        surroundingLines.add(contentLines[i]);
      }

      // Replace selected content with placeholder if it spans more than 3 lines
      if (endLine - startLine > 2) {
        surroundingLines.add('...(already attached by user)...');
      } else {
        for (int i = startLine; i <= endLine; i++) {
          surroundingLines.add(contentLines[i]);
        }
      }

      previousEndLine = endLine;
    }

    // Add remaining lines after the last selection
    for (int i = previousEndLine + 1; i < totalLines; i++) {
      surroundingLines.add(contentLines[i]);
    }

    return surroundingLines.join('\n');
  }

  Map<String, dynamic> toJson() {
    return {
      "path": path,
      "content": fileContent,
      "codeHash": codeHash,
      "embedding": embedding,
      "range": selectedRanges.map((e) => e.toJson()),
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
}

// Range similar to vscode.Range
class Position {
  final int line;
  final int character;

  Position({required this.line, required this.character});

  int compareTo(Position other) {
    if (line == other.line) {
      return character.compareTo(other.character);
    } else {
      return line.compareTo(other.line);
    }
  }

  // Convert Position to JSON map
  Map<String, dynamic> toJson() {
    return {
      'line': line,
      'character': character,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Position &&
          runtimeType == other.runtimeType &&
          line == other.line &&
          character == other.character;

  @override
  int get hashCode => line.hashCode ^ character.hashCode;
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

  bool includes(Range range) {
    return range.start.line >= start.line &&
        range.start.character >= start.character &&
        range.end.line <= end.line &&
        range.end.character <= end.character;
  }

  // Convert Range to JSON map
  Map<String, dynamic> toJson() {
    return {
      'start': start.toJson(),
      'end': end.toJson(),
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Range &&
          runtimeType == other.runtimeType &&
          start == other.start &&
          end == other.end;

  @override
  int get hashCode => start.hashCode ^ end.hashCode;
}
