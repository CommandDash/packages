import 'dart:async';
import 'dart:io';

import 'package:ansi_escapes/ansi_escapes.dart';

final wtLog = WelltestedLogger();
final frames = ['⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏'];

enum MessageSeverity { log, info, success, warning, error }

class Terminal {
  static String _ansiColor(String message,
      {required MessageSeverity severity}) {
    List<int> hexColor = _severityToHexColor(severity);

    int r = hexColor[0];
    int g = hexColor[1];
    int b = hexColor[2];
    return '\x1b[38;2;$r;$g;${b}m$message\x1b[0m';
  }

  static List<int> _severityToHexColor(MessageSeverity severity) {
    switch (severity) {
      case MessageSeverity.log:
        return [211, 215, 207]; // Easy on the eyes White
      case MessageSeverity.info:
        return [0, 255, 255]; // Cyan
      case MessageSeverity.success:
        return [2, 185, 106]; // Welltested Green
      case MessageSeverity.warning:
        return [255, 255, 0]; // Yellow
      case MessageSeverity.error:
        return [255, 0, 0]; // Red
      default:
        return [211, 215, 207]; // (Default) Easy on the eyes White
    }
  }

  static writeNormalmessage(String message,
      {required MessageSeverity severity}) {
    stdout.writeln(_ansiColor(message, severity: severity));
  }

  static writeMessage(String message, List<dynamic> frames, int index,
      {required MessageSeverity severity}) {
    stdout.write(
      '${ansiEscapes.eraseLine}\r${_ansiColor(frames[index], severity: severity)} '
      '${_ansiColor(message, severity: severity)} ${ansiEscapes.cursorHide}',
    );
  }

  static writeFinalMessage(String message,
      {required MessageSeverity severity}) {
    stdout.writeln(
      '${ansiEscapes.eraseLine}\r${_ansiColor(message, severity: severity)} '
      '${ansiEscapes.cursorShow}',
    );
  }

  static eraseExistingLine() {
    stdout.write('${ansiEscapes.eraseLine}${ansiEscapes.cursorShow}\r');
  }
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

  startSpinner(String message,
      {MessageSeverity severity = MessageSeverity.log}) {
    if (_spinner != null) stopSpinner();
    _spinner = Spinner(message)
      ..severity = severity
      ..isBusy = true;
    _timer = Timer.periodic(Duration(milliseconds: 80), (timer) {
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
    _timer = Timer.periodic(Duration(milliseconds: 80), (timer) {
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
