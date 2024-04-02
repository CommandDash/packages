import 'dart:io';
import 'package:path/path.dart' as p;

/// Base class for adding data to [DataSource] from the files available in the
/// local system.
///
/// This class should not be directly used to add data as this is a `abstract` class.
/// Instead its derivative classes should be used: [FileObject], [DirectoryFiles]
abstract class FileDataObject {
  String get version;
  const FileDataObject();

  /// static method to create and return [FileObject]. It takes following argument:
  /// - `file` - The [File] object containing the reference of data
  /// - `includePath` - This is used to let framework know whether your want include
  /// the path of the file also while saving it in cloud server or only the content. `true`
  /// mean that you are willing to store the path and false is an indicator to only
  /// store content. By default, it is `false` and is optional argument.
  /// - `relativeTo` - If you have shared the relative path to create the file object
  /// and you want to store parent path/relative path. You can do this by adding the
  /// path here. This optional.
  ///
  /// Example:
  /// ```dart
  /// final packageFile = File('path-to-your-file');
  /// fianl packageFileObject = FileDataObject.fromFile(packageFile)
  /// ```
  static FileObject fromFile(File file,
      {bool includePath = false, String? relativeTo}) {
    return FileObject(file, includePath: includePath, relativeTo: relativeTo);
  }

  /// static method to create and return [DirectoryFiles]. It takes following argument:
  /// - `Directory` - [Directory] object containg the reference to the directory
  /// that you want to store as a reference. By default, it will save all the files
  /// in the directory to the cloud.
  /// - `includePath` -  This is used to let framework know whether your want include
  /// the path of the directory also while saving it in cloud server or only the contents
  /// of the files inside the directory. `true` mean that you are willing to store the
  /// path and false is an indicator to only store content. By default, it is `false` and is optionl argument.
  /// - `relativeTo` -  If you have shared the relative path of the directory
  /// and you want to store parent path/relative path. You can do this by adding the
  /// path here. This optional.
  /// - `regex` - `RegExp` to filter specific files satisfying specific pattern that needs to
  /// be stored in the cloud for reference
  ///
  /// Example:
  /// ```dart
  /// final directory = Directory('path-to-directory');
  /// final directoryObject = FileDataObject.fromDirectory(directory);
  /// ```
  static DirectoryFiles fromDirectory(Directory directory,
      {bool includePaths = false, String? relativeTo, RegExp? regex}) {
    return DirectoryFiles(directory,
        includePaths: includePaths, relativeTo: relativeTo, regex: regex);
  }

  /// Internal method used by dash_agent to convert the shared `DataSource` to json
  /// format that can be sent on the web
  ///
  /// **Note**: Ideally, this method is not supposed to be overriden by the child
  /// objects and should not be altered. It is called automatically by the framework.
  Future<Map<String, dynamic>> process();
}

/// [FileObject] is used to add file data to [DataSource] which can be later used
/// for referencing by Agent.
///
/// Example:
/// ```dart
/// final packageFile = File('path-to-your-file');
/// fianl packageFileObject = FileDataObject.fromFile(packageFile)
/// ```
class FileObject extends FileDataObject {
  /// File object that contains the reference of the content that will be used by
  /// the agent as a reference.
  final File file;

  /// bool for specifying whether the file path should be saved as well or
  /// excluded from saving. By default, it is `false`
  final bool includePath;

  /// Optional parameter to share the parent path of the file
  ///
  /// Example:
  /// ```dart
  /// final relativeTo = '/Users/Local/Dev'
  final String? relativeTo;

  FileObject(this.file, {this.includePath = false, this.relativeTo});

  /// Internal method used by dash_agent to convert the shared `DataSource` to json
  /// format that can be sent on the web
  ///
  /// **Note**: Ideally, this method is not supposed to be overriden by the child
  /// objects and should not be altered. It is called automatically by the framework.
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

/// [DirectoryFiles] is used to add files from a directory to [DataSource] which can
/// be later used for referncing by Agent.
///
/// Example:
/// ```dart
/// final directory = Directory('path-to-directory');
/// final directoryObject = FileDataObject.fromDirectory(directory);
/// ```
class DirectoryFiles extends FileDataObject {
  /// Directory object that contains relevant files that will be used by the agent
  /// as a reference
  final Directory directory;

  /// bool for specifying whether the file path should be saved as well or
  /// excluded from saving. By default, it is `false`
  final bool includePaths;

  /// Optional parameter to share the parent path of the directory
  ///
  /// Example:
  /// ```dart
  /// final relativeTo = '/Users/Local/Dev'
  /// ```
  final String? relativeTo;

  /// Optional parameter to perform filetring of the files present in a directory
  /// for saving.
  ///
  /// Example:
  /// ```dart
  /// final testFilesRegex = RegExp('.*_test\.dart');
  /// ```
  final RegExp? regex;

  DirectoryFiles(this.directory,
      {this.includePaths = false, this.relativeTo, this.regex});

  /// Internal method used by dash_agent to convert the shared `DataSource` to json
  /// format that can be sent on the web
  ///
  /// **Note**: Ideally, this method is not supposed to be overriden by the child
  /// objects and should not be altered. It is called automatically by the framework.
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
