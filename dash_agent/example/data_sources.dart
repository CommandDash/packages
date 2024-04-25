import 'dart:io';

import 'package:dash_agent/data/datasource.dart';
import 'package:dash_agent/data/objects/project_data_object.dart';
import 'package:dash_agent/data/objects/file_data_object.dart';
import 'package:dash_agent/data/objects/web_data_object.dart';

class DocsDataSource extends DataSource {
  @override
  List<FileDataObject> get fileObjects =>
      [FileDataObject.fromFile(File('../assets/my-article.txt'))];

  @override
  List<ProjectDataObject> get projectObjects =>
      [ProjectDataObject.fromText('Some Value')];

  @override
  List<WebDataObject> get webObjects => [];
}

class BlogsDataSource extends DataSource {
  @override
  List<FileDataObject> get fileObjects => [
        DirectoryFiles(Directory('../assets/blogs'),
            relativeTo: '../assets/blogs')
      ];

  @override
  List<ProjectDataObject> get projectObjects => [];

  @override
  List<WebDataObject> get webObjects =>
      [WebDataObject.fromWebPage('https://pub.dev/packages/path')];
}
