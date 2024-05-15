import 'package:commanddash/models/data_source.dart';
import 'package:commanddash/models/workspace_file.dart';
import 'package:commanddash/steps/steps_utils.dart';

abstract class Output {
  OutputType type;
  Output(this.type, [this.maxCharsInPrompt]);
  double? maxCharsInPrompt;

  factory Output.fromJson(Map<String, dynamic> json) {
    final type = json['type'];
    if (type == 'default_output') {
      return DefaultOutput();
    } else if (type == 'prompt_output') {
      // TODO: handle code ouput and raw output
      return DefaultOutput();
    } else if (type == "multi_code_output") {
      return MultiCodeOutput();
    } else if (type == "match_document_output") {
      return DataSourceResultOutput();
    } else if (type == "code_object") {
      return CodeOutput();
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
  MultiCodeOutput([this.value])
      : super(OutputType.multiCodeOutput, 10000 * 2.7);

  @override
  String toString() {
    String code = "";
    if (value == null) {
      return code;
    } else {
      for (WorkspaceFile file in value!) {
        String newContent = 'File: ${file.path}\n${file.fileContent}';
        if ((newContent.length + code.length) <= maxCharsInPrompt!) {
          code += newContent;
        }
      }
    }
    return code;
  }

  @override
  Map<String, dynamic> toJson() {
    if (value == null) {
      throw Exception("Value not assigned to output");
    } else {
      return {
        "type": type.toString(),
        "value": value?.map((e) => e.toJson()).toList(),
      };
    }
  }
}

class DefaultOutput extends Output {
  String? value;
  DefaultOutput([this.value])
      : super(
          OutputType.defaultOutput,
        );

  @override
  String toString() {
    if (value == null) {
      throw Exception("Value not assigned to output");
    } else {
      return value!;
    }
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      "type": type.toString(),
      "value": value,
    };
  }
}

class ContinueToNextStepOutput extends Output {
  bool value;

  ContinueToNextStepOutput(this.value) : super(OutputType.userChoiceOutput);
}

class DataSourceResultOutput extends Output {
  List<DataSource>? value;
  // TODO: limit for each output

  DataSourceResultOutput([this.value])
      : super(OutputType.dataSourceOuput, 15000 * 2.7);

  @override
  String toString() {
    if (value == null) {
      throw Exception("DataSource value not assigned");
    }
    // do not add if limit is reched here.
    String result = "";
    for (DataSource ds in value!) {
      if (ds.content != null) {
        final newLength = result.length + ds.content!.length;
        if (newLength > maxCharsInPrompt!) {
          return result;
        }
        result += "${ds.content}\n";
      }
    }
    return result;
  }

  @override
  Map<String, dynamic> toJson() {
    if (value == null) {
      throw Exception("DataSource value not assigned");
    }
    return {
      "type": type.toString(),
      "value": value!.map((e) => e.toJson()).toList(),
    };
  }
}

class CodeOutput extends Output {
  String? code;
  CodeOutput([this.code]) : super(OutputType.codeOutput);

  @override
  String toString() {
    if (code == null) {
      return "NA";
    }
    return code!;
  }
}
