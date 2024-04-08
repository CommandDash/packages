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
          },
        ],
        "registered_outputs": [
          {"id": "90611917", "type": "default_output"}
        ],
        "steps": [
          {
            "type": "prompt_query",
            "query": "<736841542>. Extra info: <736841543>",
            "post_process": {"type": "raw"},
            "outputs": ["90611917"]
          },
          // {
          //   "code_output": "null",
          //   "output": "90611917",
          //   "prompt":
          //       "You are an Flutter expert who answers user's queries related to the framework. \n\n Please find the user query <Query> and relavant references <References> picked from the Flutter docs to assist you: \n\n Query: <14340369>, \nReferences: <897806645>. Please respond to the user's query!",
          //   "prompt_output": "90611917",
          //   "type": "prompt_query",
          //   "version": "0.0.1"
          // },
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

  test('Process a prompt request with nullable input', () async {
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
          },
          {
            "id": "736841543",
            "type": "string_input",
            "value": null,
          }
        ],
        "registered_outputs": [
          {"id": "90611917", "type": "default_output"}
        ],
        "steps": [
          {
            "type": "prompt_query",
            "query": "<736841542>. Extra info: <736841543>",
            "post_process": {"type": "raw"},
            "output": "90611917"
          },
          // {
          //   "code_output": "null",
          //   "output": "90611917",
          //   "prompt": "<736841542>",
          //   "prompt_output": "<81443790>",
          //   "type": "prompt_query",
          //   "version": "0.0.1"
          // },
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
