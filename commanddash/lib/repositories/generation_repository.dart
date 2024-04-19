import 'package:commanddash/models/chat_message.dart';
import 'package:commanddash/repositories/gemini_repository.dart';

part 'generation_exceptions.dart';

//Can be implemented to provide generations.
abstract class GenerationRepository {
  Future<String> getCompletion(String message);
  Future<String> getChatCompletion(
      List<ChatMessage> messages, String lastMessage);
  // Generates embeddings for the given [code]. This should be using a tasktype of retrievalDocument.
  Future getCodeEmbeddings(String code);
  Future<List<List<double>>> getCodeBatchEmbeddings(
      List<Map<String, dynamic>> code);
  // Generates embeddings for the given [value]. This should be using a tasktype of retrievalQuery.
  Future getStringEmbeddings(String value);
  Future<List<List<double>>> getStringBatchEmbeddings(List<String> value);

  factory GenerationRepository.fromJson(Map<String, dynamic> json) {
    final type = json['type'];
    if (type == 'gemini') {
      return GeminiRepository(json['key']);
    } else {
      throw UnimplementedError();
    }
  }
}
