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
  test('Process a prompt request with append to chat', () async {
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
            "value":
                "Where do you think AI is heading in the field of programming? Give a short answer."
          }
        ],
        "outputs": [
          {"id": "90611917", "type": "default_output"}
        ],
        "steps": [
          {
            "type": "prompt_query",
            "query": "736841542",
            "post_process": {"type": "raw"},
            "output": "90611917"
          },
          {
            "type": "append_to_chat",
            "message": "<90611917>",
            "post_process": {"type": "raw"},
          }
        ]
      }
    }));

    final queue = StreamQueue<OutgoingMessage>(outwrapper.outputStream.stream);
    var result = await queue.next;
    expect(result, isA<StepMessage>());
    expect(result.id, 1);
    expect((result as StepMessage).kind, 'append_to_chat');
    expect(result.args.containsKey('message'), true);
    expect(result.args['message'], isA<String>());
    print(result);
    messageStreamController
        .add(StepResponseMessage(1, 'append_to_chat', data: {'result': true}));
    result = await queue.next;
    expect(result, isA<ResultMessage>());
    expect(result.id, 1);
    expect((result as ResultMessage).message, 'TASK_COMPLETE');
    expect(result.data['outputs']['type'], 'OutputType.defaultOutput');
    expect(result.data['outputs']['value'], isA<String>());
  }, timeout: Timeout(Duration(seconds: 100)));
}
