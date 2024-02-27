//
//  Generated code. Do not modify.
//  source: example_service.proto
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

import 'example_service.pb.dart' as $0;

export 'example_service.pb.dart';

@$pb.GrpcServiceName('commanddash.TaskProcessor')
class TaskProcessorClient extends $grpc.Client {
  static final _$processTask = $grpc.ClientMethod<$0.FetchRequest, $0.Response>(
      '/commanddash.TaskProcessor/processTask',
      ($0.FetchRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.Response.fromBuffer(value));
  static final _$processMultiStepTask = $grpc.ClientMethod<$0.FetchRequest, $0.Response>(
      '/commanddash.TaskProcessor/processMultiStepTask',
      ($0.FetchRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.Response.fromBuffer(value));

  TaskProcessorClient($grpc.ClientChannel channel,
      {$grpc.CallOptions? options,
      $core.Iterable<$grpc.ClientInterceptor>? interceptors})
      : super(channel, options: options,
        interceptors: interceptors);

  $grpc.ResponseFuture<$0.Response> processTask($0.FetchRequest request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$processTask, request, options: options);
  }

  $grpc.ResponseStream<$0.Response> processMultiStepTask($0.FetchRequest request, {$grpc.CallOptions? options}) {
    return $createStreamingCall(_$processMultiStepTask, $async.Stream.fromIterable([request]), options: options);
  }
}

@$pb.GrpcServiceName('commanddash.TaskProcessor')
abstract class TaskProcessorServiceBase extends $grpc.Service {
  $core.String get $name => 'commanddash.TaskProcessor';

  TaskProcessorServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.FetchRequest, $0.Response>(
        'processTask',
        processTask_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.FetchRequest.fromBuffer(value),
        ($0.Response value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.FetchRequest, $0.Response>(
        'processMultiStepTask',
        processMultiStepTask_Pre,
        false,
        true,
        ($core.List<$core.int> value) => $0.FetchRequest.fromBuffer(value),
        ($0.Response value) => value.writeToBuffer()));
  }

  $async.Future<$0.Response> processTask_Pre($grpc.ServiceCall call, $async.Future<$0.FetchRequest> request) async {
    return processTask(call, await request);
  }

  $async.Stream<$0.Response> processMultiStepTask_Pre($grpc.ServiceCall call, $async.Future<$0.FetchRequest> request) async* {
    yield* processMultiStepTask(call, await request);
  }

  $async.Future<$0.Response> processTask($grpc.ServiceCall call, $0.FetchRequest request);
  $async.Stream<$0.Response> processMultiStepTask($grpc.ServiceCall call, $0.FetchRequest request);
}
