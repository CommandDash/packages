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
      return BaseCodeInput.fromJson(json);
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

class BaseCodeInput extends Input {
  BaseCodeInput(String id) : super(id, 'code_input');

  factory BaseCodeInput.fromJson(Map<String, dynamic> json) {
    if (json['value'] == null) {
      return EmptyCodeInput(
        id: json['id'],
      );
    }
    final value = jsonDecode(json['value']);
    return CodeInput(
      id: json['id'],
      filePath: value['filePath'],
      range: Range.fromJson(value['referenceData']['selection']),
      content: value['referenceContent'],
      fileContent: File(value['filePath']).readAsStringSync(),
      generateFullString: json['generate_full_string'] ?? false,
    );
  }
}

class EmptyCodeInput extends BaseCodeInput {
  EmptyCodeInput({required String id}) : super(id);
  @override
  String toString() {
    return "N/A";
  }
}

class CodeInput extends BaseCodeInput {
  String filePath;
  Range range;
  String content;
  String fileContent;
  final bool includeContextualCode;
  final bool generateFullString;

  CodeInput(
      {required String id,
      required this.filePath,
      required this.range,
      required this.content,
      required this.fileContent,
      this.includeContextualCode = true,
      this.generateFullString = false})
      : super(id);

  @override
  String toString() {
    return 'filepath:$filePath\n\n$content';
  }

  int getOffset(int line, int character) {
    return fileContent.split('\n').take(line).join('\n').length + character;
  }

  String getFileCodeWithReplacedCode(String newContent) {
    final startOffet = getOffset(range.start.line, range.start.character);
    final endOffset = getOffset(range.end.line, range.end.character);
    return '${fileContent.substring(0, startOffet)}$newContent${fileContent.substring(endOffset)}';
  }

  Map<String, dynamic> getReplaceFileJson(String newContent) {
    if (generateFullString) {
      newContent = getFileCodeWithReplacedCode(newContent);
    }
    return {
      "path": filePath,
      "optimizedCode": newContent,
      "originalCode": fileContent,
      "selection": range.toJson(),
    };
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
