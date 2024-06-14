import 'package:dash_agent/data/objects/project_data_object.dart';
import 'package:dash_agent/data/objects/file_data_object.dart';
import 'package:dash_agent/data/objects/web_data_object.dart';

/// [DataSource] are lists of all the documents, files, web pages and entire
///  website that you may want to query in your process steps. You can use them
///  to provide the website documentation, provide your own usage examples, or
///  document techniques of achieveing something.
///
/// `DataSource` needs the following getters passed:
/// - `projectObjects` - List of [ProjectDataObject]s that can be used to pass data
/// from the project itself.
/// - `fileObjects` - List of [FileDataObject]s that can be used to pass data from
/// files and directories.
/// - `webObjects` - List of [WebDataObject]s that can be used to pass data from
/// web pages or all the web pages of a domain (via passing xml link for the domain)
///
/// Sample example of [DataSource] for demonstration purpose:
/// ```dart
/// class DocsDataSource extends DataSource {
///  @override
///  List<SystemDataObject> get fileObjects => [
///        SystemDataObject.fromFile(File(
///            'your_file_path'))
///      ];
///
///  @override
///  List<ProjectDataObject> get projectObjects =>
///      [ProjectDataObject.fromText('Data in form of raw text')];
///
///  @override
///  List<WebDataObject> get webObjects => [];
/// }
///
/// class BlogsDataSource extends DataSource {
///  @override
///  List<SystemDataObject> get fileObjects => [
///        DirectoryFiles(
///            Directory(
///                'directory_path_to_data_source'),
///            relativeTo:
///                'parent_directory_path')
///      ];
///
///  @override
///  List<ProjectDataObject> get projectObjects => [];
///
///  @override
///  List<WebDataObject> get webObjects =>
///      [WebDataObject.fromWebPage('https://sampleurl.com')];
/// }
/// ```
abstract class DataSource {
  String get minCliVersion => '0.0.1';

  /// List of [ProjectDataObject]s that can be used to pass data
  /// from the project itself.
  ///
  /// Currently supported [ProjectDataObject]:
  ///   - `TextObject` - This can be used to pass the data in form of String. You
  /// can use `ProjectDataObject.fromText` to create [TextObject]
  ///   - `JsonObject` - This can be used to pass the data in form of Json. You
  /// can use `ProjectDataObject.fromJson` to create [JsonObject]
  ///
  /// Example:
  /// ```dart
  ///  @override
  ///  List<ProjectDataObject> get projectObjects =>
  ///      [ProjectDataObject.fromText('Data in form of raw text'),
  ///       ProejctDataObject.fromJson(
  ///         {'Sample API 1': 'description and usage',
  ///         'Sample API 2': 'description and usage'})
  ///       ];
  /// ```
  List<ProjectDataObject> get projectObjects;

  /// List of [FileDataObject]s that can be used to pass data from
  /// files and directories.
  ///
  /// Currently supported [FileDataObject]:
  ///   - `FileObject` - Pass the data by providing the [File] object. You can use
  /// `FileDataObject.fromFile` to create [FileObject]
  ///   - `DirectoryFiles` - Pass the data by providing the [Directory] object. You
  /// can use `FileDataObject.fromDirectory` to create [DirectoryFiles]
  ///
  /// Example:
  /// ```dart
  ///  @override
  ///  List<SystemDataObject> get fileObjects => [
  ///        FileDataObject.fromDirectory(
  ///            Directory(
  ///                'directory_path_to_data_source'),
  ///            relativeTo:
  ///                'parent_directory_path'),
  ///        FileDataObject.fromFile(
  ///           File(your_file_path)
  ///         )
  ///      ];
  /// ```
  List<FileDataObject> get fileObjects;

  /// List of [WebDataObject]s that can be used to pass data from web pages or
  /// all the web pages of a domain (via passing xml file for the domain).
  ///
  /// Currently supported [WebDataObject]:
  ///   - `WebPage` - Pass the data by providing the url of web page that contain
  /// the relevant data. You can use `WebDataObject.fromWebPage` to create [WebPage]
  ///   - `SiteMap` - Pass the data by providing the site map url of the domain
  /// contain the relevant data. You can use `WebDataObject.fromSiteMap` to  create
  /// [SiteMap]
  ///  - `GitHub` - Pass the repo data by providing github repo url along with
  /// optional code and issue filter to extract specific data. You can use
  /// `WebDataObject.fromGithub` to create [Github]
  ///
  /// Example:
  /// ```dart
  /// @override
  ///  List<WebDataObject> get webObjects =>
  ///      [WebDataObject.fromWebPage('https://sampleurl.com'),
  ///       WebDataObject.fromSiteMap('https://sitemaps.example.com/sitemap-example-com.xml'),
  ///       WebDataObject.fromGithub('https://github.com/user/repo', '<personal access token>')
  ///    ];
  /// ```
  List<WebDataObject> get webObjects;

  /// Internal method used by dash_agent to convert the shared `DataSource` to json
  /// format that can be sent on the web
  ///
  /// **Note**: Ideally, this method is not supposed to be overriden by the child
  /// objects and should not be altered. It is called automatically by the framework.
  Future<Map<String, dynamic>> process() async {
    final Map<String, dynamic> processedJson = {'id': hashCode.toString()};

    processedJson['version'] = minCliVersion;
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
