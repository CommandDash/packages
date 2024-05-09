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

  group('chat request', () {
    test('first chat from user', () async {
      handler.initProcessing();
      messageStreamController.add(
        IncomingMessage.fromJson(
          {
            "method": "chat-request",
            "id": 1,
            "params": {
              "agent_name": "",
              "agent_version": "1.0.0",
              "auth_details": {
                "type": "gemini",
                "key": EnvReader.get('GEMINI_KEY'),
                "githubToken": ""
              },
              "messages": [
                {
                  "role": "user",
                  "parts":
                      "Hey How to make a loading indicator in flutter?\n filePath1\n ```code1```\n",
                  "data": {
                    "id1": {
                      "filePath": "filePath1",
                      "content": "code1",
                    },
                  },
                },
                {
                  "role": "model",
                  "parts": "Hey How to make a loading indicator in flutter?",
                },
                {
                  "role": "user",
                  "parts":
                      "Hey How to make a loading indicator in flutter?\n filePath1\n ```code1```\n",
                  "data": {
                    "id2": {
                      "filePath": "filePath1",
                      "content": "code1",
                    },
                  },
                },
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
      expect(result.args['kind'], 'circular');
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
  });
}
