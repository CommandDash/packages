import 'package:commanddash/agent/input_model.dart';
import 'package:commanddash/models/workspace_file.dart';
import 'package:test/test.dart';

void main() {
  group('CodeInput tests', () {
    test('getFileCodeWithReplacedCode should replace code within range', () {
      // Arrange
      final codeInput = BaseCodeInput(
        id: '1',
        filePath: '/path/to/file',
        range: Range(
          start: Position(line: 2, character: 6),
          end: Position(line: 2, character: 11),
        ),
        content: ''' a = ''',
        fileContent: '''void main(List<String> args) {
  print("Hello, world!");
  int a = 5;
  int b = 10;
  int sum = a + b;
  print("The sum of \$a and \$b is \$sum.");

  String name = "John Doe";
  print("My name is \$name.");
}
''',
      );

      final newContent = 'REPLACED';

      // Act
      final result = codeInput.getFileCodeWithReplacedCode(newContent);

      // Assert
      expect(
        result,
        '''void main(List<String> args) {
  print("Hello, world!");
  intREPLACED5;
  int b = 10;
  int sum = a + b;
  print("The sum of \$a and \$b is \$sum.");

  String name = "John Doe";
  print("My name is \$name.");
}
''',
      );
    });

    test('getFileCodeWithReplacedCode should handle empty content', () {
      // Arrange
      final codeInput = BaseCodeInput(
        id: '1',
        filePath: '/path/to/file',
        range: Range(
          start: Position(line: 0, character: 0),
          end: Position(line: 0, character: 0),
        ),
        content: '',
        fileContent: '',
      );

      final newContent = 'replaced';

      // Act
      final result = codeInput.getFileCodeWithReplacedCode(newContent);

      // Assert
      expect(result, 'replaced');
    });

    // Add more test cases as needed
  });
}
