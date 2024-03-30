abstract class PromptResponseParser {
  String parse(String response);
  factory PromptResponseParser.fromJson(Map<String, dynamic> json) {
    final type = json['type'];
    switch (type) {
      case 'raw':
        return RawPromptResponseParser();
      case 'code':
        return CodeExtractPromptResponseParser();
      default:
        throw UnimplementedError();
    }
  }
}

class RawPromptResponseParser implements PromptResponseParser {
  @override
  String parse(String response) {
    return response;
  }
}

class CodeExtractPromptResponseParser implements PromptResponseParser {
  @override
  String parse(String response) {
    final regex = RegExp(r'^```(?:\w+)?\s*\n(.*?)(?=^```)```',
        multiLine: true, dotAll: true);
    final match = regex.firstMatch(response);

    if (match == null) {
      throw Exception('No code block found in response');
    }

    return match.group(1) ?? '';
    //  extract code from response within ``` and ```
    final start = response.indexOf('```');
    final end = response.lastIndexOf('```');
    if (start == -1 || end == -1) {
      throw Exception('Invalid response');
    }
    final code = response.substring(start + 3, end);
    if (code.isEmpty) {
      throw Exception('No code found in response');
    }
    return code;
  }
}
