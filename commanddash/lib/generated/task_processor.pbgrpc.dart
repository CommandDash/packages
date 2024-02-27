//
//  Generated code. Do not modify.
//  source: task_processor.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:grpc/service_api.dart' as $grpc;
import 'package:protobuf/protobuf.dart' as $pb;

import 'task_processor.pb.dart' as $0;

export 'task_processor.pb.dart';

@$pb.GrpcServiceName('commanddash.TaskProcessor')
class TaskProcessorClient extends $grpc.Client {
  static final _$processTask = $grpc.ClientMethod<$0.ClientMessage, $0.ProcessorMessage>(
      '/commanddash.TaskProcessor/processTask',
      ($0.ClientMessage value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.ProcessorMessage.fromBuffer(value));

  TaskProcessorClient($grpc.ClientChannel channel,
      {$grpc.CallOptions? options,
      $core.Iterable<$grpc.ClientInterceptor>? interceptors})
      : super(channel, options: options,
        interceptors: interceptors);

  $grpc.ResponseStream<$0.ProcessorMessage> processTask($async.Stream<$0.ClientMessage> request, {$grpc.CallOptions? options}) {
    return $createStreamingCall(_$processTask, request, options: options);
  }
}

@$pb.GrpcServiceName('commanddash.TaskProcessor')
abstract class TaskProcessorServiceBase extends $grpc.Service {
  $core.String get $name => 'commanddash.TaskProcessor';

  TaskProcessorServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.ClientMessage, $0.ProcessorMessage>(
        'processTask',
        processTask,
        true,
        true,
        ($core.List<$core.int> value) => $0.ClientMessage.fromBuffer(value),
        ($0.ProcessorMessage value) => value.writeToBuffer()));
  }

  $async.Stream<$0.ProcessorMessage> processTask($grpc.ServiceCall call, $async.Stream<$0.ClientMessage> request);
}
