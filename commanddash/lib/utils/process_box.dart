import 'dart:async';

import 'package:async/async.dart'; // For StreamQueue
import 'package:commanddash/generated/task_processor.pbgrpc.dart';

class ProcessBox {
  final StreamController<ProcessorMessage> _controller;
  final Stream<ClientMessage> _request;
  final StreamQueue<ClientMessage> queue;

  ProcessBox(this._controller, this._request) : queue = StreamQueue(_request) {
    _controller.stream.listen((ProcessorMessage event) async {
      if (event.hasSuccess() || event.hasError()) {
        await _controller.close();
      }
    }); // close the controller once success or error event is remitted
  }

  Future<ClientMessage> get getBaseMessage => _request.first;

  Future<Map<String, String>> fetchAdditionalData(
      GetAdditionalDataMessage message) async {
    _controller.add(ProcessorMessage(getAdditionalData: message));
    final next = await queue.next;
    return next.additionalData.args;
  }

  void sendSuccessMessage(SuccessMessage message) =>
      _controller.add(ProcessorMessage(success: message));

  void sendErrorMessage(ErrorMessage message) =>
      _controller.add(ProcessorMessage(error: message));
}
