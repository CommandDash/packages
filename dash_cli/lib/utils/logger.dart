import 'dart:async';
import 'dart:io';

import 'package:ansi_escapes/ansi_escapes.dart';

final WelltestedLogger wtLog = WelltestedLogger();
final List<String> frames = <String>[
  '⠋',
  '⠙',
  '⠹',
  '⠸',
  '⠼',
  '⠴',
  '⠦',
  '⠧',
  '⠇',
  '⠏'
];

enum MessageSeverity { log, info, success, warning, error }

class Terminal {
  static String _ansiColor(String message,
          {required MessageSeverity severity}) =>
      _severityToHexColor(message, severity);

  static String _severityToHexColor(String msg, MessageSeverity severity) {
    switch (severity) {
      case MessageSeverity.info:
        return msg.cyan; // Cyan
      case MessageSeverity.success:
        return msg.green; // Welltested Green
      case MessageSeverity.warning:
        return msg.yellow; // Yellow
      case MessageSeverity.error:
        return msg.red; // Red
      case MessageSeverity.log:
      default:
        return msg.white; // (Default) Easy on the eyes White
    }
  }

  static void writeNormalmessage(String message,
          {required MessageSeverity severity}) =>
      stdout.writeln(_ansiColor(message, severity: severity));

  static void writeMessage(String message, List<dynamic> frames, int index,
          {required MessageSeverity severity}) =>
      stdout.write(
        '${ansiEscapes.eraseLine}\r${_ansiColor(frames[index], severity: severity)} '
        '${_ansiColor(message, severity: severity)} ${ansiEscapes.cursorHide}',
      );

  static void writeFinalMessage(String message,
          {required MessageSeverity severity}) =>
      stdout.writeln(
        '${ansiEscapes.eraseLine}\r${_ansiColor(message, severity: severity)} '
        '${ansiEscapes.cursorShow}',
      );

  static void eraseExistingLine() =>
      stdout.write('${ansiEscapes.eraseLine}${ansiEscapes.cursorShow}\r');
}

class Spinner {
  bool isBusy = false;
  MessageSeverity severity = MessageSeverity.log;
  int index = 0;
  late String message;
  Spinner(this.message);
}

class WelltestedLogger {
  WelltestedLogger();
  Spinner? _spinner;
  Timer? _timer;
  bool _verbose = false;
  bool get isBusy => _spinner?.isBusy ?? false;

  set setVerbose(bool value) => _verbose = value;

  bool get verbose => _verbose;

  void startSpinner(String message,
      {MessageSeverity severity = MessageSeverity.log}) {
    if (_spinner != null) stopSpinner();
    _spinner = Spinner(message)
      ..severity = severity
      ..isBusy = true;
    _timer = Timer.periodic(const Duration(milliseconds: 80), (Timer timer) {
      _updateStatus();
    });
  }

  void _updateStatus() {
    Terminal.writeMessage(_spinner!.message, frames, _spinner!.index,
        severity: _spinner!.severity);
    _spinner!.index = (_spinner!.index + 1) % frames.length;
  }

  void stopSpinner(
      {String? message, MessageSeverity severity = MessageSeverity.log}) {
    _timer?.cancel();
    _spinner = null;
    if (message != null) {
      Terminal.writeFinalMessage(message, severity: severity);
    } else {
      Terminal.eraseExistingLine();
    }
  }

  void updateSpinnerMessage(String message) {
    _spinner?.message = message;
  }

  void log(String message, {bool verbose = false}) {
    if (!verbose || _verbose) {
      _outputMessage(message, severity: MessageSeverity.log);
    }
  }

  void info(String message, {bool verbose = false}) {
    if (!verbose || _verbose) {
      _outputMessage(message, severity: MessageSeverity.info);
    }
  }

  void success(String message, {bool verbose = false}) {
    if (!verbose || _verbose) {
      _outputMessage(message, severity: MessageSeverity.success);
    }
  }

  void warning(String message, {bool verbose = false}) {
    if (!verbose || _verbose) {
      _outputMessage(message, severity: MessageSeverity.warning);
    }
  }

  void error(String message, {bool verbose = false}) {
    if (!verbose || _verbose) {
      _outputMessage(message, severity: MessageSeverity.error);
    }
  }

  void _pauseSpinner() {
    _timer?.cancel();
    Terminal.eraseExistingLine();
  }

  void _resumeSpinner() {
    _timer = Timer.periodic(const Duration(milliseconds: 80), (Timer timer) {
      _updateStatus();
    });
  }

  void _outputMessage(String message,
      {MessageSeverity severity = MessageSeverity.log}) {
    if (_spinner?.isBusy ?? false) _pauseSpinner();
    Terminal.writeNormalmessage(message, severity: severity);
    if (_spinner?.isBusy ?? false) _resumeSpinner();
  }
}

extension TerminalColors on String {
  String Function(String) _colorCodeFormatter(String start, String end) =>
      (String x) =>
          !stdout.supportsAnsiEscapes ? x : '\x1B[${start}m$x\x1B[${end}m';

  String get bold => _colorCodeFormatter('1', '22')(this);

  String get red => _colorCodeFormatter('31', '39')(this);

  String get green => _colorCodeFormatter('32', '39')(this);

  String get yellow => _colorCodeFormatter('33', '39')(this);

  String get blue => _colorCodeFormatter('34', '39')(this);

  String get magenta => _colorCodeFormatter('35', '39')(this);

  String get cyan => _colorCodeFormatter('36', '39')(this);

  String get white => _colorCodeFormatter('37', '39')(this);
}
