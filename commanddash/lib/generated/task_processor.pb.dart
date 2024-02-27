//
//  Generated code. Do not modify.
//  source: task_processor.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

enum ClientMessage_RequestType {
  taskStart, 
  additionalData, 
  notSet
}

/// messages from IDEs or other clients talking to CLI
class ClientMessage extends $pb.GeneratedMessage {
  factory ClientMessage({
    TaskStartMessage? taskStart,
    AdditionalDataMessage? additionalData,
  }) {
    final $result = create();
    if (taskStart != null) {
      $result.taskStart = taskStart;
    }
    if (additionalData != null) {
      $result.additionalData = additionalData;
    }
    return $result;
  }
  ClientMessage._() : super();
  factory ClientMessage.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ClientMessage.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static const $core.Map<$core.int, ClientMessage_RequestType> _ClientMessage_RequestTypeByTag = {
    1 : ClientMessage_RequestType.taskStart,
    2 : ClientMessage_RequestType.additionalData,
    0 : ClientMessage_RequestType.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ClientMessage', package: const $pb.PackageName(_omitMessageNames ? '' : 'commanddash'), createEmptyInstance: create)
    ..oo(0, [1, 2])
    ..aOM<TaskStartMessage>(1, _omitFieldNames ? '' : 'taskStart', protoName: 'taskStart', subBuilder: TaskStartMessage.create)
    ..aOM<AdditionalDataMessage>(2, _omitFieldNames ? '' : 'additionalData', protoName: 'additionalData', subBuilder: AdditionalDataMessage.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ClientMessage clone() => ClientMessage()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ClientMessage copyWith(void Function(ClientMessage) updates) => super.copyWith((message) => updates(message as ClientMessage)) as ClientMessage;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ClientMessage create() => ClientMessage._();
  ClientMessage createEmptyInstance() => create();
  static $pb.PbList<ClientMessage> createRepeated() => $pb.PbList<ClientMessage>();
  @$core.pragma('dart2js:noInline')
  static ClientMessage getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ClientMessage>(create);
  static ClientMessage? _defaultInstance;

  ClientMessage_RequestType whichRequestType() => _ClientMessage_RequestTypeByTag[$_whichOneof(0)]!;
  void clearRequestType() => clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  TaskStartMessage get taskStart => $_getN(0);
  @$pb.TagNumber(1)
  set taskStart(TaskStartMessage v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasTaskStart() => $_has(0);
  @$pb.TagNumber(1)
  void clearTaskStart() => clearField(1);
  @$pb.TagNumber(1)
  TaskStartMessage ensureTaskStart() => $_ensure(0);

  @$pb.TagNumber(2)
  AdditionalDataMessage get additionalData => $_getN(1);
  @$pb.TagNumber(2)
  set additionalData(AdditionalDataMessage v) { setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasAdditionalData() => $_has(1);
  @$pb.TagNumber(2)
  void clearAdditionalData() => clearField(2);
  @$pb.TagNumber(2)
  AdditionalDataMessage ensureAdditionalData() => $_ensure(1);
}

enum ProcessorMessage_ResponseType {
  success, 
  error, 
  getAdditionalData, 
  notSet
}

/// / CLI's messages to the clients
class ProcessorMessage extends $pb.GeneratedMessage {
  factory ProcessorMessage({
    SuccessMessage? success,
    ErrorMessage? error,
    GetAdditionalDataMessage? getAdditionalData,
  }) {
    final $result = create();
    if (success != null) {
      $result.success = success;
    }
    if (error != null) {
      $result.error = error;
    }
    if (getAdditionalData != null) {
      $result.getAdditionalData = getAdditionalData;
    }
    return $result;
  }
  ProcessorMessage._() : super();
  factory ProcessorMessage.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ProcessorMessage.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static const $core.Map<$core.int, ProcessorMessage_ResponseType> _ProcessorMessage_ResponseTypeByTag = {
    1 : ProcessorMessage_ResponseType.success,
    2 : ProcessorMessage_ResponseType.error,
    3 : ProcessorMessage_ResponseType.getAdditionalData,
    0 : ProcessorMessage_ResponseType.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ProcessorMessage', package: const $pb.PackageName(_omitMessageNames ? '' : 'commanddash'), createEmptyInstance: create)
    ..oo(0, [1, 2, 3])
    ..aOM<SuccessMessage>(1, _omitFieldNames ? '' : 'success', subBuilder: SuccessMessage.create)
    ..aOM<ErrorMessage>(2, _omitFieldNames ? '' : 'error', subBuilder: ErrorMessage.create)
    ..aOM<GetAdditionalDataMessage>(3, _omitFieldNames ? '' : 'getAdditionalData', protoName: 'getAdditionalData', subBuilder: GetAdditionalDataMessage.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ProcessorMessage clone() => ProcessorMessage()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ProcessorMessage copyWith(void Function(ProcessorMessage) updates) => super.copyWith((message) => updates(message as ProcessorMessage)) as ProcessorMessage;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ProcessorMessage create() => ProcessorMessage._();
  ProcessorMessage createEmptyInstance() => create();
  static $pb.PbList<ProcessorMessage> createRepeated() => $pb.PbList<ProcessorMessage>();
  @$core.pragma('dart2js:noInline')
  static ProcessorMessage getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ProcessorMessage>(create);
  static ProcessorMessage? _defaultInstance;

  ProcessorMessage_ResponseType whichResponseType() => _ProcessorMessage_ResponseTypeByTag[$_whichOneof(0)]!;
  void clearResponseType() => clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  SuccessMessage get success => $_getN(0);
  @$pb.TagNumber(1)
  set success(SuccessMessage v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasSuccess() => $_has(0);
  @$pb.TagNumber(1)
  void clearSuccess() => clearField(1);
  @$pb.TagNumber(1)
  SuccessMessage ensureSuccess() => $_ensure(0);

  @$pb.TagNumber(2)
  ErrorMessage get error => $_getN(1);
  @$pb.TagNumber(2)
  set error(ErrorMessage v) { setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasError() => $_has(1);
  @$pb.TagNumber(2)
  void clearError() => clearField(2);
  @$pb.TagNumber(2)
  ErrorMessage ensureError() => $_ensure(1);

  @$pb.TagNumber(3)
  GetAdditionalDataMessage get getAdditionalData => $_getN(2);
  @$pb.TagNumber(3)
  set getAdditionalData(GetAdditionalDataMessage v) { setField(3, v); }
  @$pb.TagNumber(3)
  $core.bool hasGetAdditionalData() => $_has(2);
  @$pb.TagNumber(3)
  void clearGetAdditionalData() => clearField(3);
  @$pb.TagNumber(3)
  GetAdditionalDataMessage ensureGetAdditionalData() => $_ensure(2);
}

class TaskStartMessage extends $pb.GeneratedMessage {
  factory TaskStartMessage({
    $core.String? task,
    $core.Map<$core.String, $core.String>? args,
  }) {
    final $result = create();
    if (task != null) {
      $result.task = task;
    }
    if (args != null) {
      $result.args.addAll(args);
    }
    return $result;
  }
  TaskStartMessage._() : super();
  factory TaskStartMessage.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory TaskStartMessage.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'TaskStartMessage', package: const $pb.PackageName(_omitMessageNames ? '' : 'commanddash'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'task')
    ..m<$core.String, $core.String>(2, _omitFieldNames ? '' : 'args', entryClassName: 'TaskStartMessage.ArgsEntry', keyFieldType: $pb.PbFieldType.OS, valueFieldType: $pb.PbFieldType.OS, packageName: const $pb.PackageName('commanddash'))
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  TaskStartMessage clone() => TaskStartMessage()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  TaskStartMessage copyWith(void Function(TaskStartMessage) updates) => super.copyWith((message) => updates(message as TaskStartMessage)) as TaskStartMessage;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static TaskStartMessage create() => TaskStartMessage._();
  TaskStartMessage createEmptyInstance() => create();
  static $pb.PbList<TaskStartMessage> createRepeated() => $pb.PbList<TaskStartMessage>();
  @$core.pragma('dart2js:noInline')
  static TaskStartMessage getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<TaskStartMessage>(create);
  static TaskStartMessage? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get task => $_getSZ(0);
  @$pb.TagNumber(1)
  set task($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasTask() => $_has(0);
  @$pb.TagNumber(1)
  void clearTask() => clearField(1);

  @$pb.TagNumber(2)
  $core.Map<$core.String, $core.String> get args => $_getMap(1);
}

class AdditionalDataMessage extends $pb.GeneratedMessage {
  factory AdditionalDataMessage({
    $core.Map<$core.String, $core.String>? args,
  }) {
    final $result = create();
    if (args != null) {
      $result.args.addAll(args);
    }
    return $result;
  }
  AdditionalDataMessage._() : super();
  factory AdditionalDataMessage.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory AdditionalDataMessage.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'AdditionalDataMessage', package: const $pb.PackageName(_omitMessageNames ? '' : 'commanddash'), createEmptyInstance: create)
    ..m<$core.String, $core.String>(1, _omitFieldNames ? '' : 'args', entryClassName: 'AdditionalDataMessage.ArgsEntry', keyFieldType: $pb.PbFieldType.OS, valueFieldType: $pb.PbFieldType.OS, packageName: const $pb.PackageName('commanddash'))
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  AdditionalDataMessage clone() => AdditionalDataMessage()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  AdditionalDataMessage copyWith(void Function(AdditionalDataMessage) updates) => super.copyWith((message) => updates(message as AdditionalDataMessage)) as AdditionalDataMessage;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AdditionalDataMessage create() => AdditionalDataMessage._();
  AdditionalDataMessage createEmptyInstance() => create();
  static $pb.PbList<AdditionalDataMessage> createRepeated() => $pb.PbList<AdditionalDataMessage>();
  @$core.pragma('dart2js:noInline')
  static AdditionalDataMessage getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AdditionalDataMessage>(create);
  static AdditionalDataMessage? _defaultInstance;

  @$pb.TagNumber(1)
  $core.Map<$core.String, $core.String> get args => $_getMap(0);
}

class SuccessMessage extends $pb.GeneratedMessage {
  factory SuccessMessage({
    $core.String? message,
    $core.Map<$core.String, $core.String>? args,
  }) {
    final $result = create();
    if (message != null) {
      $result.message = message;
    }
    if (args != null) {
      $result.args.addAll(args);
    }
    return $result;
  }
  SuccessMessage._() : super();
  factory SuccessMessage.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SuccessMessage.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SuccessMessage', package: const $pb.PackageName(_omitMessageNames ? '' : 'commanddash'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'message')
    ..m<$core.String, $core.String>(2, _omitFieldNames ? '' : 'args', entryClassName: 'SuccessMessage.ArgsEntry', keyFieldType: $pb.PbFieldType.OS, valueFieldType: $pb.PbFieldType.OS, packageName: const $pb.PackageName('commanddash'))
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SuccessMessage clone() => SuccessMessage()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SuccessMessage copyWith(void Function(SuccessMessage) updates) => super.copyWith((message) => updates(message as SuccessMessage)) as SuccessMessage;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SuccessMessage create() => SuccessMessage._();
  SuccessMessage createEmptyInstance() => create();
  static $pb.PbList<SuccessMessage> createRepeated() => $pb.PbList<SuccessMessage>();
  @$core.pragma('dart2js:noInline')
  static SuccessMessage getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SuccessMessage>(create);
  static SuccessMessage? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get message => $_getSZ(0);
  @$pb.TagNumber(1)
  set message($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasMessage() => $_has(0);
  @$pb.TagNumber(1)
  void clearMessage() => clearField(1);

  @$pb.TagNumber(2)
  $core.Map<$core.String, $core.String> get args => $_getMap(1);
}

class ErrorMessage extends $pb.GeneratedMessage {
  factory ErrorMessage({
    $core.String? message,
    $core.Map<$core.String, $core.String>? args,
  }) {
    final $result = create();
    if (message != null) {
      $result.message = message;
    }
    if (args != null) {
      $result.args.addAll(args);
    }
    return $result;
  }
  ErrorMessage._() : super();
  factory ErrorMessage.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ErrorMessage.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ErrorMessage', package: const $pb.PackageName(_omitMessageNames ? '' : 'commanddash'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'message')
    ..m<$core.String, $core.String>(2, _omitFieldNames ? '' : 'args', entryClassName: 'ErrorMessage.ArgsEntry', keyFieldType: $pb.PbFieldType.OS, valueFieldType: $pb.PbFieldType.OS, packageName: const $pb.PackageName('commanddash'))
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ErrorMessage clone() => ErrorMessage()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ErrorMessage copyWith(void Function(ErrorMessage) updates) => super.copyWith((message) => updates(message as ErrorMessage)) as ErrorMessage;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ErrorMessage create() => ErrorMessage._();
  ErrorMessage createEmptyInstance() => create();
  static $pb.PbList<ErrorMessage> createRepeated() => $pb.PbList<ErrorMessage>();
  @$core.pragma('dart2js:noInline')
  static ErrorMessage getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ErrorMessage>(create);
  static ErrorMessage? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get message => $_getSZ(0);
  @$pb.TagNumber(1)
  set message($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasMessage() => $_has(0);
  @$pb.TagNumber(1)
  void clearMessage() => clearField(1);

  @$pb.TagNumber(2)
  $core.Map<$core.String, $core.String> get args => $_getMap(1);
}

class GetAdditionalDataMessage extends $pb.GeneratedMessage {
  factory GetAdditionalDataMessage({
    $core.String? kind,
    $core.Map<$core.String, $core.String>? args,
  }) {
    final $result = create();
    if (kind != null) {
      $result.kind = kind;
    }
    if (args != null) {
      $result.args.addAll(args);
    }
    return $result;
  }
  GetAdditionalDataMessage._() : super();
  factory GetAdditionalDataMessage.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetAdditionalDataMessage.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetAdditionalDataMessage', package: const $pb.PackageName(_omitMessageNames ? '' : 'commanddash'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'kind')
    ..m<$core.String, $core.String>(2, _omitFieldNames ? '' : 'args', entryClassName: 'GetAdditionalDataMessage.ArgsEntry', keyFieldType: $pb.PbFieldType.OS, valueFieldType: $pb.PbFieldType.OS, packageName: const $pb.PackageName('commanddash'))
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetAdditionalDataMessage clone() => GetAdditionalDataMessage()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetAdditionalDataMessage copyWith(void Function(GetAdditionalDataMessage) updates) => super.copyWith((message) => updates(message as GetAdditionalDataMessage)) as GetAdditionalDataMessage;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetAdditionalDataMessage create() => GetAdditionalDataMessage._();
  GetAdditionalDataMessage createEmptyInstance() => create();
  static $pb.PbList<GetAdditionalDataMessage> createRepeated() => $pb.PbList<GetAdditionalDataMessage>();
  @$core.pragma('dart2js:noInline')
  static GetAdditionalDataMessage getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetAdditionalDataMessage>(create);
  static GetAdditionalDataMessage? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get kind => $_getSZ(0);
  @$pb.TagNumber(1)
  set kind($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasKind() => $_has(0);
  @$pb.TagNumber(1)
  void clearKind() => clearField(1);

  @$pb.TagNumber(2)
  $core.Map<$core.String, $core.String> get args => $_getMap(1);
}


const _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
