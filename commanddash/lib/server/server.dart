import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:async/async.dart';
import 'package:commanddash/server/messages.dart';

class Server {
  Server() {
    _init();
  }

  final StreamController<IncomingMessage> _incomingMessagesController =
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
    stdout.writeln(jsonEncode(message.toJson));
  }
}
