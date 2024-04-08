import 'dart:async';

import 'package:commanddash/server/messages.dart';
import 'package:commanddash/server/operation_message.dart';
import 'package:commanddash/server/server.dart';
import 'package:rxdart/rxdart.dart';

enum TimeoutKind {
  /// 6s. Use for almost synchronous tasks like fetching local data.
  sync,

  /// 60s. Use for finite API call related tasks, like refreshing accessToken.
  async,

  /// 6 mins. Use for long running tasks like LLM calls (if any at client level).
  stretched
}

Duration durationFromTimeoutKind(TimeoutKind kind) {
  switch (kind) {
    case TimeoutKind.sync:
      return Duration(seconds: 6);
    case TimeoutKind.async:
      return Duration(seconds: 60);
    case TimeoutKind.stretched:
      return Duration(minutes: 6);
  }
}

class TaskAssist {
  TaskAssist(this._server, this._taskId);
  final Server _server;
  final int _taskId;

  Future<Map<String, dynamic>> processStep(
      {required String kind, required Map<String, dynamic> args}) async {
    _server.sendMessage(StepMessage(_taskId, kind: kind, args: args));
    final dataResponse = await _server.messagesStream
        .whereType<StepResponseMessage>()
        .where((event) => event.id == _taskId)
        .first;
    if (dataResponse.data['result'] == 'error') {
      throw Exception(dataResponse.data['message']);
    }
    return dataResponse.data;
  }

  void sendResultMessage(
      {required String message, required Map<String, dynamic> data}) {
    _server.sendMessage(ResultMessage(_taskId, message: message, data: data));
  }

  void sendErrorMessage(
      {required message,
      required Map<String, dynamic> data,
      StackTrace? stackTrace}) {
    _server.sendMessage(ErrorMessage(_taskId,
        message: message,
        data: data..addAll({'stack_trace': stackTrace?.toString()})));
  }

  /// Only use for debugging purposes. Clients can print the log on their end.
  void sendLogMessage({required message, required Map<String, dynamic> data}) {
    _server.sendMessage(LogMessage(_taskId, message: message, data: data));
  }

  /// To perform task independent operationas such as asking client to refresh and provide new access token.
  ///
  /// [timeoutKind] should be suitably added depending upon what is expected from the operation
  Future<Map<String, dynamic>> processOperation({
    required String kind,
    required Map<String, dynamic> args,
    TimeoutKind timeoutKind = TimeoutKind.async,
  }) async {
    _server.sendMessage(OperationMessage(kind: kind, args: args));

    final dataResponse = await _server.messagesStream
        .whereType<OperationResponseMessage>()
        .where((event) => event.kind == kind)
        .first
        .timeout(durationFromTimeoutKind(timeoutKind), onTimeout: () {
      throw TimeoutException('Operation timed out fetching $kind');
    });

    if (dataResponse.data['result'] == 'error') {
      throw Exception(dataResponse.data['message']);
    }
    return dataResponse.data;
  }
}
