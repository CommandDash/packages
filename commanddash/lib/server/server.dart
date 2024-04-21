import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:async/async.dart';
import 'package:commanddash/server/messages.dart';

class Server {
  late OutWrapper stdout;
  Server() {
    _init();
    stdout = StdOutWrapper();
  }

  StreamController<IncomingMessage> _incomingMessagesController =
      StreamController.broadcast();

  Stream<IncomingMessage> get messagesStream =>
      _incomingMessagesController.stream;

  StreamQueue<IncomingMessage> get incomingMessageQueue =>
      StreamQueue(messagesStream);

  void _init() {
    stdin.transform(utf8.decoder).transform(LineSplitter()).listen((line) {
      if (line == 'exit') exit(0);

      final Map<String, dynamic> request = jsonDecode(line);
      _incomingMessagesController.add(IncomingMessage.fromJson(request));
    });
  }

  void sendMessage(OutgoingMessage message) {
    stdout.writeOutgoingMessage(message);
  }

  void replaceMessageStreamController(
      StreamController<IncomingMessage> controller) {
    _incomingMessagesController = controller;
  }
}

class StdOutWrapper implements OutWrapper {
  @override
  void writeOutgoingMessage(OutgoingMessage message) {
    stdout.writeln(jsonEncode(message.toJson));
  }
}

abstract class OutWrapper {
  void writeOutgoingMessage(OutgoingMessage message);
}

/// Use this method to print logs on the IDE when debugging
///
/// The benefit is that it does not require [TaskAssist]. Do not ship with [sendDebugMessage] active in code.
sendDebugMessage(Map<String, dynamic> data) {
  print(jsonEncode(
      {'id': 'independent', 'method': 'debug_message', 'params': data}));
}
