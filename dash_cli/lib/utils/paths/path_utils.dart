import 'dart:io';
import 'package:path/path.dart' as p;

class PathUtils {

  static String get currentPath => Directory.current.path;
  static String get libPath => p.join(currentPath, 'lib');
  static String get testPath => p.join(currentPath, 'test');

  static String relatetiveLibFilePath(String filePath) =>
      p.relative(filePath, from: libPath);
  static String relativeTestFilePath(String filePath) =>
      p.relative(filePath, from: testPath);

  static String absouteLibFilePath(String relativePath) =>
      p.join('$libPath/$relativePath');
  static String absouteTestFilePath(String relativePath) =>
      p.join('$testPath/$relativePath');
  static String absouteProjectFilePath(String relativePath) =>
      p.join('$currentPath/$relativePath');

  static String fileURItoRelativePath(String filePath) {
    filePath = filePath.replaceAll('file:///', '/');
    return p.relative(filePath);
  }
}
