import 'package:commanddash/models/chat_message.dart';
import 'package:commanddash/repositories/generation_repository.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import '../steps/chat_test.mocks.dart';

@GenerateMocks([GenerationRepository])
void main() {
  group('chat request', () {
    late MockGenerationRepository mockGenerationRepository;

    setUp(() {
      mockGenerationRepository = MockGenerationRepository();
    });

    test('should get chat completion', () async {
      final messages = [
        ChatMessage(
          role: ChatRole.user,
          message: 'Hello',
        ),
      ];
      final lastMessage = 'Hello';
      when(mockGenerationRepository.getChatCompletion(messages, lastMessage))
          .thenAnswer((_) async => 'Hello, how are you?');
      final response = await mockGenerationRepository.getChatCompletion(
          messages, lastMessage);
      expect(response, 'Hello, how are you?');
      verify(mockGenerationRepository.getChatCompletion(messages, lastMessage))
          .called(1);
    });
  });
}
