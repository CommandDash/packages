import 'dart:convert';

import 'package:commanddash/repositories/generation_repository.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:google_generative_ai/src/client.dart';
import 'package:google_generative_ai/src/error.dart';

class UnknownException implements Exception {
  UnknownException(this.message);
  final String message;
}

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
    } on InvalidApiKey catch (e) {
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
  Future<List<List<double>>> getCodeBatchEmbeddings(List<String> code) async {
    try {
      final response = await HttpApiClient(apiKey: apiKey).makeRequest(
          Uri.https('generativelanguage.googleapis.com').resolveUri(Uri(
              pathSegments: [
                'v1',
                'models',
                'embedding-001:batchEmbedContents'
              ])),
          {
            'requests': code
                .map((e) => <String, Object?>{
                      'model': 'models/embedding-001',
                      'content': Content.text(e).toJson(),
                      'taskType': TaskType.retrievalDocument.toJson(),
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
    } on FormatException catch (e) {
      throw UnknownException(e.message);
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }

  @override
  Future<List<List<double>>> getStringBatchEmbeddings(
      List<String> values) async {
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
  Future<String> getChatCompletion() {
    // TODO: implement getChatCompletion
    throw UnimplementedError();
  }
}
