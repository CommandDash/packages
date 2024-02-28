import 'package:commanddash/server/messages.dart';
import 'package:commanddash/server/server.dart';
import 'package:commanddash/server/task_assist.dart';
import 'package:rxdart/rxdart.dart';

class TaskHandler {
  TaskHandler(this._server);
  final Server _server;
  void initProcessing() {
    _server.messagesStream
        .whereType<TaskStartMessage>()
        .listen((TaskStartMessage message) {
      final taskAssist = TaskAssist(_server, message.id);
      switch (message.taskKind) {
        case 'randomTask':
          taskAssist.sendCompletionMessage(
              SuccessMessage(message.id, message: 'TASK_COMPLETED', data: {}));
          break;
        default:
          taskAssist.sendCompletionMessage(
              ErrorMessage(message.id, message: 'INVALID_TASK_KIND', data: {}));
      }
    });
  }
}
