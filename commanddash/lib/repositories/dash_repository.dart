import 'package:dio/dio.dart';

class DashRepository {
  DashRepository(this.dio);
  final Dio dio;

  /// Error is handled and thrown back from the interceptor. Add a try catch at step level.
  Future<void> mockApi() async {
    final response = await dio.get('/path');
    return response.data;
  }
}
