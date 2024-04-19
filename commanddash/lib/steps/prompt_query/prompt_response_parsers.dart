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

class PromptOutputParser implements PromptResponseParser {
  @override
  String parse(String response) {
    RegExp exp = RegExp(r"```([\s\S]*?)```");
    return response.replaceAll(exp, '').trim();
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
    RegExp exp = RegExp(r"```([\s\S]*?)```");
    Iterable<Match> matches = exp.allMatches(response);
    if (matches.isEmpty) {
      return '';
    }
    final match = matches.last;
    String block = match.group(1) ?? "";
    // Remove language tags
    String cleanedBlock = block.replaceAllMapped(
        RegExp(r"^(python|dart|ts|code|javascript|java)\s*:\s*",
            caseSensitive: false),
        (match) => "");
    cleanedBlock = cleanedBlock.replaceAllMapped(
        RegExp(r"^(python|dart|ts|code|javascript|java)\s*\s*",
            caseSensitive: false),
        (match) => "");
    return cleanedBlock;
  }
}
