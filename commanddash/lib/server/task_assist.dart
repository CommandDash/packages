import 'package:commanddash/server/messages.dart';
import 'package:commanddash/server/server.dart';
import 'package:rxdart/rxdart.dart';

class TaskAssist {
  TaskAssist(this._server, this._taskId);
  final Server _server;
  final int _taskId;

  Future<Map<String, dynamic>> processStep(
      {required String kind, required Map<String, dynamic> args}) async {
    _server.sendMessage(ProcessMessage(_taskId, kind: kind, args: args));
    final dataResponse = await _server.messagesStream
        .whereType<ProcessResponseMessage>()
        .where((event) => event.id == _taskId)
        .first;
    return dataResponse.data;
  }

  void sendResultMessage(
      {required String message, required Map<String, dynamic> data}) {
    _server.sendMessage(ResultMessage(_taskId, message: message, data: data));
  }

  void sendErrorMessage(
      {required message, required Map<String, dynamic> data}) {
    _server.sendMessage(ErrorMessage(_taskId, message: message, data: data));
  }

  /// Only use for debugging purposes. Clients can print the log on their end.
  void sendLogMessage({required message, required Map<String, dynamic> data}) {
    _server.sendMessage(LogMessage(_taskId, message: message, data: data));
  }
}
