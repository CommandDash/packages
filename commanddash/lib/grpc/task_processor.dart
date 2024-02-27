import 'dart:async';

import 'package:commanddash/generated/task_processor.pbgrpc.dart';
import 'package:commanddash/utils/process_box.dart';
import 'package:grpc/service_api.dart';

class TaskProcessor extends TaskProcessorServiceBase {
  @override
  Stream<ProcessorMessage> processTask(
      ServiceCall call, Stream<ClientMessage> request) {
    final controller = StreamController<ProcessorMessage>();
    final ProcessBox processBox = ProcessBox(controller, request);

    _processTask(processBox);

    return controller.stream;
  }

  _processTask(ProcessBox processBox) async {
    ClientMessage firstRequest = await processBox.getBaseMessage;

    if (firstRequest.hasTaskStart()) {
      await startTaskProcessing(firstRequest.taskStart, processBox);
    } else {
      processBox
          .sendErrorMessage(ErrorMessage(message: 'Invalid Task Request'));
    }
  }

  Future<void> startTaskProcessing(
      TaskStartMessage taskStartMessage, ProcessBox processBox) async {
    switch (taskStartMessage.task) {
      case 'random_task':
        await someRandomTask(
            taskStartMessage.args['argument'] as String, processBox);
        break;

      default:
        processBox.sendErrorMessage(ErrorMessage(message: 'Invalid Task Type'));
    }
  }
}

Future<void> someRandomTask(
    String randomArgument, ProcessBox processBox) async {
  // some process
  await processBox
      .fetchAdditionalData(GetAdditionalDataMessage(kind: '', args: {}));

  return processBox
      .sendSuccessMessage(SuccessMessage(args: {'result': 'success'}));
}
