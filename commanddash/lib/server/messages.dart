import 'package:commanddash/server/operation_message.dart';
import 'package:equatable/equatable.dart';

class IncomingMessage extends Equatable {
  final int id;
  const IncomingMessage(this.id);

  factory IncomingMessage.fromJson(Map<String, dynamic> json) {
    switch (json['method']) {
      case 'task_start':
        final taskId = json['id'];
        final taskKind = json['params']['kind'];
        final taskData = json['params']['data'];
        return TaskStartMessage(taskId, taskKind: taskKind, data: taskData);
      case 'agent-execute':
        final taskId = json['id'];
        final taskKind = json['method'];
        final taskData = json['params'];
        return TaskStartMessage(taskId, taskKind: taskKind, data: taskData);
      case 'step_response':
        final taskId = json['id'];
        final responseData = json['data'];
        return StepResponseMessage(taskId, json['kind'], data: responseData);
      case 'operation_response':
        final responseData = json['data'];
        return OperationResponseMessage(json['kind'], data: responseData);
      default:
        throw UnimplementedError();
    }
  }

  @override
  List<Object?> get props => [id];
}

class TaskStartMessage extends IncomingMessage {
  final String taskKind; // agent-execute
  final Map<String, dynamic> data;
  TaskStartMessage(int id, {required this.taskKind, required this.data})
      : super(id);
  @override
  List<Object?> get props => [...super.props, taskKind, data];

  factory TaskStartMessage.fromJson(
      int id, String taskKind, Map<String, dynamic> data) {
    return TaskStartMessage(id, taskKind: taskKind, data: data);
  }
}

class StepResponseMessage extends IncomingMessage {
  final String kind;
  final Map<String, dynamic> data;

  StepResponseMessage(int id, this.kind, {required this.data}) : super(id);

  @override
  List<Object?> get props => [...super.props, kind, data];
}

class OutgoingMessage extends Equatable {
  final int id;
  const OutgoingMessage(this.id);

  Map<String, dynamic> get toJson => {'id': id};

  @override
  List<Object?> get props => [id];
}

class ResultMessage extends OutgoingMessage {
  final String message;
  final Map<String, dynamic> data;
  ResultMessage(int id, {required this.message, required this.data})
      : super(id);

  @override
  Map<String, dynamic> get toJson {
    final json = super.toJson;
    json.addAll({
      'method': 'result',
      'params': {
        'message': message,
        'data': data,
      },
    });
    return json;
  }

  @override
  List<Object?> get props => [...super.props, message, data];
}

class ErrorMessage extends OutgoingMessage {
  final String message;
  final Map<String, dynamic> data;
  ErrorMessage(int id, {required this.message, required this.data}) : super(id);

  @override
  Map<String, dynamic> get toJson {
    final json = super.toJson;
    json.addAll({
      'method': 'error',
      'params': {
        'message': message,
        'data': data,
      },
    });
    return json;
  }

  @override
  List<Object?> get props => [...super.props, message, data];
}

/// Log Message is sent to log something in the client side for debugging purpose.
class LogMessage extends OutgoingMessage {
  final String message;
  final Map<String, dynamic> data;
  LogMessage(int id, {required this.message, required this.data}) : super(id);

  @override
  Map<String, dynamic> get toJson {
    final json = super.toJson;
    json.addAll({
      'method': 'log',
      'params': {
        'message': message,
        'data': data,
      },
    });
    return json;
  }

  @override
  List<Object?> get props => [...super.props, message, data];
}

/// Step messages are continuous messages sent to client while executing a task.
/// [id] represents the taskId
/// Client returns -> [StepResponseMessage]
class StepMessage extends OutgoingMessage {
  final String kind;
  final Map<String, dynamic> args;
  StepMessage(int id, {required this.kind, required this.args}) : super(id);

  @override
  Map<String, dynamic> get toJson {
    final json = super.toJson;
    json.addAll({
      'method': 'step',
      'params': {
        'kind': kind,
        'args': args,
      },
    });
    return json;
  }

  @override
  List<Object?> get props => [...super.props, kind, args];
}
