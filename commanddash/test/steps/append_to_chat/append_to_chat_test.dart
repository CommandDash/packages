import 'package:commanddash/repositories/generation_repository.dart';
import 'package:commanddash/server/task_assist.dart';
import 'package:commanddash/steps/append_to_chat/append_to_chat_step.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import 'append_to_chat_test.mocks.dart';

@GenerateNiceMocks([MockSpec<TaskAssist>(), MockSpec<GenerationRepository>()])
void main() {
  group('AppendToChatStep', () {
    late AppendToChatStep step;
    late MockTaskAssist taskAssist;
    late MockGenerationRepository generationRepository;

    setUp(() {
      taskAssist = MockTaskAssist();
      generationRepository = MockGenerationRepository();
      step = AppendToChatStep(outputIds: ['output-id'], message: 'message');
    });

    test('constructor works correctly', () {
      expect(step.outputIds, ['output-id']);
      expect(step.message, 'message');
    });

    test('fromJson works correctly', () {
      final json = {
        'outputs': ['output-id'],
        'value': 'message',
      };
      final step = AppendToChatStep.fromJson(json, 'message');
      expect(step.outputIds,
          null); //Append to chat is not supposed to return any output
      expect(step.message, 'message');
    });

    test('run throws an exception if the response contains an error', () async {
      when(taskAssist.processStep(
              kind: 'append_to_chat',
              args: {'message': 'message'},
              timeoutKind: TimeoutKind.sync))
          .thenAnswer((_) async => {
                'error': {'message': 'error message'}
              });

      expectLater(() async => step.run(taskAssist, generationRepository),
          throwsA(isA<Exception>()));
      //TODO: add a way to check for error message.
    });

    test('run returns null if the response does not contain an error',
        () async {
      when(taskAssist.processStep(
              kind: 'append_to_chat',
              args: {'message': 'message'},
              timeoutKind: TimeoutKind.sync))
          .thenAnswer((_) async => {});

      expect(await step.run(taskAssist, generationRepository), isNull);
    });
  });
}
