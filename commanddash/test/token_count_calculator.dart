import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:test/test.dart';

import 'test_utils.dart';

/// Helper test to fetch token counts of texts.
void main() {
  test('token count', () async {
    await EnvReader.load();
    final model = GenerativeModel(
        model: 'gemini-pro', apiKey: EnvReader.get('GEMINI_KEY') ?? '');
    final value = await model.countTokens([Content.text(text)]);
    print(value.totalTokens);
    print(text.length);
  });
}

const text = 'mock_text';
