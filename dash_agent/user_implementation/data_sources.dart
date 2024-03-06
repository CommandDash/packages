import 'dart:io';

import 'package:dash_agent/data/datasource.dart';
import 'package:dash_agent/data/objects/project_data_object.dart';
import 'package:dash_agent/data/objects/system_data_object.dart';
import 'package:dash_agent/data/objects/web_data_object.dart';

class DocsDataSource extends DataSource {
  @override
  List<SystemDataObject> get fileObjects => [
        SystemDataObject.fromFile(File(
            '/Users/samyak/Documents/commanddash/commanddash/dash_agent/assets/my-article.txt'))
      ];

  @override
  List<ProjectDataObject> get projectObjects =>
      [ProjectDataObject.fromText('Some Value')];

  @override
  List<WebDataObject> get webObjects => [];
}

class BlogsDataSource extends DataSource {
  @override
  List<SystemDataObject> get fileObjects => [
        DirectoryFiles(
            Directory(
                '/Users/samyak/Documents/commanddash/commanddash/dash_agent/assets/blogs'),
            relativeTo:
                '/Users/samyak/Documents/commanddash/commanddash/dash_agent/assets/blogs')
      ];

  @override
  List<ProjectDataObject> get projectObjects => [];

  @override
  List<WebDataObject> get webObjects =>
      [WebDataObject.fromWebPage('https://pub.dev/packages/path')];
}
