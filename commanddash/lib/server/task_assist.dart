import 'package:commanddash/server/messages.dart';
import 'package:commanddash/server/operation_message.dart';
import 'package:commanddash/server/server.dart';
import 'package:rxdart/rxdart.dart';

class TaskAssist {
  TaskAssist(this._server, this._taskId);
  final Server _server;
  final int _taskId;

  Future<Map<String, dynamic>> processStep(
      {required String kind, required Map<String, dynamic> args}) async {
    _server.sendMessage(StepMessage(_taskId, kind: kind, args: args));
    final dataResponse = await _server.messagesStream
        .whereType<StepResponseMessage>()
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

  /// To perform task independent operationas such as asking client to refresh and provide new access token.
  Future<Map<String, dynamic>> processOperation({
    required String kind,
    required Map<String, dynamic> args,
  }) async {
    _server.sendMessage(OperationMessage(kind: kind, args: args));

    final dataResponse = await _server.messagesStream
        .whereType<OperationResponseMessage>()
        .where((event) => event.kind == kind)
        .first;
    return dataResponse.data;
  }
}
