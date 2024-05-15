import 'package:commanddash/models/chat_message.dart';
import 'package:commanddash/repositories/gemini_repository.dart';
import 'package:dio/dio.dart';
import 'package:matcher/matcher.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

void main() {
  late GeminiRepository repository;
  late Dio dio;

  setUp(() {
    dio = Dio(BaseOptions(baseUrl: 'https://api.commanddash.dev'));
    repository = GeminiRepository(
      'apiKey',
      dio: dio,
    );
  });

  group('getCompletion', () {
    test('throws an error when the API returns an error', () async {
      // Arrange
      when(dio.post('/ai/message/create', data: any)).thenThrow(Exception());

      // Act
      final result = repository.getCompletion('Hello');

      // Assert
      expect(result, throwsException);
    });

    test('returns the response text when the API returns successfully',
        () async {

      // Act
      final result = await repository.getCompletion('Hello');

      // Assert
      expect(result, 'Hello back');
    });

    test('throws an error when the response text is null', () async {
      // Arrange
      when(dio.post('/ai/message/create', data: any)).thenAnswer((_) async =>
          Response(
              data: {'text': null},
              statusCode: 200,
              requestOptions: RequestOptions(path: '/ai/message/create')));

      // Act
      final result = repository.getCompletion('Hello');

      // Assert
      expect(result, throwsException);
    });
  });
}
