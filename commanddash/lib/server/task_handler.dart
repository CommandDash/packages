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
        case 'random_task':
          someRandomFunction(taskAssist);
          break;
        default:
          taskAssist.sendErrorMessage(message: 'INVALID_TASK_KIND', data: {});
      }
    });
  }
}

Future<void> someRandomFunction(TaskAssist taskAssist) async {
  final data = await taskAssist.processStep(kind: 'random_data_kind', args: {});
  if (data['value'] == 'unique_value') {
    taskAssist.sendResultMessage(message: 'TASK_COMPLETED', data: {});
  } else {
    taskAssist.sendErrorMessage(message: 'TASK_FAILED', data: {});
  }
}
