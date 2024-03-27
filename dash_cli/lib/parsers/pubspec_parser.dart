import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

import '../models/pubspec_data.dart';


class PubspecParser {
  static Future<PubspecData> forPath(String packagePath) async {
    /// Read in the pubspec file and parse it as yaml.
    final pubspecFile = File(p.join(packagePath, 'pubspec.yaml'));
    if (!pubspecFile.existsSync()) {
      throw StateError('No `pubspec.yaml` found. '
          'Run dash_cli only on a Flutter or Dart project.');
    }
    final YamlMap pubspec = loadYaml(pubspecFile.readAsStringSync()) as YamlMap;
    final rootPackageName = pubspec['name'] as String;
    final environment = pubspec['environment'] as Map;
    final dependencies = pubspec['dependencies'] as Map?;
    final devDependencies = pubspec['dev_dependencies'] as Map?;

    return PubspecData(
      rootPackageName,
      environment: environment,
      dependencies: dependencies,
      devDependencies: devDependencies,
      isFlutter: dependencies?.containsKey('flutter') ?? false,
    )..toJson();
  }
}
