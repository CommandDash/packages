import 'package:commanddash/agent/loader_model.dart';
import 'package:commanddash/agent/output_model.dart';
import 'package:commanddash/agent/step_model.dart';
import 'package:commanddash/models/data_source.dart';
import 'package:commanddash/repositories/dash_repository.dart';
import 'package:commanddash/repositories/gemini_repository.dart';
import 'package:commanddash/server/task_assist.dart';

import '../steps_utils.dart';

// TODO: To be tested
class SearchInSourceStep extends Step {
  final String query;
  final List<DataSource> dataSource;
  final String agentName;
  final String agentVersion;
  final bool isTest;

  SearchInSourceStep({
    required List<String> outputIds,
    required this.query,
    required this.dataSource,
    required this.agentName,
    required this.agentVersion,
    required this.isTest,
    Loader loader = const MessageLoader('Searching in sources'),
  }) : super(
          outputIds: outputIds,
          type: StepType.promptQuery,
          loader: loader,
        );

  factory SearchInSourceStep.fromJson(
    Map<String, dynamic> json,
    String query,
    String agentName,
    String agentVersion,
    bool isTest,
  ) {
    return SearchInSourceStep(
        outputIds: (json['outputs'] as List<dynamic>)
            .map((e) => e.toString())
            .toList(),
        query: query,
        agentName: agentName,
        agentVersion: agentVersion,
        dataSource: (json['data_sources'] as List)
            .map((e) => DataSource(id: e))
            .toList(),
        isTest: isTest);
  }

  @override
  Future<List<DataSourceResultOutput>> run(
      TaskAssist taskAssist, GeminiRepository generationRepository,
      [DashRepository? dashRepository]) async {
    await super.run(taskAssist, generationRepository);
    if (dashRepository == null) {
      throw Exception('DashRepository is not provided');
    }
    final response = await dashRepository.getDatasource(
        query: query,
        agentName: agentName,
        agentVersion: agentVersion,
        datasources: dataSource,
        isTest: isTest);
    return [DataSourceResultOutput(response)];
  }
}
