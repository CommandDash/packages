import 'package:dash_agent/data/objects/project_data_object.dart';
import 'package:dash_agent/data/objects/system_data_object.dart';
import 'package:dash_agent/data/objects/web_data_object.dart';

/// [DataSource] are lists of all the documents, files, web pages and entire website that you may want to query in your process steps.
/// You can use them to provide the website documentation, provide your own usage examples, or document techniques of achieveing something.
abstract class DataSource {
  String get version => '0.0.1';
  List<ProjectDataObject> get projectObjects;
  List<FileDataObject> get fileObjects;
  List<WebDataObject> get webObjects;

  Future<Map<String, dynamic>> process() async {
    final Map<String, dynamic> processedJson = {'id': hashCode.toString()};

    processedJson['version'] = version;
    processedJson['project_objects'] = [];
    for (final projectObject in projectObjects) {
      processedJson['project_objects'].add(await projectObject.process());
    }
    processedJson['file_objects'] = [];
    for (final fileObject in fileObjects) {
      processedJson['file_objects'].add(await fileObject.process());
    }
    processedJson['web_objects'] = [];
    for (final webObject in webObjects) {
      processedJson['web_objects'].add(await webObject.process());
    }

    return processedJson;
  }

  @override
  String toString() {
    return '<${hashCode.toString()}>';
  }
}
