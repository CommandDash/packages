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

    messageStreamController.add(
      IncomingMessage.fromJson(
        {
          "method": "agent-execute",
          "id": 1,
          'params': {
            "authdetails": {
              "type": "gemini",
              "key": EnvReader.get('GEMINI_KEY'),
              "githubToken": ""
            },
            "slug": "/refactor",
            "intent": "Ask me anything",
            "text_field_layout": "Refactor your code <736841542> <805088184>",
            "inputs": [
              {
                "id": "736841542",
                "display_text": "Your query",
                "type": "string_input",
                "value": "​Write comments in the following code"
              },
              {
                "id": "805088184",
                "display_text": "Code Attachment",
                "type": "code_input",
                "value":
                    "{\"filePath\":\"/Users/keval/Desktop/dev/welltested/projects/dart_files/test_file.dart\",\"referenceContent\":\"`lib/test/loading_dialog.dart`\\n```\\n  void _popDialog(final BuildContext context, final T? value) {\\n    if (_popEd) {\\n      return;\\n    }\\n    _popEd = true;\\n    // Here we use the root navigator so that we can pop dialog while using multiple navigators.\\n    Navigator.of(context, rootNavigator: true).pop(value);\\n  }\\n```\\n\",\"referenceData\":{\"selection\":{\"start\":{\"line\":112,\"character\":0},\"end\":{\"line\":119,\"character\":0}},\"editor\":\"file:///Users/fisclouds/Documents/smooth-app/packages/smooth_app/lib/test/loading_dialog.dart\"},\"startLineNumber\":112,\"endLineNumber\":119,\"fileName\":\"loading_dialog.dart\",\"chipId\":\"loading_dialog.dart:[112 - 119]\"}"
              }
            ],
            "outputs": [
              {"id": "90611917", "type": "multi_code_output"},
              {"id": "436621806", "type": "default_output"}
            ],
            "steps": [
              {
                "type": "prompt_query",
                "query":
                    "You are a Flutter/Dart assistant helping user modify code within their editor window.refrence: <90611917>\nRefactor the given code according to user instruction. User instruction <736841542>. \n Code: <90611917>",
                "post_process": {"type": "code"},
                "output": "436621806"
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

    messageStreamController
        .add(StepResponseMessage(1, 'replace_in_file', data: {'value': true}));

    result = await queue.next;

    expect(result, isA<ResultMessage>());
    expect(result.id, 1);
    expect((result as ResultMessage).message, 'TASK_COMPLETE');
    expect((result as ResultMessage).message, isNotEmpty);
    expect(result.data, {});
  });
}
