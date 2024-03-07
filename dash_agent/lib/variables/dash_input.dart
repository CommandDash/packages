import 'package:dash_agent/variables/variable.dart';

abstract class DashInput extends Variable {
  DashInput(this.displayText);

  final String displayText;

  Future<Map<String, dynamic>> process();
}

class StringInput extends DashInput {
  StringInput(super.displayText);

  @override
  Future<Map<String, dynamic>> process() async {
    return {
      'id': hashCode.toString(),
      'display_text': displayText,
      'type': 'string_input',
    };
  }
}

class CodeInput extends DashInput {
  CodeInput(super.displayText);

  @override
  Future<Map<String, dynamic>> process() async {
    return {
      'id': hashCode.toString(),
      'display_text': displayText,
      'type': 'code_input'
    };
  }
}
