import 'dart:async';

import 'package:commanddash/runner.dart';
import 'package:dio/dio.dart';

typedef RefreshAccessToken = Future<Map<String, dynamic>> Function();

Dio getClient(
  String accessToken,
  RefreshAccessToken updateAccessToken,
) {
  final dio = Dio();
  dio.options.baseUrl = 'https://api.commanddash.dev';
  dio.options.headers['Engine-Version'] = version;
  dio.interceptors.add(CustomInterceptor(
      dio: dio,
      accessToken: accessToken,
      updateAccessToken: updateAccessToken));
  return dio;
}

class CustomInterceptor extends Interceptor {
  CustomInterceptor(
      {required this.dio,
      required this.accessToken,
      required this.updateAccessToken,
      this.apiKey});
  final Dio dio;
  String accessToken;
  RefreshAccessToken updateAccessToken;
  String? apiKey;

  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    options.headers['Authorization'] = 'Bearer $accessToken';
    options.headers['X-API-Key'] = '$apiKey';
    return handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    response.data = response.data;
    handler.resolve(response);
  }

  @override
  Future<void> onError(
      DioException err, ErrorInterceptorHandler handler) async {
    if (err.response != null && err.response!.statusCode == 401) {
      try {
        final tokenResponse = await updateAccessToken();
        if (tokenResponse['access_token'] == null) {
          throw Exception('Unable to refresh github access token');
        }
        accessToken = tokenResponse['access_token'];

        // Retry the original request
        final opts = err.requestOptions;
        opts.headers['Authorization'] = 'Bearer $accessToken';

        final response = await dio.fetch(opts);
        handler.resolve(response);
      } on DioException catch (e) {
        // if [updateAccessToken] or [dio.fetch] fails
        handler.next(e);
      }
    } else {
      handler.next(err);
    }
  }
}

UserException userException(Exception e) {
  if (e is DioException) {
    if (e.response != null) {
      return UserException(
          statusCode: e.response!.statusCode,
          message: e.response!.data['message']);
    } else {
      return UserException(message: e.message);
    }
  } else {
    throw UserException(message: e.toString());
  }
}

class UserException implements Exception {
  UserException({this.statusCode, this.message});

  final int? statusCode;
  final String? message;

  @override
  String toString() {
    if (statusCode != null) {
      return '$statusCode $message';
    } else {
      return '$message';
    }
  }
}
