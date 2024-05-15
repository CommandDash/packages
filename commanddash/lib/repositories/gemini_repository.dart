import 'package:commanddash/models/chat_message.dart';
import 'package:commanddash/repositories/generation_repository.dart';
import 'package:dio/dio.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:google_generative_ai/src/client.dart';
import 'package:google_generative_ai/src/error.dart';

class UnknownException implements Exception {
  UnknownException(this.message);
  final String message;
}

class GeminiRepository implements GenerationRepository {
  final String apiKey;
  final Dio dio;
  GeminiRepository(this.apiKey, {required this.dio});
  @override
  Future<String> getCompletion(
    String messages,
  ) async {
    try {
      final message = [
        {'role': 'user', 'content': messages}
      ];
      final response =
          await dio.post('/ai/message/create', data: {'message': message});
      final responseText = response.data['text'];
      if (responseText == null) {
        throw Exception('No response received from Claud');
      }
      return responseText;
    } catch (e) {
      throw Exception('Error getting response from claud: ${e.toString()}');
    }
  }

  @override
  Future<List<double>> getCodeEmbeddings(
    String value,
  ) async {
    try {
      final model = GenerativeModel(model: 'embedding-001', apiKey: apiKey);
      final content = Content.text(value);

      final result = await model.embedContent(
        content,
        taskType: TaskType
            .retrievalDocument, //TODO: let's later think if we can improve this in a general way and make a single API for both string and code.
      );
      return result.embedding.values;
    } on InvalidApiKey {
      throw InvalidApiKeyException();
    } on ServerException catch (e) {
      throw ModelException(e.message);
    } on UnsupportedUserLocation catch (e) {
      throw ModelException(e.message);
    } on FormatException catch (e) {
      throw UnknownException(e.message);
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }

  @override
  Future<List<List<double>>> getCodeBatchEmbeddings(
      List<Map<String, dynamic>> code) async {
    try {
      final model = GenerativeModel(model: 'embedding-001', apiKey: apiKey);
      final embedRequest = code
          .map((value) => EmbedContentRequest(Content.text(value['content']),
              title: value['title'], taskType: TaskType.retrievalDocument))
          .toList();
      final response = await model.batchEmbedContents(embedRequest);
      return response.embeddings.map((e) => e.values).toList();
    } on InvalidApiKey catch (_) {
      //Note: this exeception are not thrown anyway by the embedAPIs
      throw InvalidApiKeyException();
    } on ServerException catch (e) {
      throw ModelException(e.message);
    } on UnsupportedUserLocation catch (e) {
      throw ModelException(e.message);
    } on FormatException catch (e) {
      throw UnknownException(e.message);
    } catch (e) {
      throw UnknownException(e.toString());
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
    } on InvalidApiKey {
      throw InvalidApiKeyException();
    } on ServerException catch (e) {
      throw ModelException(e.message);
    } on UnsupportedUserLocation catch (e) {
      throw ModelException(e.message);
    } on FormatException catch (e) {
      throw UnknownException(e.message);
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }

  @override
  Future<List<List<double>>> getStringBatchEmbeddings(
      List<String> values) async {
    //TODO: update to batch embed
    try {
      final response = await HttpApiClient(apiKey: apiKey).makeRequest(
          Uri.https('generativelanguage.googleapis.com').resolveUri(Uri(
              pathSegments: [
                'v1',
                'models',
                'embedding-001:batchEmbedContents'
              ])),
          {
            'requests': values
                .map((e) => <String, Object?>{
                      'model': 'models/embedding-001',
                      'content': Content.text(e).toJson(),
                      'taskType': TaskType.retrievalQuery.toJson(),
                    })
                .toList()
          });
      try {
        return (response['embeddings'] as List)
            .map((e) => List<double>.from(e['values']))
            .toList();
      } catch (e) {
        if (response.containsKey('error')) {
          throw parseError(response['error']!);
        }
        rethrow;
      }
    } on InvalidApiKey catch (_) {
      //Note: this exeception are not thrown anyway by the embedAPIs
      throw InvalidApiKeyException();
    } on ServerException catch (e) {
      throw ModelException(e.message);
    } on UnsupportedUserLocation catch (e) {
      throw ModelException(e.message);
    } on FormatException catch (e) {
      throw UnknownException(e.message);
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }

  @override
  Future<String> getChatCompletion(
      List<ChatMessage> messages, String lastMessage) async {
    final model = GenerativeModel(model: 'gemini-pro', apiKey: apiKey);
    final Content content = Content.text(lastMessage);
    final history = messages.map((e) {
      if (e.role == ChatRole.user) {
        return Content.text(e.message);
      } else {
        return Content.model([TextPart(e.message)]);
      }
    }).toList();

    final chat = model.startChat(history: history);
    var response = await chat.sendMessage(content);
    if (response.text != null) {
      return response.text!;
    } else {
      throw ModelException("No response recieved from gemini");
    }
  }
}
