class IncomingMessage {
  final int id;
  const IncomingMessage(this.id);

  factory IncomingMessage.fromJson(Map<String, dynamic> json) {
    switch (json['method']) {
      case 'task_start':
        final taskId = json['id'];
        final taskKind = json['params']['kind'];
        final taskData = json['params']['data'];
        return TaskStartMessage(taskId, taskKind: taskKind, data: taskData);
      case 'process_step_response':
        final taskId = json['id'];
        final responseData = json['params'];
        return ProcessResponseMessage(taskId, data: responseData);
      default:
        throw UnimplementedError();
    }
  }
}

class TaskStartMessage extends IncomingMessage {
  final String taskKind;
  final Map<String, dynamic> data;
  TaskStartMessage(int id, {required this.taskKind, required this.data})
      : super(id);
}

class ProcessResponseMessage extends IncomingMessage {
  final Map<String, dynamic> data;
  ProcessResponseMessage(int id, {required this.data}) : super(id);
}

class OutgoingMessage {
  final int id;
  const OutgoingMessage(this.id);

  Map<String, dynamic> get toJson => {'id': id};
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
}

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
}

/// To be used to communicate with client to execute any user facing tasks or fetch data from client.
class ProcessMessage extends OutgoingMessage {
  final String kind;
  final Map<String, dynamic> args;
  ProcessMessage(int id, {required this.kind, required this.args}) : super(id);

  @override
  Map<String, dynamic> get toJson {
    final json = super.toJson;
    json.addAll({
      'method': 'process_step',
      'params': {
        'kind': kind,
        'args': args,
      },
    });
    return json;
  }
}
