import 'package:commanddash/repositories/gemini_repository.dart';
import 'package:commanddash/repositories/generation_repository.dart';
import 'package:test/test.dart';

void main() {
  setUp(() {});

  group('GeminiRepository', () {
    test('getEmbeddings With correct api Key', () async {
      final geminiRepository =
          GeminiRepository('AIzaSyDuPgJQG2Q43VFAZ6Xr-3_5NGIuAdVEMnQ');
      final testString = "The quick brown fox jumps over the lazy dog.";
      final result = await geminiRepository.getCodeEmbeddings(testString);

      expect(result.length, greaterThan(0));
    });

    test('getEmbeddings With incorrect api Key', () async {
      final geminiRepository = GeminiRepository('invalidApiKey');
      final testString = "The quick brown fox jumps over the lazy dog.";
      expect(() async => await geminiRepository.getCodeEmbeddings(testString),
          throwsA(isA<InvalidApiKeyException>()));
    });
  });
}
