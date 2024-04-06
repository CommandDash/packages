@Timeout(Duration(minutes: 3))
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
  test('Flutter agent', () async {
    handler.initProcessing();

    messageStreamController.add(
      IncomingMessage.fromJson(
        {
          "method": "agent-execute",
          "id": 1,
          "version": "1.0.0",
          'params': {
            "authdetails": {
              "type": "gemini",
              "key": EnvReader.get('GEMINI_KEY'),
              "githubToken": "authtoken",
            },
            "agent_name": "flutter",
            "slug": "/doc",
            "intent": "Your Flutter doc expert",
            "text_field_layout":
                "Hi, I'm here to help you with core flutter queries. Let me know your question: <14340369>",
            "registered_inputs": [
              {
                "id": "14340369",
                "display_text": "Your query",
                "type": "string_input",
                "value": "What is material.dart?"
              }
            ],
            "registered_outputs": [
              {
                "id": "897806645",
                "type": "match_document_output",
                "version": "0.0.1"
              },
              {
                "id": "81443790",
                "type": "prompt_output",
                "version": "0.0.1",
              }
            ],
            "steps": [
              {
                "type": "search_in_sources",
                "query": "<14340369>",
                "output": "897806645",
                "data_sources": ["816647033"],
              },
              {
                "type": "prompt_query",
                "query":
                    "You are an Flutter expert who answers user's queries related to the framework. \n\n Please find the user query <Query> and relavant references <References> picked from the Flutter docs to assist you: \n\n Query: <14340369>, \nReferences: <897806645>. Please respond to the user's query!",
                "output": "81443790",
              },
              {
                "type": "append_to_chat",
                "value": "<81443790>",
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
