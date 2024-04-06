/// Base class for adding data to [DataSource] from the project itself. The data
/// can be of the form raw text or json.
///
/// This class should not be directly used to add data as this is a `abstract` class.
/// Instead its derivative classes should be used: [TextObject], [JsonObject]
abstract class ProjectDataObject {
  String get version;
  const ProjectDataObject();

  /// static method to create and return [TextObject]. It takes `String` object
  /// that represent data as an argument.
  ///
  /// Example:
  /// ```dart
  /// String firebaseDoc = '<firebase-doc>';
  /// final firebaseDocObject = ProjectDataObject.fromText(firebaseDoc);
  /// ```
  static TextObject fromText(String text) {
    return TextObject(text);
  }

  /// static method to create and return [JsonObject]. It takes `Map<String, dynamic>`
  /// that represents data as an argument
  ///
  /// Example:
  /// ```dart
  /// final apiVersion = {'Sample API v1': 'description and usage',
  ///                     'Sample API v2': 'description and usage'};
  /// final apiDocObject = ProjectDataObject.fromJson(apiVersion);
  /// ```
  static JsonObject fromJson(Map<String, dynamic> json) {
    return JsonObject(json);
  }

  /// Internal method used by dash_agent to convert the shared `DataSource` to json
  /// format that can be sent on the web
  ///
  /// **Note**: Ideally, this method is not supposed to be overriden by the child
  /// objects and should not be altered. It is called automatically by the framework.
  Future<Map<String, dynamic>> process();
}

/// [TextObject] is used to add `String` data to [DataSource] which can be later
/// used for referecing by Agent
///
/// Example:
/// ```dart
/// String firebaseDoc = '<firebase-doc>';
/// final firebaseDocObject = ProjectDataObject.fromText(firebaseDoc);
/// ```
class TextObject extends ProjectDataObject {
  /// text representing the data from the project that will be used by the agent
  /// as reference
  final String text;

  const TextObject(this.text);

  /// Internal method used by dash_agent to convert the shared `DataSource` to json
  /// format that can be sent on the web
  ///
  /// **Note**: Ideally, this method is not supposed to be overriden by the child
  /// objects and should not be altered. It is called automatically by the framework.
  @override
  Future<Map<String, dynamic>> process() async {
    return {
      'id': hashCode.toString(),
      'type': 'text_object',
      'content': text,
      'version': version
    };
  }

  @override
  String get version => '0.0.1';
}

/// [JsonObject] is used to add json data to [DataSource] which can be later used
/// for referencing by Agent.
///
/// Example:
/// ```dart
/// final apiVersion = {'Sample API v1': 'description and usage',
///                     'Sample API v2': 'description and usage'};
/// final apiDocObject = ProjectDataObject.fromJson(apiVersion);
/// ```
class JsonObject extends ProjectDataObject {
  /// data in the form of `Map` from the project that will be used by the agent
  /// as reference
  final Map<String, dynamic> json;

  const JsonObject(this.json);

  /// Internal method used by dash_agent to convert the shared `DataSource` to json
  /// format that can be sent on the web
  ///
  /// **Note**: Ideally, this method is not supposed to be overriden by the child
  /// objects and should not be altered. It is called automatically by the framework.
  @override
  Future<Map<String, dynamic>> process() async {
    return {
      'id': hashCode.toString(),
      'type': 'json_object',
      'content': json,
      'version': version
    };
  }

  @override
  String get version => '0.0.1';
}
