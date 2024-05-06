import 'package:dash_agent/variables/variable.dart';

/// Base class to accept inputs from the user.
abstract class DashInput extends Variable {
  DashInput(this.displayText, {this.optional = false});

  /// Hint Text
  final String displayText;

  /// Marks the input as optional.
  final bool optional;

  Future<Map<String, dynamic>> process();
}

/// Appears inline in the text field as a string input.
///
/// Provide a hint to the user on what input to add with [displayText].
///
/// For [optional] inputs, "NA" will be appended in steps if no value is provided by user.
///
/// Examples:
/// ```
/// final userQuery = StringInput('Your query');
/// final additionalInstructions = StringInput('Additional Instructions', optional: true);
///
/// @override
/// List<DashInput> get registerInputs => [userQuery, additionalInstructions];
/// ```
class StringInput extends DashInput {
  StringInput(super.displayText, {super.optional});

  @override
  Future<Map<String, dynamic>> process() async {
    return {
      'id': hashCode.toString(),
      'display_text': displayText,
      'type': 'string_input',
      'optional': optional,
      'version': version
    };
  }
}

/// Appears inline in the text field as a code input.
///
/// User can attach code snippets of any programming language from within their workspace.
///
/// Provide a hint to the user on the kind of the code snippet to attach with [displayText].
///
/// For [optional] inputs, "NA" will be appended in steps if no code snippet is added by the user.
///
/// Examples:
/// ```
/// final testMethod = CodeInput('Test Method');
/// final reference1 = CodeInput('Existing Reference', optional: true);
/// final reference2 = CodeInput('Existing Reference', optional: true);
/// final reference3 = CodeInput('Existing Reference', optional: true);
///
/// @override
/// List<DashInput> get registerInputs => [testMethod, reference1, reference2, reference3 ];
/// ```
class CodeInput extends DashInput {
  CodeInput(super.displayText,
      {super.optional, this.includeContextualCode = true});

  /// [includeContextualCode] extracts the nested code objects and matching code files from the codebase.
  final bool includeContextualCode;

  @override
  Future<Map<String, dynamic>> process() async {
    return {
      'id': hashCode.toString(),
      'display_text': displayText,
      'type': 'code_input',
      'optional': optional,
      'include_contextual_code': includeContextualCode,
      'version': version,
    };
  }
}
