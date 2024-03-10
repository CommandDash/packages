import 'package:commanddash/repositories/client/dio_client.dart';
import 'package:commanddash/repositories/dash_repository.dart';
import 'package:commanddash/repositories/gemini_repository.dart';
import 'package:commanddash/server/messages.dart';
import 'package:commanddash/server/server.dart';
import 'package:commanddash/server/task_assist.dart';
import 'package:commanddash/steps/find_closest_files/embedding_generator.dart';
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
        case 'random_task_with_step':
          randomFunctionWithStep(taskAssist);
          break;
        case 'random_task_with_side_operation':
          randomFunctionWithSideOperation(taskAssist);
          break;
        case 'refresh_token_test':
          final client = getClient(
              message.data['auth']['github_access_token'],
              () async => taskAssist
                  .processOperation(kind: 'refresh_access_token', args: {}));
          DashRepository(client);

          ///Other repositories using the backend client
          ///Pass this to the agent.
          break;
        case 'find_closest_files':
          EmbeddingGenerator().findClosesResults(
            taskAssist,
            message.data['query'],
            message.data['workspacePath'],
            GeminiRepository(message.data['apiKey']),
          );
          break;
        default:
          taskAssist.sendErrorMessage(message: 'INVALID_TASK_KIND', data: {});
      }
    });
  }
}

/// Function for Integration Test of the step communication
Future<void> randomFunctionWithStep(TaskAssist taskAssist) async {
  final data = await taskAssist.processStep(kind: 'step_data_kind', args: {});
  if (data['value'] == 'unique_value') {
    taskAssist.sendResultMessage(message: 'TASK_COMPLETED', data: {});
  } else {
    taskAssist.sendErrorMessage(message: 'TASK_FAILED', data: {});
  }
}

/// Function for Integration Test of the side operation communication
Future<void> randomFunctionWithSideOperation(TaskAssist taskAssist) async {
  /// added these logs for debugging purposes on client
  taskAssist.sendLogMessage(
      message: 'operation_data_kind_request_received', data: {});

  final data =
      await taskAssist.processOperation(kind: 'operation_data_kind', args: {});
  taskAssist.sendLogMessage(
      message: 'operation_data_kind_received', data: data);
  taskAssist.sendResultMessage(message: 'TASK_COMPLETED', data: {});
}
