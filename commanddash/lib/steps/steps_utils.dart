import 'package:commanddash/agent/input_model.dart';
import 'package:commanddash/agent/output_model.dart';
import 'package:commanddash/server/server.dart';

enum StepType {
  searchInWorkspace,
  promptQuery,
  appendToChat,
  replaceInFile,
  contextualCode,
  chat,
  searchInSources,
}

enum OutputType {
  defaultOutput,
  multiCodeOutput,
  userChoiceOutput,
  dataSourceOuput,
  codeOutput,
  promptOutput,
}

extension ProcessedQueryExtension on String {
  List<String> getInputIds() {
    final RegExp queryIdPattern = RegExp(r'<(\d+)>');
    String stringValue = this;
    final allMatches = queryIdPattern.allMatches(stringValue).toList();
    final ids = allMatches.map((e) {
      return e.group(1)!;
    }).toList();
    return ids;
  }

  String replacePlaceholder(
      Map<String, Input> inputs, Map<String, Output> outputs,
      {Function(int tokens)? totalTokensAddedCallback}) {
    final RegExp queryIdPattern = RegExp(r'<(\d+)>');
    String stringValue = this;
    int totalTokens = 0;
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

        totalTokens += replaceValue.length;
      }
    }
    if (totalTokensAddedCallback != null) {
      totalTokensAddedCallback(totalTokens);
    }
    return stringValue;
  }
}
