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
        "inputs": [
          {
            "id": "736841542",
            "type": "string_input",
            "value": "Where is the themeing of the app?"
          }
        ],
        "outputs": [
          {"id": "436621806", "type": "default_output"},
          {"id": "90611917", "type": "default_output"}
        ],
        "steps": [
          {
            "type": "search_in_workspace",
            "query": "<422243666>",
            "workspace_object_type": "all",
            "workspacePath":
                "/Users/keval/Desktop/dev/welltested/projects/dart_files",
            "output": "436621806"
          },
          {
            "type": "prompt_query",
            "query":
                "Here are the related references from user's project:\n <436621806>. Answer the user's query. Query: <736841542>",
            "post_process": {"type": "raw"},
            "output": "90611917"
          }
        ]
      }
    }));

    final queue = StreamQueue<OutgoingMessage>(outwrapper.outputStream.stream);
    var result = await queue.next;
    expect(result, isA<StepMessage>());
    expect(result.id, 1);
    expect((result as StepMessage).kind, 'cache');
    expect(result.args, {});

    messageStreamController
        .add(StepResponseMessage(1, 'cache_response', data: {'value': '{}'}));

    result = await queue.next;

    expect(result, isA<ResultMessage>());
    expect(result.id, 1);
    expect((result as ResultMessage).message, 'TASK_COMPLETE');
    expect((result as ResultMessage).message, isNotEmpty);
    expect(result.data, {});
  });
}
