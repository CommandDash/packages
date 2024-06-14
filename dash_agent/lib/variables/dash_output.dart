import 'package:dash_agent/variables/variable.dart';

/// Base class for all Dash Outputs.
abstract class DashOutput extends Variable {
  DashOutput();

  Future<Map<String, dynamic>> process();
}

/// Represents a Match Document output.
///
/// This output represents a document that are fetched from CommandDash server
/// based on the matches from a particular search query in the [MatchDocumentStep]
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

/// Represents a Multi Code Object output.
///
/// This output represents a collection of code objects.
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

/// Represents a Prompt output.
///
/// This output represents a output from the [PromptQueryStep]
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

/// Represents a Code output.
///
/// This output represents a code snippet.
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

/// Represents a Boolean output.
///
/// This output represents a boolean value.
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
