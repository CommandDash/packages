import 'package:commanddash/models/chat_message.dart';
import 'package:commanddash/repositories/generation_repository.dart';
import 'package:dio/dio.dart';

class ClaudRepository implements GenerationRepository {
  final Dio dio;
  ClaudRepository(this.dio);

  @override
  Future<String> getChatCompletion(
      List<ChatMessage> messages, String lastMessage) async {
    try {
      final history = messages
          .map((message) => {
                'role': message.role == ChatRole.user ? 'user' : 'assistant',
                'content': message.message
              })
          .toList();
      final body = [
        ...history,
        {'role': 'user', 'content': lastMessage}
      ];

      final response = await dio.post('/ai/message/create', data: body);
      return response.data['text'];
    } catch (e) {
      throw Exception('Error getting response from claud: ${e.toString()}');
    }
  }

  @override
  Future<String> getCompletion(String message) async {
    try {
      final body = {'role': 'user', 'content': message};
      final response = await dio.post('/ai/message/create', data: body);
      return response.data['text'];
    } catch (e) {
      throw Exception('Error getting response from claud: ${e.toString()}');
    }
  }

  @override
  Future<List<List<double>>> getCodeBatchEmbeddings(
      List<Map<String, dynamic>> code) {
    // TODO: implement getCodeBatchEmbeddings
    throw UnimplementedError();
  }

  @override
  Future getCodeEmbeddings(String code) {
    // TODO: implement getCodeEmbeddings
    throw UnimplementedError();
  }

  @override
  Future<List<List<double>>> getStringBatchEmbeddings(List<String> value) {
    // TODO: implement getStringBatchEmbeddings
    throw UnimplementedError();
  }

  @override
  Future getStringEmbeddings(String value) {
    // TODO: implement getStringEmbeddings
    throw UnimplementedError();
  }
}
