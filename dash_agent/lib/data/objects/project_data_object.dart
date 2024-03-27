abstract class ProjectDataObject {
  String get version;
  const ProjectDataObject();

  static TextObject fromText(String text) {
    return TextObject(text);
  }

  static JsonObject fromJson(Map<String, dynamic> json) {
    return JsonObject(json);
  }

  Future<Map<String, dynamic>> process();
}

class TextObject extends ProjectDataObject {
  final String text;

  const TextObject(this.text);

  Map<String, dynamic> toJson() {
    return {};
  }

  @override
  Future<Map<String, dynamic>> process() async {
    return {
      'id': hashCode.toString(),
      'type': 'text_object',
      'text': text,
      'version': version
    };
  }
  
  @override
  String get version => '1.0.0';
}

class JsonObject extends ProjectDataObject {
  final Map<String, dynamic> json;

  const JsonObject(this.json);

  @override
  Future<Map<String, dynamic>> process() async {
    return {
      'id': hashCode.toString(),
      'type': 'json_object',
      'json': json,
      'version': version
    };
  }
  
  @override
  String get version => '1.0.0';
}
