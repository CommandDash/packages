// lib/data/objects/system_data_object.dart
import 'dart:io';
import 'package:path/path.dart' as p;

abstract class FileDataObject {
  String get version;
  const FileDataObject();

  static FileObject fromFile(File file,
      {bool includePath = false, String? relativeTo}) {
    return FileObject(file, includePath: includePath, relativeTo: relativeTo);
  }

  static DirectoryFiles fromDirectory(Directory directory,
      {bool includePaths = false, String? relativeTo, RegExp? regex}) {
    return DirectoryFiles(directory,
        includePaths: includePaths, relativeTo: relativeTo, regex: regex);
  }

  Future<Map<String, dynamic>> process();
}

class FileObject extends FileDataObject {
  final File file;
  final bool includePath;
  final String? relativeTo;

  FileObject(this.file, {this.includePath = false, this.relativeTo});

  @override
  Future<Map<String, dynamic>> process() async {
    if (!file.existsSync()) {
      throw Exception('File does not exist');
    }

    return {
      'id': hashCode.toString(),
      'type': 'file_object',
      'content': await file.readAsString(),
      ...(includePath ? {'path': p.relative(file.path, from: relativeTo)} : {}),
      'version': version
    };
  }

  @override
  String get version => '0.0.1';
}

class DirectoryFiles extends FileDataObject {
  final Directory directory;
  final bool includePaths;
  final String? relativeTo;
  final RegExp? regex;

  DirectoryFiles(this.directory,
      {this.includePaths = false, this.relativeTo, this.regex});

  @override
  Future<Map<String, dynamic>> process() async {
    if (!directory.existsSync()) {
      throw Exception('Directory does not exist');
    }

    List<Map<String, dynamic>> files = [];

    for (var file in directory.listSync(recursive: true)) {
      if (file is File) {
        if (regex != null && !regex!.hasMatch(file.path)) {
          continue;
        }

        String content = await file.readAsString();

        files.add({
          'id': hashCode.toString(),
          'type': 'file_object',
          'content': content,
          ...(includePaths
              ? {'path': p.relative(file.path, from: relativeTo)}
              : {}),
        });
      }
    }

    return {
      'id': hashCode.toString(),
      'type': 'directory_files',
      'files': files,
      'version': version
    };
  }

  @override
  String get version => '0.0.1';
}
