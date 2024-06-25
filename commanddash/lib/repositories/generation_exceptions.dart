part of 'gemini_repository.dart';

class ModelException implements Exception {
  final String? message;
  ModelException([this.message]);
  @override
  String toString() {
    return message ?? 'ModelException: Unknow error occurred.';
  }
}

class InvalidApiKeyException implements Exception {
  InvalidApiKeyException();
  @override
  String toString() {
    return 'InvalidApiKeyException: Api key is invalid. please check the api key and try again.';
  }
}
