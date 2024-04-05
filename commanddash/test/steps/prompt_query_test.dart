import 'dart:async';

import 'package:async/async.dart';
import 'package:commanddash/agent/output_model.dart';
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
  test('Process a prompt request with prompt query', () async {
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
            "value":
                "Where do you think AI is heading in the field of programming? Give a one line answer."
          }
        ],
        "registered_outputs": [
          {"id": "90611917", "type": "default_output"}
        ],
        "steps": [
          {
            "type": "prompt_query",
            "query": "<736841542>",
            "post_process": {"type": "raw"},
            "output": "90611917"
          },
        ]
      }
    }));

    final queue = StreamQueue<OutgoingMessage>(outwrapper.outputStream.stream);
    var result = await queue.next;
    expect(result, isA<StepMessage>());
    expect(result.id, 1);
    expect((result as StepMessage).kind, 'loader_update');
    expect(result.args['kind'], 'message');
    expect(result.args['message'], 'Preparing Result');
    messageStreamController
        .add(StepResponseMessage(1, 'loader_update', data: {}));
    result = await queue.next;
    expect(result, isA<ResultMessage>());
    expect(result.id, 1);
    expect((result as ResultMessage).message, 'TASK_COMPLETE');
    expect((result as ResultMessage).message, isNotEmpty);
    expect((result as ResultMessage).data.containsKey('90611917'), true);
    expect((result as ResultMessage).data['90611917'], isA<DefaultOutput>());
    expect(
        ((result as ResultMessage).data['90611917'] as DefaultOutput).value !=
            null,
        true);
    expect(
        ((result as ResultMessage).data['90611917'] as DefaultOutput)
            .value!
            .isNotEmpty,
        true);
  });

  test('Process a prompt request with code parser', () async {
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
            "value": "Give dart function to calculate factorial of a number."
          }
        ],
        "registered_outputs": [
          {"id": "90611917", "type": "default_output"}
        ],
        "steps": [
          {
            "type": "prompt_query",
            "query": "<736841542>",
            "post_process": {"type": "code"},
            "output": "90611917"
          },
        ]
      }
    }));

    final queue = StreamQueue<OutgoingMessage>(outwrapper.outputStream.stream);
    var result = await queue.next;
    expect(result, isA<StepMessage>());
    expect(result.id, 1);
    expect((result as StepMessage).kind, 'loader_update');
    expect(result.args['kind'], 'message');
    expect(result.args['message'], 'Preparing Result');
    messageStreamController
        .add(StepResponseMessage(1, 'loader_update', data: {}));
    result = await queue.next;
    expect(result, isA<ResultMessage>());
    expect(result.id, 1);
    expect((result as ResultMessage).message, 'TASK_COMPLETE');
    expect((result as ResultMessage).message, isNotEmpty);
    expect((result as ResultMessage).data.containsKey('90611917'), true);
    expect((result as ResultMessage).data['90611917'], isA<DefaultOutput>());
    expect(
        ((result as ResultMessage).data['90611917'] as DefaultOutput).value !=
            null,
        true);
    expect(
        ((result as ResultMessage).data['90611917'] as DefaultOutput)
            .value!
            .isNotEmpty,
        true);
  });
}
