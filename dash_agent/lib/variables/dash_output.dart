import 'package:dash_agent/variables/variable.dart';

abstract class DashOutput extends Variable {
  DashOutput();

  Future<Map<String, dynamic>> process();
}

class MatchDocumentOuput extends DashOutput {
  MatchDocumentOuput();

  @override
  Future<Map<String, dynamic>> process() async {
    return {
      'id': hashCode.toString(),
      'type': 'match_document_output',
      'version': version
    };
  }
}

class MultiCodeObject extends DashOutput {
  MultiCodeObject();

  @override
  Future<Map<String, dynamic>> process() async {
    return {
      'id': hashCode.toString(),
      'type': 'multi_code_output',
      'version': version
    };
  }
}

class PromptOutput extends DashOutput {
  PromptOutput();

  @override
  Future<Map<String, dynamic>> process() async {
    return {
      'id': hashCode.toString(),
      'type': 'prompt_output',
      'version': version,
    };
  }
}

class CodeOutput extends DashOutput {
  CodeOutput();

  @override
  Future<Map<String, dynamic>> process() async {
    return {
      'id': hashCode.toString(),
      'type': 'code_output',
      'version': version
    };
  }
}

class BooleanOutput extends DashOutput {
  BooleanOutput();

  @override
  Future<Map<String, dynamic>> process() async {
    return {
      'id': hashCode.toString(),
      'type': 'boolean_output',
      'version': version
    };
  }
}
