// lib/variables/dash_output.dart
import 'package:dash_agent/variables/variable.dart';

abstract class DashOutput extends Variable {
  DashOutput();

  Future<Map<String, dynamic>> process();
}

class DefaultOutput extends DashOutput {
  DefaultOutput();

  @override
  Future<Map<String, dynamic>> process() async {
    return {
      'id': hashCode.toString(),
      'type': 'default_output',
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
      'type': 'multi_code_object',
      'version': version
    };
  }
}

class CodeObject {
  CodeObject();

  Future<Map<String, dynamic>> process() async {
    return {
      'id': hashCode.toString(),
      'type': 'code_object',
    };
  }
}

class DataSourceResultOutput extends DashOutput {
  DataSourceResultOutput();

  @override
  Future<Map<String, dynamic>> process() async {
    return {
      'id': hashCode.toString(),
      'type': 'user_choice_output',
    };
  }
}
