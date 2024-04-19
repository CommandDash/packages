import 'package:commanddash/repositories/gemini_repository.dart';
import 'package:commanddash/repositories/generation_repository.dart';
import 'package:test/test.dart';

import '../test_utils.dart';

void main() {
  String? apiKey;
  setUp(() async {
    await EnvReader.load();
    apiKey = EnvReader.get('GEMINI_KEY');
    if (apiKey == null) {
      throw Exception("GEMINI_KEY key missing in env file.");
    }
  });

  group('GeminiRepository', () {
    test('getEmbeddings With correct api Key', () async {
      final geminiRepository = GeminiRepository(apiKey!);
      final testString = "The quick brown fox jumps over the lazy dog.";
      final result = await geminiRepository.getCodeEmbeddings(testString);

      expect(result.length, greaterThan(0));
    });

    //TODO: This test fails because the packge API doesn't handle this error correctly
    test('getEmbeddings With incorrect api Key', () async {
      final geminiRepository = GeminiRepository('invalidApiKey');
      final testString = "The quick brown fox jumps over the lazy dog.";
      expect(
          () async => await geminiRepository.getCodeEmbeddings(testString),
          throwsA(isA<
              UnknownException>())); // SDK gives format exception for incorrect key
    });

    test('getCodeBatchEmbeddings [custom api implementation]', () async {
      final geminiRepository = GeminiRepository(apiKey!);
      final result = await geminiRepository.getCodeBatchEmbeddings(
        ['Hello', 'World'],
      );
      expect(result, isA<List<List<double>>>());
    });
    test('getCodeBatchEmbeddings [custom api implementation] with wrong key',
        () async {
      final geminiRepository = GeminiRepository('AIzaSyCGXM9N6U9LkUoNou4KX-');
      expect(
          () async => await geminiRepository.getCodeBatchEmbeddings(
                ['Hello', 'World'],
              ),
          throwsA(isA<InvalidApiKeyException>()));
    });
    test('getStringBatchEmbeddings [custom api implementation]', () async {
      final geminiRepository = GeminiRepository(apiKey!);
      final result = await geminiRepository.getCodeBatchEmbeddings(
        ['Hello', 'World'],
      );
      expect(result, isA<List<List<double>>>());
    });
    test('getStringBatchEmbeddings [custom api implementation] with wrong key',
        () async {
      final geminiRepository = GeminiRepository('AIzaSyCGXM9N6U9LkUoNou4KX-');
      expect(
          () async => await geminiRepository.getCodeBatchEmbeddings(
                ['Hello', 'World'],
              ),
          throwsA(isA<InvalidApiKeyException>()));
    });
  });
}
