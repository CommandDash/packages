import 'dart:io';

import 'package:commanddash/models/workspace_file.dart';
import 'package:commanddash/steps/steps_utils.dart';

abstract class Output {
  OutputType type;
  Output(this.type);

  factory Output.fromJson(Map<String, dynamic> json) {
    final type = json['type'];
    if (type == 'default_output') {
      return DefaultOutput.fromJson(json);
    } else {
      throw UnimplementedError();
    }
  }

  @override
  String toString() {
    throw UnimplementedError();
  }

  Map<String, dynamic> toJson() {
    return {
      "type": type.toString(),
    };
  }
}

class MultiCodeOutput extends Output {
  List<WorkspaceFile>? value;
  MultiCodeOutput([this.value]) : super(OutputType.multiCodeOutput);

  factory MultiCodeOutput.fromJson(Map<String, dynamic> json) {
    return MultiCodeOutput(
      json['id'],
    );
  }

  @override
  String toString() {
    String code = "";
    if (value == null) {
      return code;
    } else {
      for (WorkspaceFile file in value!) {
        code += 'File: ${file.path}\n';
        if (file.content == null) {
          code += File(file.path).readAsStringSync();
        }
        code += file.content!;
      }
    }
    return code;
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      "type": type.toString(),
      "value": value?.map((e) => e.toJson()).toList(),
    };
  }
}

class DefaultOutput extends Output {
  String value;
  DefaultOutput(this.value) : super(OutputType.defaultOutput);

  factory DefaultOutput.fromJson(Map<String, dynamic> json) {
    return DefaultOutput(
      json['type'],
    );
  }

  @override
  String toString() {
    return value;
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      "type": type.toString(),
      "value": value,
    };
  }
}
