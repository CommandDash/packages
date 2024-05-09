import 'package:commanddash/agent/agent_handler.dart';
import 'package:commanddash/chat/chat_handler.dart';
import 'package:commanddash/repositories/client/dio_client.dart';
import 'package:commanddash/repositories/dash_repository.dart';
import 'package:commanddash/server/messages.dart';
import 'package:commanddash/server/server.dart';
import 'package:commanddash/server/task_assist.dart';
import 'package:commanddash/steps/chat/chat_step.dart';
import 'package:rxdart/rxdart.dart';

class TaskHandler {
  TaskHandler(this._server);
  final Server _server;

  void initProcessing() {
    _server.messagesStream
        .whereType<TaskStartMessage>()
        .listen((message) => _processMessage(message));
  }

  void _processMessage(TaskStartMessage message) async {
    final taskAssist = TaskAssist(_server, message.id);

    try {
      switch (message.taskKind) {
        case 'random_task_global_error':
          throw Exception('Some unhandled exception not tracked to a task.');
        case 'random_task_with_step':
          await randomFunctionWithStep(taskAssist);
          break;
        case 'random_task_with_side_operation':
          await randomFunctionWithSideOperation(taskAssist);
          break;
        case 'get-agents':
          final client = getClient(
              message.data['auth']['github_access_token'],
              () async => taskAssist.processOperation(
                    kind: 'refresh_access_token',
                    args: {},
                  ));
          final repo = DashRepository(client);
          final agents = await repo.getAgents();
          taskAssist.sendResultMessage(
            message: "Agent get successful",
            data: {"agents": agents},
          );
          break;
        case 'refresh_token_test':
          final client = getClient(
              message.data['auth']['github_access_token'],
              () async => taskAssist.processOperation(
                    kind: 'refresh_access_token',
                    args: {},
                  ));
          DashRepository(client);

          /// Other repositories using the backend client
          /// Pass this to the agent.
          break;
        case 'agent-execute':
          final handler = AgentHandler.fromJson(message.data);
          await handler.runTask(taskAssist);
          break;
        case 'chat-request':
          final handler = ChatHandler.fromJson(message.data);
          handler.run(taskAssist);
          break;
        default:
          taskAssist.sendErrorMessage(message: 'INVALID_TASK_KIND', data: {});
      }
    } catch (e, stackTrace) {
      taskAssist.sendErrorMessage(
          message: 'Error processing request: ${e.toString()}',
          data: {},
          stackTrace: stackTrace);
    }
  }
}

/// Function for Integration Test of the step communication
Future<void> randomFunctionWithStep(TaskAssist taskAssist) async {
  final data = await taskAssist.processStep(
      kind: 'step_data_kind', args: {}, timeoutKind: TimeoutKind.sync);
  if (data['value'] == 'unique_value') {
    taskAssist.sendResultMessage(message: 'TASK_COMPLETED', data: {});
  } else {
    taskAssist.sendErrorMessage(
      message: 'TASK_FAILED',
      data: {},
    );
  }
}

/// Function for Integration Test of the side operation communication
Future<void> randomFunctionWithSideOperation(TaskAssist taskAssist) async {
  await taskAssist.processOperation(
      kind: 'operation_data_kind', args: {}, timeoutKind: TimeoutKind.sync);
  taskAssist.sendLogMessage(message: 'response received', data: {});
  taskAssist
      .sendResultMessage(message: 'TASK_COMPLETED', data: {'success': true});
}
