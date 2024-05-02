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

  group(
    'chat request',
    () {
      test('first chat from user', () async {
        handler.initProcessing();
        messageStreamController.add(
          IncomingMessage.fromJson(
            {
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
                  {"id": "736841542", "type": "string_input", "value": "Hello"},
                  // {
                  //   "id": "736841543",
                  //   "type": "chat_query_input",
                  //   "value": [
                  //     {
                  //       'role': 'user',
                  //       'message': 'Hello',
                  //     },
                  //   ],
                  // }
                ],
                "registered_outputs": [
                  {"id": "90611917", "type": "default_output"}
                ],
                "steps": [
                  {
                    "type": "chat",
                    "query": "<736841542>",
                    // "messages": "736841543",
                    "outputs": ["90611917"],
                  },
                  {
                    "type": "append_to_chat",
                    "value": "<90611917>",
                    "post_process": {"type": "raw"},
                  }
                ]
              }
            },
          ),
        );

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
        expect(result, isA<StepMessage>());
        expect(result.id, 1);
        expect((result as StepMessage).kind, 'loader_update');
        expect(result.args['kind'], 'none');
        expect(result.args.containsKey('message'), false);
        messageStreamController
            .add(StepResponseMessage(1, 'loader_update', data: {}));
        result = await queue.next;
        expect(result, isA<StepMessage>());
        expect(result.id, 1);
        expect((result as StepMessage).kind, 'append_to_chat');
        expect(result.args.containsKey('message'), true);
        expect(result.args['message'], isA<String>());
        messageStreamController.add(StepResponseMessage(1, 'append_to_chat',
            data: {'result': 'success'}));
        result = await queue.next;
        expect(result, isA<ResultMessage>());
        expect(result.id, 1);
        expect((result as ResultMessage).message, 'TASK_COMPLETE');
      }, timeout: Timeout(Duration(minutes: 1)));

      test('chat with history', () async {
        handler.initProcessing();
        messageStreamController.add(
          IncomingMessage.fromJson(
            {
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
                        "Where do you think AI is heading in the field? Give a short answer."
                  },
                  {
                    "id": "736841543",
                    "type": "chat_query_input",
                    "value":
                        "[\n                      {\n                        \"role\": \"user\",\n                        \"message\":\n                            \"I am researching about AI in medical field.\"\n                      },\n                      {\n                        \"role\": \"agent\",\n                        \"message\": \"That is a good topic to research on.\"\n                      }\n                    ]"
                  }
                ],
                "registered_outputs": [
                  {"id": "90611917", "type": "default_output"}
                ],
                "steps": [
                  {
                    "type": "chat",
                    "query": "<736841542>",
                    "messages": "<736841543>",
                    "outputs": ["90611917"],
                  },
                  {
                    "type": "append_to_chat",
                    "value": "<90611917>",
                    "post_process": {"type": "raw"},
                  }
                ]
              }
            },
          ),
        );

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
        expect(result, isA<StepMessage>());
        expect(result.id, 1);
        expect((result as StepMessage).kind, 'loader_update');
        expect(result.args['kind'], 'none');
        expect(result.args.containsKey('message'), false);
        messageStreamController
            .add(StepResponseMessage(1, 'loader_update', data: {}));
        result = await queue.next;
        expect(result, isA<StepMessage>());
        expect(result.id, 1);
        expect((result as StepMessage).kind, 'append_to_chat');
        expect(result.args.containsKey('message'), true);
        expect(result.args['message'], isA<String>());
        messageStreamController.add(StepResponseMessage(1, 'append_to_chat',
            data: {'result': 'success'}));
        result = await queue.next;
        expect(result, isA<ResultMessage>());
        expect(result.id, 1);
        expect((result as ResultMessage).message, 'TASK_COMPLETE');
      });
    },
  );
}
