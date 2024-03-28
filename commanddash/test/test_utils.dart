import 'dart:async';
import 'dart:io';

import 'package:commanddash/server/messages.dart';
import 'package:commanddash/server/server.dart';

class EnvReader {
  static final Map<String, String> _envMap = {};

  static Future<void> load() async {
    final file = File('.env');
    final lines = await file.readAsLines();
    for (var line in lines) {
      _parseAndAddToMap(line);
    }
  }

  static void _parseAndAddToMap(String line) {
    // Ignores comments and empty lines
    if (line.startsWith('#') || line.isEmpty) return;

    final index = line.indexOf('=');
    if (index != -1) {
      final key = line.substring(0, index);
      final value = line.substring(index + 1);
      _envMap[key] = value;
    }
  }

  static String? get(String key) => _envMap[key];
}

class TestOutWrapper extends OutWrapper {
  final outputStream = StreamController<OutgoingMessage>.broadcast();
  @override
  void writeOutgoingMessage(OutgoingMessage message) {
    outputStream.add(message);
  }
}
