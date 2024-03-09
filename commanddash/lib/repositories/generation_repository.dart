part 'generation_exceptions.dart';

//Can be implemented to provide generations.
abstract class GenerationRepository {
  Future<String> getCompletion(String message);
  Future<String> getChatCompletion(); // TODO: add proper params here
  // Generates embeddings for the given [code]. This should be using a tasktype of retrievalDocument.
  Future getCodeEmbeddings(String code);
  // Generates embeddings for the given [value]. This should be using a tasktype of retrievalQuery.
  Future getStringEmbeddings(String value);
}
