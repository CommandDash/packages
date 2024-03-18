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
  test('Refactor query as expected from IDE', () async {
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
            "value": "Add basic flutter implementaion "
          },
          {
            "id": "422243666",
            "type": "code_input",
            "value": {
              "filePath":
                  "/Users/keval/Desktop/dev/welltested/projects/dart_files/test_file.dart",
              "range": {
                "start": {"line": 1, "character": 0},
                "end": {"line": 11, "character": 0}
              },
              "content":
                  "void main(List<String> args) {\n  print(\"Hello, world!\");\n\n  int a = 5;\n  int b = 10;\n  int sum = a + b;\n  print(\"The sum of \$a and \$b is \$sum.\");\n\n  String name = \"GitHub Copilot\";\n  print(\"My name is \$name.\");\n}\n",
            },
          },
        ],
        "outputs": [
          {"id": "90611917", "type": "multi_code_output"},
          {"id": "436621806", "type": "default_output"},
        ],
        "steps": [
          {
            "type": "prompt_query",
            "query":
                "You are a Flutter/Dart assistant helping user modify code within their editor window.refrence: <90611917>\nRefactor the given code according to user instruction. User instruction <736841542>. \n Code: <90611917>",
            "post_process": {"type": "code"},
            "output": "436621806",
          },
          // replace in file
          {
            "type": "replace_in_file",
            "query": "<436621806>",
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
