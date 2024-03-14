import 'package:commanddash/agent/input_model.dart';
import 'package:commanddash/agent/output_model.dart';

enum StepType { searchInWorkspace }

enum OutputType { defaultOutput, multiCodeOutput }

extension ProcessedQueryExtension on String {
  String replacePlaceholder(
      Map<String, Input> inputs, Map<String, Output> outputs) {
    final RegExp queryIdPattern = RegExp(r'<(\d+)>');
    final stringValue = this;
    for (RegExpMatch match in queryIdPattern.allMatches(stringValue)) {
      final inputId =
          match.toString().substring(1, match.toString().length - 1);
      var replaceValue;
      if (inputs[inputId] != null) {
        replaceValue = inputs[inputId];
      } else if (outputs[inputId] != null) {
        replaceValue = outputs[inputId];
      }
      if (replaceValue != null) {
        stringValue.replaceRange(
            match.start, match.end, replaceValue.toString());
      }
    }
    return stringValue;
  }
}
