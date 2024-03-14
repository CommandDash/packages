import 'dart:io';

import 'package:commanddash/models/workspace_file.dart';
import 'package:commanddash/steps/steps_utils.dart';

abstract class Output {
  OutputType type;
  Output(this.type);

  factory Output.fromJson(Map<String, dynamic> json) {
    final type = json['type'];
    if (type == 'default_output') {
      return DefaultOutput(json['value']);
    } else {
      throw UnimplementedError();
    }
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

  // Map<String, dynamic> toJson() {
  //   // return
  // }
}

class DefaultOutput extends Output {
  String value;
  DefaultOutput(this.value) : super(OutputType.defaultOutput);

  factory DefaultOutput.fromJson(Map<String, dynamic> json) {
    return DefaultOutput(
      json['type'],
    );
  }
}
