import 'package:commanddash/models/data_source.dart';
import 'package:commanddash/repositories/client/dio_client.dart';
import 'package:commanddash/server/task_assist.dart';
import 'package:dio/dio.dart';

class DashRepository {
  DashRepository(this.dio);
  final Dio dio;

  factory DashRepository.fromKeys(
      String githubAccessToken, TaskAssist taskAssist) {
    final client = getClient(
        githubAccessToken,
        () async => taskAssist
            .processOperation(kind: 'refresh_access_token', args: {}));
    final repo = DashRepository(client);
    return repo;
  }

  /// Error is handled and thrown back from the interceptor. Add a try catch at step level.
  Future<void> mockApi() async {
    final response = await dio.get('/path');
    return response.data;
  }

  Future<List<DataSource>> getDatasource({
    required String agentName,
    required String agentVersion,
    required String query,
    required List<DataSource> datasources,
  }) async {
    try {
      final response = await dio.post('/agent/get-reference', data: {
        "name": agentName,
        "query": query,
        "version": agentVersion,
        "matching_doc_data_source_ids": datasources.map((e) => e.id).toList(),
        "testing": true,
      });
      return List<Map<String, dynamic>>.from(response.data['data']).map((e) {
        return DataSource.fromJson(e);
      }).toList();
    } catch (e) {
      throw Exception('Error fetching datasource');
    }
  }

  // TODO: to be tested
  Future<List<Map<String, dynamic>>> getAgents() async {
    try {
      final response = await dio.post('/agent/get-general-agents', data: {
        "testing": true,
        "min_cli_version": "1.0.0",
      });
      return response.data;
    } catch (e) {
      throw Exception('Error fetching datasource');
    }
  }
}
