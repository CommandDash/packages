import 'dart:convert';

import 'package:commanddash/models/chat_message.dart';
import 'package:commanddash/repositories/client/dio_client.dart';

import 'package:commanddash/server/task_assist.dart';
import 'package:commanddash/utils/embedding_utils.dart';
import 'package:dio/dio.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:google_generative_ai/src/client.dart';
import 'package:google_generative_ai/src/error.dart';

part 'generation_exceptions.dart';

class UnknownException implements Exception {
  UnknownException(this.message);
  final String message;
}

class GeminiRepository {
  final String? apiKey;
  late Dio dio;

  final int characterLimit = 120000.tokenized;

  GeminiRepository(this.apiKey, this.dio);

  factory GeminiRepository.fromKeys(
      String? apiKey, String githubAccessToken, TaskAssist taskAssist) {
    final client = getClient(
        githubAccessToken,
        () async => taskAssist
            .processOperation(kind: 'refresh_access_token', args: {}));
    return GeminiRepository(apiKey, client);
  }

  Future<List<double>> getCodeEmbeddings(
    String value,
  ) async {
    if (apiKey == null) {
      throw Exception('This functionality is not supported without Gemini Key');
    }
    try {
      final model = GenerativeModel(model: 'embedding-001', apiKey: apiKey!);
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

  Future<List<List<double>>> getCodeBatchEmbeddings(
      List<Map<String, dynamic>> code) async {
    if (apiKey == null) {
      throw Exception('This functionality is not supported without Gemini Key');
    }
    try {
      final model = GenerativeModel(model: 'embedding-001', apiKey: apiKey!);
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

  Future<List<double>> getStringEmbeddings(String value) async {
    if (apiKey == null) {
      throw Exception('This functionality is not supported without Gemini Key');
    }
    try {
      final model = GenerativeModel(model: 'embedding-001', apiKey: apiKey!);
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

  Future<List<List<double>>> getStringBatchEmbeddings(
      List<String> values) async {
    if (apiKey == null) {
      throw Exception('This functionality is not supported without Gemini Key');
    }
    try {
      final response = await HttpApiClient(apiKey: apiKey!).makeRequest(
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

  Future<String> getCompletion(String message, String agentName,
      {String? command}) async {
    String response;
    if (apiKey != null) {
      try {
        response = await _getGeminiFlashChatCompletionResponse(
            'gemini-1.5-flash', [], message, apiKey!);
      } on ServerException catch (e) {
        // throw GenerativeAIException('recitation');
        if (e.message.contains('recitation') ||
            e.message
                .contains('User location is not supported for the API use')) {
          response = await getApiCompletionResponse([], message,
              agentName: agentName, command: command);
        } else {
          rethrow;
        }
      }
    } else {
      response = await getApiCompletionResponse([], message,
          agentName: agentName, command: command);
    }

    return response;
  }

  Future<String> getChatCompletion(
    List<ChatMessage> messages,
    String lastMessage, {
    required String agent,
    String? command,
    String? systemPrompt,
  }) async {
    String response;
    if (apiKey != null) {
      try {
        response = await _getGeminiFlashChatCompletionResponse(
            'gemini-1.5-flash', messages, lastMessage, apiKey!,
            systemPrompt: systemPrompt);
      } on GenerativeAIException catch (e) {
        // throw GenerativeAIException('recitation');
        if (e.message.contains('recitation') ||
            e.message
                .contains('User location is not supported for the API use')) {
          response = await getApiCompletionResponse(messages, lastMessage,
              systemPrompt: systemPrompt, agentName: agent, command: command);
        } else {
          rethrow;
        }
      }
    } else {
      response = await getApiCompletionResponse(messages, lastMessage,
          systemPrompt: systemPrompt, agentName: agent, command: command);
    }

    return response;
  }

  Future<String> _getGeminiFlashChatCompletionResponse(String modelCode,
      List<ChatMessage> messages, String lastMessage, String apiKey,
      {String? systemPrompt}) async {
    // system intructions are not being adapted that well by Gemini models.
    // final Content? systemInstruction =
    //     systemPrompt != null ? Content.text(systemPrompt) : null;
    final model = GenerativeModel(model: modelCode, apiKey: apiKey);
    final Content content = Content.text(lastMessage);
    final history = messages.map((e) {
      if (e.role == ChatRole.user) {
        return Content.text(e.message);
      } else {
        return Content.model([TextPart(e.message)]);
      }
    }).toList();

    if (systemPrompt != null) {
      history.insert(0, Content.text(systemPrompt));
    }

    final chat = model.startChat(history: history);
    final response = await chat.sendMessage(content);
    if (response.text != null) {
      return response.text!;
    } else {
      throw ModelException("No response recieved from gemini");
    }
  }

  Future<String> getApiCompletionResponse(
      List<ChatMessage> messages, String lastMessage,
      {required String agentName,
      String? command,
      String? systemPrompt}) async {
    final List<Map<String, String>> message = [];

    if (systemPrompt != null) {
      message.add({'role': 'model', 'text': systemPrompt});
    }
    for (final e in messages) {
      if (e.role == ChatRole.user) {
        message.add({'role': 'model', 'text': e.message});
      } else {
        message.add({'role': 'user', 'text': e.message});
      }
    }
    message.add({'role': 'user', 'text': lastMessage});

    final response = await dio.post(
      '/ai/agent/answer',
      data: {'message': message, 'agent': agentName, 'command': command},
    );
    if (response.statusCode == 200) {
      return response.data['content'] as String;
    }
    throw ModelException('${response.statusCode}: ${response.data['message']}');
  }
}
