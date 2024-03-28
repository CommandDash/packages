import 'dart:async';

import 'package:commanddash/server/messages.dart';
import 'package:commanddash/server/operation_message.dart';
import 'package:commanddash/server/server.dart';
import 'package:commanddash/server/task_assist.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

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
}
