import 'package:commanddash/models/chat_message.dart';
import 'package:commanddash/repositories/gemini_repository.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import '../embedding_generator_test.mocks.dart';

@GenerateMocks([GeminiRepository])
void main() {
  group('chat request', () {
    late MockGeminiRepository mockGeminiRepository;

    setUp(() {
      mockGeminiRepository = MockGeminiRepository();
    });

    test('should get chat completion', () async {
      final messages = [
        ChatMessage(role: ChatRole.user, message: 'Hello', data: {}),
      ];
      final lastMessage = 'Hello';
      when(mockGeminiRepository.getChatCompletion(messages, lastMessage))
          .thenAnswer((_) async => 'Hello, how are you?');
      final response =
          await mockGeminiRepository.getChatCompletion(messages, lastMessage);
      expect(response, 'Hello, how are you?');
      verify(mockGeminiRepository.getChatCompletion(messages, lastMessage))
          .called(1);
    });
  });
}
