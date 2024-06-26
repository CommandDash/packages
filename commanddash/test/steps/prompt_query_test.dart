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
  test('Process a prompt request with prompt query', () async {
    handler.initProcessing();

    messageStreamController.add(IncomingMessage.fromJson({
      "method": "agent-execute",
      "id": 1,
      "params": {
        "agent_name": "",
        "agent_version": "1.0.0",
        "auth_details": {
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
          },
        ],
        "registered_outputs": [
          {"id": "90611917", "type": "default_output"}
        ],
        "steps": [
          {
            "type": "prompt_query",
            "prompt": "<736841542>. Extra info: <736841543>",
            "post_process": {"type": "raw"},
            "outputs": ["90611917"]
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
  });

  test('Process a prompt request with code parser', () async {
    handler.initProcessing();

    messageStreamController.add(IncomingMessage.fromJson({
      "method": "agent-execute",
      "id": 1,
      "params": {
        "agent_name": "",
        "agent_version": "1.0.0",
        "auth_details": {
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
            "prompt": "<736841542>",
            "post_process": {"type": "code"},
            "outputs": ["90611917"]
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
  });

  test(
    'Process a prompt request with nullable input',
    () async {
      handler.initProcessing();

      messageStreamController.add(IncomingMessage.fromJson({
        "method": "agent-execute",
        "id": 1,
        "params": {
          "agent_name": "",
          "agent_version": "1.0.0",
          "auth_details": {
            "type": "gemini",
            "key": EnvReader.get('GEMINI_KEY'),
            "githubToken": ""
          },
          "registered_inputs": [
            {
              "id": "736841542",
              "type": "string_input",
              "value": "Explain this code"
            },
            {
              "id": "736841543",
              "type": "string_input",
              // "value": null,
            }
          ],
          "registered_outputs": [
            {"id": "90611917", "type": "default_output"}
          ],
          "steps": [
            {
              "type": "prompt_query",
              "prompt": "<736841542>. Extra info: <736841543>",
              "post_process": {"type": "raw"},
              "outputs": ["90611917"]
            },
          ]
        }
      }));

      final queue =
          StreamQueue<OutgoingMessage>(outwrapper.outputStream.stream);
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
    },
  );
  test(
    'Process a prompt request with both prompt output and code output',
    () async {
      handler.initProcessing();

      messageStreamController.add(IncomingMessage.fromJson({
        "method": "agent-execute",
        "id": 1,
        "params": {
          "agent_name": "",
          "agent_version": "1.0.0",
          "auth_details": {
            "type": "gemini",
            "key": EnvReader.get('GEMINI_KEY'),
            "githubToken": ""
          },
          "registered_inputs": [
            {
              "id": "736841542",
              "type": "string_input",
              "value":
                  "Give a dart code function which takes integer and prints fibonacci for that number. Also explain the working after the code."
            },
            {
              "id": "736841543",
              "type": "string_input",
              "value": null,
            }
          ],
          "registered_outputs": [
            {"id": "90611917", "type": "prompt_output"},
            {"id": "90611918", "type": "code_object"},
          ],
          "steps": [
            {
              "type": "prompt_query",
              "prompt": "<736841542>. Extra info: <736841543>",
              "outputs": [
                "90611917",
                "90611918",
              ]
            },
          ]
        }
      }));

      final queue =
          StreamQueue<OutgoingMessage>(outwrapper.outputStream.stream);
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
    },
  );
}
