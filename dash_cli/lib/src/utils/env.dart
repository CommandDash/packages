import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

import '../models/config.dart';
import 'logger.dart';
import 'version.dart';

/// Environment variables for the CLI.
class WelltestedEnv {
  WelltestedEnv._();

  /// Singleton instance of the class.
  static final WelltestedEnv instance = WelltestedEnv._();

  /// Version of the CLI.
  final String dashCliVersion = version;

  /// Name of the CLI.
  final String dashCliName = 'dash_cli';

  /// Get the config file.
  static File get configFile => File(getConfigPath);

  /// Get the path to the config file.
  static String get getConfigPath {
    String? home = Platform.isWindows
        ? Platform.environment['APPDATA']
        : Platform.environment['HOME'];
    return p.join(home!, '.config', '.welltested');
  }

  /// Get the Config environment variables.
  Config get env => _env;

  /// Config environment variables.
  Config _env = Config();

  /// Verify the config file.
  Map<String, dynamic> _verify(File f) {
    if (!f.existsSync()) {
      stderr.writeln('[dotenv] Load failed: file not found: $f');
      return <String, dynamic>{};
    }
    String fileData = f.readAsStringSync();
    return json.decode(fileData.isEmpty ? '{}' : fileData)
        as Map<String, dynamic>;
  }

  /// Load the config file.
  ///
  /// If the file does not exist, it will be created.
  /// (This method is called in the main function of the CLI.)
  void load() {
    File file = configFile;
    if (!file.existsSync()) {
      wtLog.warning('Config file not found. Creating one for you.');
      file.createSync(recursive: true);
    }
    _env = Config.fromJson(_verify(file));
  }

  /// Add new key to the config file.
  ///
  /// TODO: Eventually, this method should be moved to the Config class.
  static bool addNew(String key, String value) {
    try {
      if (configFile.existsSync()) {
        String data = configFile.readAsStringSync();
        Map<String, dynamic> map = json.decode(data.isEmpty ? '{}' : data) as Map<String, dynamic>;
        map.addAll(<String, dynamic>{key: value});
        configFile.writeAsStringSync(json.encode(map));
      } else {
        configFile.createSync(recursive: true);
        configFile.writeAsStringSync(json.encode(<String, String>{key: value}));
      }
      return true;
    } catch (e) {
      wtLog.error('Failed to save key. $e');
      rethrow;
    }
  }
}
