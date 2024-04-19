import 'dart:async';

import 'package:async/async.dart';
import 'package:commanddash/server/messages.dart';
import 'package:commanddash/server/server.dart';
import 'package:commanddash/server/task_handler.dart';
import 'package:test/test.dart';

import '../test_utils.dart';

void main() {
  late Server server;
  late TaskHandler handler;
  late StreamController<IncomingMessage> messageStreamController;
  late TestOutWrapper outwrapper;

  setUp(() async {
    await EnvReader.load();
    server = Server();
    messageStreamController = StreamController.broadcast();
    outwrapper = TestOutWrapper();
    server.replaceMessageStreamController(messageStreamController);
    server.stdout = outwrapper;
    handler = TaskHandler(server);
  });

  test('Processing search_in_workspace executes successfully', () async {
    handler.initProcessing();

    messageStreamController.add(IncomingMessage.fromJson({
      "method": "agent-execute",
      "id": 1,
      "params": {
        "auth_details": {
          "type": "gemini",
          "key": EnvReader.get('GEMINI_KEY'),
          "githubToken": ""
        },
        "registered_inputs": [
          {
            "id": "736841542",
            "type": "string_input",
            "value": "Where is the themeing of the app?"
          }
        ],
        "registered_outputs": [
          {"id": "436621806", "type": "default_output"}
        ],
        "steps": [
          {
            "type": "search_in_workspace",
            "query": "<422243666>",
            "workspace_object_type": "all",
            "outputs": ["436621806"]
          }
        ]
      }
    }));

    final queue = StreamQueue<OutgoingMessage>(outwrapper.outputStream.stream);
    var result = await queue.next;
    expect(result.id, 1);
    expect((result as StepMessage).kind, 'loader_update');
    expect(result.args['kind'], 'message');
    expect(result.args['message'], 'Finding relevant files');
    messageStreamController
        .add(StepResponseMessage(1, 'loader_update', data: {}));
    result = await queue.next;
    expect(result, isA<StepMessage>());
    expect(result.id, 1);
    expect((result as StepMessage).kind, 'workspace_details');
    expect(result.args, {});
    messageStreamController.add(StepResponseMessage(1, 'workspace_details',
        data: {'path': EnvReader.get('OPEN_WORKSPACE_PATH')}));

    result = await queue.next;
    expect(result, isA<StepMessage>());
    expect(result.id, 1);
    expect((result as StepMessage).kind, 'cache');
    expect(result.args, {});

    messageStreamController
        .add(StepResponseMessage(1, 'cache', data: {'value': '{}'}));

    result = await queue.next;
    expect(result, isA<ResultMessage>());
    expect(result.id, 1);
    expect((result as ResultMessage).message, 'TASK_COMPLETE');
    expect((result).message, isNotEmpty);
  });

  test(
      'Processing search_in_workspace gives no workspace found error if workspace path is provided null from client',
      () async {
    handler.initProcessing();

    messageStreamController.add(IncomingMessage.fromJson({
      "method": "agent-execute",
      "id": 1,
      "params": {
        "auth_details": {
          "type": "gemini",
          "key": EnvReader.get('GEMINI_KEY'),
          "githubToken": ""
        },
        "registered_inputs": [
          {
            "id": "736841542",
            "type": "string_input",
            "value": "Where is the themeing of the app?"
          }
        ],
        "registered_outputs": [
          {"id": "436621806", "type": "default_output"}
        ],
        "steps": [
          {
            "type": "search_in_workspace",
            "query": "<422243666>",
            "workspace_object_type": "all",
            "outputs": ["436621806"]
          }
        ]
      }
    }));

    final queue = StreamQueue<OutgoingMessage>(outwrapper.outputStream.stream);
    var result = await queue.next;
    expect(result.id, 1);
    expect((result as StepMessage).kind, 'loader_update');
    expect(result.args['kind'], 'message');
    expect(result.args['message'], 'Finding relevant files');
    messageStreamController
        .add(StepResponseMessage(1, 'loader_update', data: {}));
    result = await queue.next;
    expect(result, isA<StepMessage>());
    expect(result.id, 1);
    expect((result as StepMessage).kind, 'workspace_details');
    expect(result.args, {});
    messageStreamController
        .add(StepResponseMessage(1, 'workspace_details', data: {'path': null}));

    result = await queue.next;
    expect(result, isA<ErrorMessage>());
    expect(result.id, 1);
    expect((result as ErrorMessage).message, 'No open workspace found');
    expect(result.data, {'stack_trace': null});

    try {
      result = await queue.next.timeout(Duration(seconds: 1));
      throw Exception('More events found when the stream was supposed to end');
    } catch (_) {}
  });

  test(
      'Processing search_in_workspace gives no workspace found error if workspace path is provided empty from client',
      () async {
    handler.initProcessing();

    messageStreamController.add(IncomingMessage.fromJson({
      "method": "agent-execute",
      "id": 1,
      "params": {
        "auth_details": {
          "type": "gemini",
          "key": EnvReader.get('GEMINI_KEY'),
          "githubToken": ""
        },
        "registered_inputs": [
          {
            "id": "736841542",
            "type": "string_input",
            "value": "Where is the themeing of the app?"
          }
        ],
        "registered_outputs": [
          {"id": "436621806", "type": "default_output"}
        ],
        "steps": [
          {
            "type": "search_in_workspace",
            "query": "<422243666>",
            "workspace_object_type": "all",
            "outputs": ["436621806"]
          }
        ]
      }
    }));

    final queue = StreamQueue<OutgoingMessage>(outwrapper.outputStream.stream);
    var result = await queue.next;
    expect(result.id, 1);
    expect((result as StepMessage).kind, 'loader_update');
    expect(result.args['kind'], 'message');
    expect(result.args['message'], 'Finding relevant files');
    messageStreamController
        .add(StepResponseMessage(1, 'loader_update', data: {}));
    result = await queue.next;
    expect(result, isA<StepMessage>());
    expect(result.id, 1);
    expect((result as StepMessage).kind, 'workspace_details');
    expect(result.args, {});
    messageStreamController
        .add(StepResponseMessage(1, 'workspace_details', data: {'path': ''}));

    result = await queue.next;
    expect(result, isA<ErrorMessage>());
    expect(result.id, 1);
    expect((result as ErrorMessage).message, 'No open workspace found');
    expect(result.data, {'stack_trace': null});

    try {
      result = await queue.next.timeout(Duration(seconds: 1));
      throw Exception('More events found when the stream was supposed to end');
    } catch (_) {}
  });
}
