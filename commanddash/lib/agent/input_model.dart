import 'dart:convert';
import 'dart:io';

import 'package:commanddash/models/chat_message.dart';
import 'package:commanddash/models/workspace_file.dart';

abstract class Input {
  String id;
  String type;
  Input(this.id, this.type);

  factory Input.fromJson(Map<String, dynamic> json) {
    final type = json['type'];
    // TODO: parse if jsons
    if (type == "string_input") {
      return StringInput.fromJson(json);
    } else if (type == "code_input") {
      return CodeInput.fromJson(json);
    } else if (type == "chat_query_input") {
      return ChatQueryInput.fromJson(json);
    } else {
      throw UnimplementedError();
    }
  }

  @override
  String toString();
}

class StringInput extends Input {
  String? value;
  StringInput(String id, this.value) : super(id, 'string_input');

  factory StringInput.fromJson(Map<String, dynamic> json) {
    return StringInput(
      json['id'],
      json['value'],
    );
  }

  @override
  String toString() {
    if (value == null) {
      return 'NA';
    }
    return value!;
  }
}

class CodeInput extends Input {
  String? filePath;
  Range? range;
  bool generateFullString;
  String? content;
  String? fileContent;
  final bool includeContextualCode;

  CodeInput(
      {required String id,
      this.filePath,
      this.range,
      this.content,
      this.generateFullString = false,
      this.fileContent,
      this.includeContextualCode = true})
      : super(id, 'code_input');

  factory CodeInput.fromJson(Map<String, dynamic> json) {
    if (json['value'] == null) {
      return CodeInput(
          id: json['id'],
          includeContextualCode: json['includeContextualCode'] ?? true);
    }
    final value = jsonDecode(json['value']);
    return CodeInput(
      id: json['id'],
      filePath: value['filePath'],
      range: Range.fromJson(value['referenceData']['selection']),
      content: value['referenceContent'],
      generateFullString: json['generate_full_string'] ?? false,
      fileContent: File(value['filePath']).readAsStringSync(),
    );
  }

  // Generates the full string which includes the cursor selection.
  // Has all the content of the file with the selected range highlighted with <CURSOR_SELECTION> tag.
  String getCodeWithCursorSelection() {
    if (range == null) {
      return 'NA';
    }
    final startOffet = getOffset(range!.start.line, range!.start.character);
    final endOffset = getOffset(range!.end.line, range!.end.character);
    return '${fileContent!.substring(0, startOffet)}<CURSOR_SELECTION>${fileContent!.substring(startOffet, endOffset)}</CURSOR_SELECTION>${fileContent!.substring(endOffset)}';
  }

  /// Generates the full string with [newContent].
  String getFileCodeWithReplacedCode(String newContent) {
    if (range == null) {
      throw Exception("Code input value is required for replacing in file");
    }
    final startOffet = getOffset(range!.start.line, range!.start.character);
    final endOffset = getOffset(range!.end.line, range!.end.character);
    return '${fileContent!.substring(0, startOffet)}$newContent${fileContent!.substring(endOffset)}';
  }

  @override
  String toString() {
    if (content == null) {
      return 'NA';
    }
    return 'filepath:$filePath\n\n$content';
  }

  Map<String, dynamic> getReplaceFileJson(String newContent) {
    if (range == null) {
      throw Exception("Code input value is required for replacing in file");
    }
    if (generateFullString) {
      newContent = getFileCodeWithReplacedCode(newContent);
    }
    return {
      "path": filePath,
      "optimizedCode": newContent,
      "originalCode": fileContent,
      "selection": range?.toJson(),
    };
  }

  int getOffset(int line, int character) {
    return fileContent!.split('\n').take(line).join('\n').length + character;
  }
}

class ChatQueryInput extends Input {
  List<ChatMessage>? messages;
  ChatQueryInput(String id, this.messages) : super(id, 'chat_query_input');

  factory ChatQueryInput.fromJson(Map<String, dynamic> json) {
    final value = jsonDecode(json['value']);
    return ChatQueryInput(
      json['id'],
      (value as List).map((e) => ChatMessage.fromJson(e)).toList(),
    );
  }

  @override
  String toString() {
    return messages?.map((e) => e.toString()).join('\n') ?? 'NA';
  }
}
