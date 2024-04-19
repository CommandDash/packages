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
  test('Refactor query as expected from IDE', () async {
    handler.initProcessing();

    messageStreamController.add(
      IncomingMessage.fromJson(
        {
          "method": "agent-execute",
          "id": 1,
          'params': {
            "agent_name": "",
            "agent_version": "1.0.0",
            "authdetails": {
              "type": "gemini",
              "key": EnvReader.get('GEMINI_KEY'),
              "githubToken": ""
            },
            "slug": "/refactor",
            "intent": "Ask me anything",
            "text_field_layout":
                "\nRemove print statements and give better name for variables<736841542>",
            "registered_inputs": [
              {
                "id": "736841542",
                "display_text": "Your query",
                "type": "string_input",
                "value": "Remove comments"
              },
              {
                "id": "805088184",
                "display_text": "Code Attachment",
                "type": "code_input",
                "generate_full_string": true,
                "value":
                    "{\"filePath\":\"/Users/keval/Desktop/dev/welltested/projects/dart_files/test_file.dart\",\"referenceContent\":\"void main(List<String> args) {\\n  print(\\\"Hello, world!\\\");\\n\\n  int a = 5;\\n  int b = 10;\\n  int sum = a + b;\\n  print(\\\"The sum of \$a and \$b is \$sum.\\\");\\n\\n  String name = \\\"John Doe\\\";\\n  print(\\\"My name is \$name.\\\");\\n}\",\"referenceData\":{\"selection\":{\"start\":{\"line\":2,\"character\":1},\"end\":{\"line\":10,\"character\":1}},\"editor\":\"file:///Users/fisclouds/Documents/smooth-app/packages/smooth_app/lib/test/loading_dialog.dart\"},\"startLineNumber\":112,\"endLineNumber\":119,\"fileName\":\"loading_dialog.dart\",\"generateFullString\":true}"
              }
            ],
            "registered_outputs": [
              {"id": "436621806", "type": "default_output"}
            ],
            "steps": [
              {
                "type": "prompt_query",
                "prompt":
                    "You are a Flutter/Dart assistant helping user modify code within their editor window.\nRefactor the given code according to user instruction. User instruction <736841542>. \n Code: <805088184>" +
                        '''Proceed step by step:
            1. Describe the selected piece of code.
            2. What are the possible optimizations?
            3. How do you plan to achieve that ? [Don't output code yet]
            4. Output the modified code to be be programatically replaced in the editor in place of the CURSOR_SELECTION.Since this is without human review, you need to output the precise CURSOR_SELECTION''',
                "post_process": {"type": "code"},
                "outputs": ["436621806"]
              },
              {
                "type": "replace_in_file",
                "query": "<436621806>",
                "replaceInFile": "805088184",
                "continue_if_declined": true,
              }
            ]
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
    expect((result as StepMessage).kind, 'replace_in_file');
    expect((result).args.containsKey('file'), true);
    expect((result).args['file']['originalCode'], isNotEmpty);
    expect((result).args['file']['optimizedCode'], isNotEmpty);
    print(result.args['file']['originalCode']);
    print(result.args['file']['optimizedCode']);

    messageStreamController
        .add(StepResponseMessage(1, 'replace_in_file', data: {'value': true}));

    result = await queue.next;

    expect(result, isA<ResultMessage>());
    expect(result.id, 1);
    expect((result as ResultMessage).message, 'TASK_COMPLETE');
  });
}
