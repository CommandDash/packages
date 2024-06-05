@Timeout(Duration(minutes: 4))
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
  test('Flutter agent deault command', () async {
    handler.initProcessing();

    messageStreamController.add(
      IncomingMessage.fromJson(
        {
          "method": "agent-execute",
          "id": 1,
          'params': {
            "auth_details": {
              "type": "gemini",
              "key": EnvReader.get('GEMINI_KEY'),
              "github_token": EnvReader.get('github_access_key'),
            },
            "agent_name": "flutter",
            "agent_version": "1.0.0",
            "slug": "",
            "intent": "Your Flutter doc expert",
            "chat_mode": {
              "system_prompt":
                  "You are a Flutter expert. You are here to help with core flutter queries.",
              "data_sources": ["816647033"],
            },
            "registered_inputs": [
              {
                "id": "805088184",
                "display_text": "Code Attachment",
                "type": "code_input",
                "generate_full_string": true,
                "value":
                    "{\"filePath\":\"/Users/keval/Desktop/dev/welltested/projects/demo_app/lib/test_file.dart\",\"referenceContent\":\"void main(List<String> args) {\\n  print(\\\"Hello, world!\\\");\\n\\n  int a = 5;\\n  int b = 10;\\n  int sum = a + b;\\n  print(\\\"The sum of \$a and \$b is \$sum.\\\");\\n\\n  String name = \\\"John Doe\\\";\\n  print(\\\"My name is \$name.\\\");\\n}\",\"referenceData\":{\"selection\":{\"start\":{\"line\":2,\"character\":1},\"end\":{\"line\":10,\"character\":1}},\"editor\":\"file:///Users/fisclouds/Documents/smooth-app/packages/smooth_app/lib/test/loading_dialog.dart\"},\"startLineNumber\":112,\"endLineNumber\":119,\"fileName\":\"loading_dialog.dart\",\"generateFullString\":true}"
              },
              {
                "id": "736841543",
                "type": "chat_query_input",
                // "value":
                //     "[\n                      {\n                        \"role\": \"user\",\n                        \"message\":\n                            \"I am researching about AI in medical field.\"\n                      },\n                      {\n                        \"role\": \"agent\",\n                        \"message\": \"That is a good topic to research on.\"\n                      }\n                    ]"
                "value": [],
              },
            ],
            "last_message":
                "What does the Operations class do? Is there any class in the flutter framework already which can be used instead of writing this on own? <805088184>",
          }
        },
      ),
    );

    final queue = StreamQueue<OutgoingMessage>(outwrapper.outputStream.stream);
    var result = await queue.next;
    expect(result, isA<StepMessage>());
    expect(result.id, 1);
    expect((result as StepMessage).kind, 'loader_update');
    expect(result.args['kind'], 'message');
    expect(result.args['message'], 'Searching in sources');
    messageStreamController
        .add(StepResponseMessage(1, 'loader_update', data: {}));
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
    expect((result as StepMessage).kind, 'context');
    messageStreamController.add(StepResponseMessage(1, 'context', data: {
      "context": [
        {
          "filePath":
              "/Users/keval/Desktop/dev/welltested/projects/demo_app/lib/context_file.dart",
        }
      ],
    }));
    result = await queue.next;
    expect(result, isA<StepMessage>());
    expect(result.id, 1);
    expect((result as StepMessage).kind, 'prompt_update');
    messageStreamController
        .add(StepResponseMessage(1, 'prompt_update', data: {}));
    result = await queue.next;
    expect(result, isA<StepMessage>());
    expect(result.id, 1);
    expect((result as StepMessage).kind, 'loader_update');
    expect(result.args['kind'], 'processingFiles');
    expect(result.args['message']['value'], 'Preparing Result');
    messageStreamController
        .add(StepResponseMessage(1, 'loader_update', data: {}));
    // result = await queue.next;
    // expect(result, isA<StepMessage>());
    // expect(result.id, 1);
    // expect((result as StepMessage).kind, 'loader_update');
    // expect(result.args['kind'], 'message');
    // expect(result.args['message'], 'Preparing Result');
    // messageStreamController
    //     .add(StepResponseMessage(1, 'loader_update', data: {}));
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
    messageStreamController.add(
        StepResponseMessage(1, 'append_to_chat', data: {'result': 'success'}));
    result = await queue.next;
    expect(result, isA<ResultMessage>());
    expect(result.id, 1);
    expect((result as ResultMessage).message, 'TASK_COMPLETE');
  });
}
