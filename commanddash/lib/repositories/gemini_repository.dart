import 'package:commanddash/repositories/generation_repository.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiRepository implements GenerationRepository {
  final String apiKey;
  GeminiRepository(this.apiKey);
  @override
  Future<String> getCompletion(
    String messages,
  ) async {
    // For text-only input, use the gemini-pro model
    final model = GenerativeModel(model: 'gemini-pro', apiKey: apiKey);
    final content = [Content.text('Write a story about a magic backpack.')];
    final response = await model.generateContent(content);
    if (response.text != null) {
      return response.text!;
    } else {
      throw ModelException("No response recieved from gemini");
    }
  }

  @override
  Future<List<double>> getCodeEmbeddings(String value) async {
    try {
      final model = GenerativeModel(model: 'embedding-001', apiKey: apiKey);
      final content = Content.text(value);
      final result = await model.embedContent(
        content,
        taskType: TaskType.retrievalDocument,
      );
      return result.embedding.values;
    } on InvalidApiKey catch (e) {
      throw InvalidApiKeyException();
    } on ServerException catch (e) {
      throw ModelException(e.message);
    } on UnsupportedUserLocation catch (e) {
      throw ModelException(e.message);
    }
  }

  @override
  Future<List<double>> getStringEmbeddings(String value) async {
    try {
      final model = GenerativeModel(model: 'embedding-001', apiKey: apiKey);
      final content = Content.text(value);
      final result = await model.embedContent(
        content,
        taskType: TaskType.retrievalQuery,
      );
      return result.embedding.values;
    } on InvalidApiKey catch (e) {
      throw InvalidApiKeyException();
    } on ServerException catch (e) {
      throw ModelException(e.message);
    } on UnsupportedUserLocation catch (e) {
      throw ModelException(e.message);
    }
  }

  @override
  Future<String> getChatCompletion() {
    // TODO: implement getChatCompletion
    throw UnimplementedError();
  }
}
