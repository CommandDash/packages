import 'package:commanddash/generated/example_service.pbgrpc.dart';
import 'package:grpc/src/client/channel.dart';
import 'package:grpc/src/server/call.dart';

class TaskProcessor extends TaskProcessorServiceBase {
  @override
  Stream<Response> processMultiStepTask(
      ServiceCall call, FetchRequest request) {
    // TODO: implement processMultiStepTask
    throw UnimplementedError();
  }

  @override
  Future<Response> processTask(ServiceCall call, FetchRequest request) async {
    await Future.delayed(Duration(seconds: 1));
    return Response()..success = (SuccessResponse()..args['success'] = 'true');
  }
}
