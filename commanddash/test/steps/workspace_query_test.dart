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
  test('Process a search_in_workspace followed by a prompt_query request',
      () async {
    handler.initProcessing();

    messageStreamController.add(IncomingMessage.fromJson({
      "method": "agent-execute",
      "id": 1,
      "params": {
        "authdetails": {
          "type": "gemini",
          "key": EnvReader.get('GEMINI_KEY'),
          "githubToken": ""
        },
        "registered_inputs": [
          {
            "id": "736841542",
            "type": "string_input",
            "value": "Where is the themeing of the app?"
          },
          {
            "id": "736841543",
            "display_text": "Extra info",
            "type": "string_input",
            "optional": true
          },
        ],
        "registered_outputs": [
          {"id": "436621806", "type": "default_output"},
          {"id": "90611917", "type": "default_output"}
        ],
        "steps": [
          {
            "type": "search_in_workspace",
            "query": "<422243666>",
            "workspace_object_type": "all",
            "outputs": ["436621806"]
          },
          {
            "type": "prompt_query",
            "prompt":
                "Here are the related references from user's project:\n <436621806>. Answer the user's query. Query: <736841542>",
            "post_process": {"type": "raw"},
            "outputs": ["90611917"]
          },
          {
            "type": "append_to_chat",
            "value": "<90611917>",
            "post_process": {"type": "raw"},
          }
        ]
      }
    }));

    final queue = StreamQueue<OutgoingMessage>(outwrapper.outputStream.stream);
    var result = await queue.next;
    expect(result, isA<StepMessage>());
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
    expect(result, isA<StepMessage>());
    expect(result.id, 1);
    expect((result as StepMessage).kind, 'loader_update');
    expect(result.args['kind'], 'message');
    expect(result.args['message'], 'Preparing Result');
    messageStreamController
        .add(StepResponseMessage(1, 'loader_update', data: {}));
    result = await queue.next;
    expect(result, isA<StepMessage>());
    expect(result.id, 1);
    expect((result as StepMessage).kind, 'loader_update');
    expect(result.args['kind'], 'none');
    messageStreamController
        .add(StepResponseMessage(1, 'loader_update', data: {}));
    result = await queue.next;
    expect(result, isA<StepMessage>());
    expect(result.id, 1);
    expect((result as StepMessage).kind, 'append_to_chat');
    expect(result.args.containsKey('message'), true);
    expect(result.args['message'], isA<String>());
    messageStreamController.add(
        StepResponseMessage(1, 'append_to_chat', data: {'result': 'success'}));
    result = await queue.next;
    expect(result, isA<ResultMessage>());
    expect(result.id, 1);
    expect((result as ResultMessage).message, 'TASK_COMPLETE');
    expect((result as ResultMessage).message, isNotEmpty);
  }, timeout: Timeout(Duration(minutes: 3)));
}
