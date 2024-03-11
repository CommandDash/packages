import 'package:commanddash/agent/agent_handler.dart';
import 'package:commanddash/steps/find_closest_files/embedding_generator.dart';
import 'package:commanddash/repositories/gemini_repository.dart';
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
        case 'agent-execute':
          final handler = AgentHandler.fromJson(message.data);
          handler.runTask(taskAssist);
          break;
        // case 'find_closest_files':
        //   EmbeddingGenerator().findClosesResults(
        //     taskAssist,
        //     message.data['query'],
        //     message.data['workspacePath'],
        //     GeminiRepository(message.data['apiKey']),
        //   );
        // break;
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
