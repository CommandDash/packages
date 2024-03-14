import 'package:commanddash/agent/input_model.dart';
import 'package:commanddash/agent/output_model.dart';
import 'package:commanddash/models/workspace_file.dart';
import 'package:commanddash/steps/steps_utils.dart';
import 'package:test/test.dart';

void main() {
  test('replacePlaceholder correctly replaces placeholders', () {
    final String testString = '<1> and <2>';
    final Map<String, Input> inputs = {
      '1': StringInput('1', 'Input1'),
      '2': StringInput('1', 'Input2'),
    };
    final Map<String, Output> outputs = {};
    final output = testString.replacePlaceholder(inputs, outputs);

    expect(testString.replacePlaceholder(inputs, outputs), 'Input1 and Input2');
  });

  test('replacePlaceholder correctly replaces placeholders with outputs', () {
    final String testString = '<1> and <2>';
    final Map<String, Input> inputs = {};
    final Map<String, Output> outputs = {
      '1': DefaultOutput('Output1'),
      '2': DefaultOutput('Output2'),
    };

    expect(
        testString.replacePlaceholder(inputs, outputs), 'Output1 and Output2');
  });

  test('replacePlaceholder correctly replaces placeholders with mixed inputs',
      () {
    final String testString = '<1> and <2>';
    final Map<String, Input> inputs = {
      '1': StringInput('1', 'Input1'),
    };
    final Map<String, Output> outputs = {
      '2': DefaultOutput('Output2'),
    };

    expect(
        testString.replacePlaceholder(inputs, outputs), 'Input1 and Output2');
  });

  test(
      'replacePlaceholder correctly replaces placeholders with MultiCodeOutput',
      () {
    final String testString = '<1> and <2>';
    final Map<String, Input> inputs = {
      '1': StringInput('1', 'Input1'),
    };
    final Map<String, Output> outputs = {
      '2': MultiCodeOutput([
        WorkspaceFile('file1', content: 'content1'),
        WorkspaceFile('file2', content: 'content2'),
      ]),
    };

    expect(testString.replacePlaceholder(inputs, outputs),
        'Input1 and File: file1\ncontent1File: file2\ncontent2');
  });
}
