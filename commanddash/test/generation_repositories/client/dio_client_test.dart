import 'package:commanddash/repositories/client/dio_client.dart';
import 'package:dio/dio.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import 'dio_client_test.mocks.dart';

@GenerateMocks([Dio, RequestInterceptorHandler, ErrorInterceptorHandler])
void main() {
  late MockDio dio;
  late MockErrorInterceptorHandler errorInterceptorHandler;
  late CustomInterceptor customInterceptor;

  setUp(() {
    dio = MockDio();
    errorInterceptorHandler = MockErrorInterceptorHandler();
    customInterceptor = CustomInterceptor(
      dio: dio,
      accessToken: 'access-token',
      updateAccessToken: () async {
        return {'access_token': 'new-access-token'};
      },
    );
  });

  group('CustomInterceptor', () {
    test('sends access token in header', () async {
      final requestOptions = RequestOptions(path: '/api/v1/users');
      customInterceptor.onRequest(requestOptions, RequestInterceptorHandler());

      expect(requestOptions.headers['Authorization'], 'Bearer access-token');
    });

    group('onError', () {
      test('updates access token and retries request on 401 status code',
          () async {
        final requestOptions = RequestOptions(path: '/api/v1/users');
        final dioError = DioException(
          requestOptions: requestOptions,
          response: Response(
            statusCode: 401,
            requestOptions: requestOptions,
          ),
        );
        final response =
            Response(data: '{"id": 1}', requestOptions: requestOptions);
        when(dio.fetch(requestOptions)).thenAnswer((_) async => response);

        await customInterceptor.onError(dioError, errorInterceptorHandler);

        verify(dio.fetch(requestOptions));
        verify(errorInterceptorHandler.resolve(response));
        expect(
            requestOptions.headers['Authorization'], 'Bearer new-access-token');
      });

      test('passes error to handler on non-401 status code', () async {
        final requestOptions = RequestOptions(path: '/api/v1/users');
        final dioError = DioException(
          requestOptions: requestOptions,
          response: Response(
            statusCode: 500,
            requestOptions: requestOptions,
          ),
        );

        await customInterceptor.onError(dioError, errorInterceptorHandler);
        verify(errorInterceptorHandler.next(dioError));
        verifyNever(dio.fetch(any));
      });

      test('passes error to handler when updateAccessToken throws an exception',
          () async {
        final requestOptions = RequestOptions(path: '/api/v1/users');
        final exception = DioException(requestOptions: requestOptions);
        customInterceptor = CustomInterceptor(
          dio: dio,
          accessToken: 'access-token',
          updateAccessToken: () async {
            throw exception;
          },
        );

        final dioError = DioException(
          requestOptions: requestOptions,
          response: Response(
            statusCode: 401,
            requestOptions: requestOptions,
          ),
        );

        await customInterceptor.onError(dioError, errorInterceptorHandler);
        verifyNever(dio.fetch(any));
        verifyNever(errorInterceptorHandler.resolve(any));
        verify(errorInterceptorHandler.next(exception));
      });
      test('passes error to handler when dio.fetch throws an exception',
          () async {
        final requestOptions = RequestOptions(path: '/api/v1/users');
        final exception = DioException(requestOptions: requestOptions);
        final dioError = DioException(
          requestOptions: requestOptions,
          response: Response(
            statusCode: 401,
            requestOptions: requestOptions,
          ),
        );
        when(dio.fetch(requestOptions)).thenThrow(exception);
        await customInterceptor.onError(dioError, errorInterceptorHandler);
        verify(dio.fetch(any));
        verifyNever(errorInterceptorHandler.resolve(any));
        verify(errorInterceptorHandler.next(exception));
      });
      test('throws error when updateAccessToken doesn\'t return access token',
          () async {
        final requestOptions = RequestOptions(path: '/api/v1/users');
        customInterceptor = CustomInterceptor(
          dio: dio,
          accessToken: 'access-token',
          updateAccessToken: () async {
            return {};
          },
        );
        final dioError = DioException(
          requestOptions: requestOptions,
          response: Response(
            statusCode: 401,
            requestOptions: requestOptions,
          ),
        );

        expect(
            () async => await customInterceptor.onError(
                dioError, errorInterceptorHandler),
            throwsA(const TypeMatcher<Exception>()));
      });
    });
  });
}
