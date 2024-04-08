import 'package:commanddash/steps/prompt_query/prompt_response_parsers.dart';
import 'package:test/test.dart';

void main() {
  test('PromptOutputParser returns text outside code blocks', () {
    RegExp exp = RegExp(r"```([\s\S]*?)```");

    final response = '''
    This is some text outside code blocks.

    ```
    This is a code block.
    ```

    More text outside code blocks.

    ```dart
    This is another code block.
    ```

    Final text.
  ''';

    expect(
        response.replaceAll(exp, '').trim(),
        '''
    This is some text outside code blocks.

    

    More text outside code blocks.

    

    Final text.
  '''
            .trim());
  });

  test('PromptOutputParser returns empty string if no text found', () {
    final parser = PromptOutputParser();

    final response = '''
      ```
      This is a code block.
      ```
    ''';

    expect(parser.parse(response).trim(), '');
  });

  test('RawPromptResponseParser returns the same response', () {
    final parser = RawPromptResponseParser();

    final response = 'This is a raw response';

    expect(parser.parse(response), response);
  });

  test('CodeExtractPromptResponseParser returns code from response', () {
    final parser = CodeExtractPromptResponseParser();

    final response = '''
      Some text before code block.

      ```
      This is a code block.
      ```

      Some text after code block.
    ''';

    expect(
        parser.parse(response).trim(),
        '''
      This is a code block.
    '''
            .trim());
  });

  test('CodeExtractPromptResponseParser handles language name', () {
    final parser = CodeExtractPromptResponseParser();

    final response = '''
      Some text before code block.

      ```dart
      This is a code block.
      ```

      Some text after code block.
    ''';

    expect(
        parser.parse(response).trim(),
        '''
      This is a code block.
    '''
            .trim());
  });

  test('CodeExtractPromptResponseParser throws exception if no code found', () {
    final parser = CodeExtractPromptResponseParser();

    final response = '''
      No code block here.
    ''';

    expect(parser.parse(response), '');
  });
}
