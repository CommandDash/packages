import 'dart:async';

import 'package:async/async.dart';
import 'package:commanddash/server/messages.dart';
import 'package:commanddash/server/operation_message.dart';
import 'package:commanddash/server/server.dart';
import 'package:commanddash/server/task_assist.dart';
import 'package:commanddash/server/task_handler.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import '../test_utils.dart';
import 'task_assist_test.mocks.dart';

@GenerateMocks([Server])
void main() {
  group('TaskAssist', () {
    late Server server;
    late TaskAssist taskAssist;
    late StreamController<IncomingMessage> messageStreamController;
    setUp(() {
      server = MockServer();
      taskAssist = TaskAssist(server, 1);
      messageStreamController = StreamController.broadcast();
      when(server.messagesStream)
          .thenAnswer((_) => messageStreamController.stream);
    });

    test(
        'processOperation() closes succesfully when the correct response is receieved',
        () async {
      final operationMessage = OperationMessage(kind: 'test', args: {});

      Completer completer = Completer();
      completer.future.timeout(Duration(milliseconds: 10));
      // Run the fetch from client
      taskAssist.processOperation(kind: 'test', args: {}).then((value) {
        completer.complete(value);
      });
      messageStreamController
          .add(OperationResponseMessage('test', data: {'value': true}));

      await expectLater(
          await completer.future.timeout(Duration(milliseconds: 10)),
          {'value': true});
      verify(server.sendMessage(operationMessage));
    }, timeout: Timeout(Duration(milliseconds: 100)));
    test(
      'processOperation() doesn`t close when an incorrect response is receieved',
      () async {
        final operationMessage = OperationMessage(kind: 'test', args: {});

        Completer completer = Completer();

        // Run the fetch from client
        taskAssist.processOperation(kind: 'test', args: {}).then((value) {
          // Verify and expect
          verify(server.sendMessage(operationMessage));
          expect(value, {'value': true});
          completer.complete();
        });
        messageStreamController
            .add(OperationResponseMessage('other_test', data: {'value': true}));
        // Use expectLater with the async matcher completes
        await expectLater(
          completer.future.timeout(Duration(milliseconds: 10)),
          throwsA(isA<TimeoutException>()),
        );
      },
    );
  }, timeout: Timeout(Duration(milliseconds: 100)));

  group('Task Assist E2E Tests', () {
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
        IncomingMessage.fromJson({
          "method": "task_start",
          "params": {
            "kind": "random_task_with_side_operation",
            "data": <String, dynamic>{}
          },
          "id": 1
        }),
      );

      final queue =
          StreamQueue<OutgoingMessage>(outwrapper.outputStream.stream);
      var result = await queue.next;
      expect(result, isA<OperationMessage>());
      expect(result.id, -1);
      expect((result as OperationMessage).kind, 'operation_data_kind');

      messageStreamController.add(IncomingMessage.fromJson({
        "method": "operation_response",
        "kind": "operation_data_kind",
        "data": {"result": "success", "value": "unique_value"}
      }));
      result = await queue.next;
      expect(result, isA<LogMessage>());
      expect((result as LogMessage).message, 'response received');
      result = await queue.next;
      expect(result, isA<ResultMessage>());
      expect(result.id, 1);
    });
  });
}
