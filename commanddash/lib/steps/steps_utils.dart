import 'package:commanddash/agent/input_model.dart';
import 'package:commanddash/agent/output_model.dart';

enum StepType {
  searchInWorkspace,
  promptQuery,
  appendToChat,
  replaceInFile,
  contextualCode,
}

enum OutputType { defaultOutput, multiCodeOutput }

extension ProcessedQueryExtension on String {
  String replacePlaceholder(
      Map<String, Input> inputs, Map<String, Output> outputs) {
    final RegExp queryIdPattern = RegExp(r'<(\d+)>');
    String stringValue = this;
    final allMatches = queryIdPattern.allMatches(stringValue).toList();
    for (int i = allMatches.length - 1; i >= 0; i--) {
      final match = allMatches[i];
      final inputId = match.group(1);
      String? replaceValue;
      if (inputs[inputId] != null) {
        replaceValue = inputs[inputId].toString();
      } else if (outputs[inputId] != null) {
        replaceValue = outputs[inputId].toString();
      }
      if (replaceValue != null) {
        stringValue =
            stringValue.replaceRange(match.start, match.end, replaceValue);
      }
    }
    return stringValue;
  }
}
