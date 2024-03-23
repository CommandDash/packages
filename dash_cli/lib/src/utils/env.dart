import 'dart:convert';
import 'dart:io';

import 'package:dash_cli/src/utils/logger.dart';
import 'package:path/path.dart' as p;

class WelltestedEnv {
  WelltestedEnv._();

  static final WelltestedEnv instance = WelltestedEnv._();

  final String dashCliVersion = '0.0.1';

  final String dashCliName = 'dash_cli';

  static File get configFile => File(getConfigPath);

  static String get getConfigPath {
    var home = Platform.isWindows
        ? Platform.environment['APPDATA']
        : Platform.environment['HOME'];
    return File(p.join(home!, '.config', '.welltested')).path;
  }

  Map<String, dynamic> get env => _env;

  Map<String, dynamic> _env = {};

  Map<String, dynamic> _verify(File f) {
    if (!f.existsSync()) {
      stderr.writeln('[dotenv] Load failed: file not found: $f');
      return {};
    }
    return json.decode(f.readAsStringSync());
  }

  void load() {
    var file = configFile;
    if (!file.existsSync()) {
      wtLog.warning('Config file not found. Creating one for you.');
      file.createSync(recursive: true);
    }
    _env = _verify(file);
  }

  static bool addNew(String key, String value) {
    try {
      if (configFile.existsSync()) {
        var data = configFile.readAsStringSync();
        var map = json.decode(data) as Map<String, dynamic>;
        map.addAll({key: value});
        configFile.writeAsStringSync(json.encode(map));
      } else {
        configFile.createSync(recursive: true);
        configFile.writeAsStringSync(json.encode({key: value}));
      }
      return true;
    } catch (e) {
      wtLog.error('Failed to save key.');
      return false;
    }
  }
}
