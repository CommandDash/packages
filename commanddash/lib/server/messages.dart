class IncomingMessage {
  final String id;
  const IncomingMessage(this.id);

  factory IncomingMessage.fromJson(Map<String, dynamic> json) {
    switch (json['method']) {
      case 'taskStart':
        final taskId = json['id'];
        final taskKind = json['params']['kind'];
        final taskData = json['params']['data'];
        return TaskStartMessage(taskId, taskKind: taskKind, data: taskData);
      case 'additionalData':
        final taskId = json['id'];
        final additionalData = json['params']['data'];
        return AdditionalDataMessage(taskId, data: additionalData);
      default:
        throw UnimplementedError();
    }
  }
}

class TaskStartMessage extends IncomingMessage {
  final String taskKind;
  final Map<String, dynamic> data;
  TaskStartMessage(String id, {required this.taskKind, required this.data})
      : super(id);
}

class AdditionalDataMessage extends IncomingMessage {
  final Map<String, dynamic> data;
  AdditionalDataMessage(String id, {required this.data}) : super(id);
}

class OutgoingMessage {
  final String id;
  const OutgoingMessage(this.id);

  Map<String, dynamic> get toJson => {'id': id};
}

class SuccessMessage extends OutgoingMessage {
  final String message;
  final Map<String, dynamic> data;
  SuccessMessage(String id, {required this.message, required this.data})
      : super(id);

  @override
  Map<String, dynamic> get toJson {
    final json = super.toJson;
    json.addAll({
      'method': 'result',
      'result': {
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
  ErrorMessage(String id, {required this.message, required this.data})
      : super(id);

  @override
  Map<String, dynamic> get toJson {
    final json = super.toJson;
    json.addAll({
      'method': 'error',
      'error': {
        'message': message,
        'data': data,
      },
    });
    return json;
  }
}

class GetAdditionalDataMessage extends OutgoingMessage {
  final String kind;
  final Map<String, dynamic> args;
  GetAdditionalDataMessage(String id, {required this.kind, required this.args})
      : super(id);

  @override
  Map<String, dynamic> get toJson {
    final json = super.toJson;
    json.addAll({
      'method': 'additionalData',
      'params': {
        'kind': kind,
        'args': args,
      },
    });
    return json;
  }
}
