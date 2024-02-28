import 'package:commanddash/server/messages.dart';
import 'package:commanddash/server/server.dart';
import 'package:rxdart/rxdart.dart';

class TaskAssist {
  TaskAssist(this._server, this._taskId);
  final Server _server;
  final String _taskId;

  Future<Map<String, dynamic>> getAdditionalData(
      GetAdditionalDataMessage message) async {
    _server.sendMessage(message);
    final dataResponse = await _server.messagesStream
        .whereType<AdditionalDataMessage>()
        .where((event) => event.id == _taskId)
        .first;
    return dataResponse.data;
  }

  void sendCompletionMessage(OutgoingMessage message) {
    assert(message is SuccessMessage || message is ErrorMessage,
        'Completion can only be marked with success or error');
    _server.sendMessage(message);
  }
}
