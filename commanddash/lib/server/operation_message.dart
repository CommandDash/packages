import 'package:commanddash/server/messages.dart';

class OperationResponseMessage extends IncomingMessage {
  final String kind;
  final Map<String, dynamic> data;

  OperationResponseMessage(this.kind, {required this.data}) : super(-1);

  @override
  List<Object?> get props => [kind, data];
}

/// [OperationMesssage] are one-off messages sent from CLI to Client that are not just scoped to a single task.
/// [id] here represents the OperationID.
/// Client returns -> [OperationResponseMessage]
class OperationMessage extends OutgoingMessage {
  final String kind;
  final Map<String, dynamic> args;
  OperationMessage({required this.kind, required this.args}) : super(-1);
  @override
  Map<String, dynamic> get toJson {
    return {
      'id': -1,
      'method': 'operation',
      'params': {
        'kind': kind,
        'args': args,
      },
    };
  }

  @override
  List<Object?> get props => [kind, args];
}
