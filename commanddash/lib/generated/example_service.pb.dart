//
//  Generated code. Do not modify.
//  source: example_service.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

class FetchRequest extends $pb.GeneratedMessage {
  factory FetchRequest({
    $core.String? type,
    $core.Map<$core.String, $core.String>? args,
  }) {
    final $result = create();
    if (type != null) {
      $result.type = type;
    }
    if (args != null) {
      $result.args.addAll(args);
    }
    return $result;
  }
  FetchRequest._() : super();
  factory FetchRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory FetchRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'FetchRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'commanddash'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'type')
    ..m<$core.String, $core.String>(2, _omitFieldNames ? '' : 'args', entryClassName: 'FetchRequest.ArgsEntry', keyFieldType: $pb.PbFieldType.OS, valueFieldType: $pb.PbFieldType.OS, packageName: const $pb.PackageName('commanddash'))
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  FetchRequest clone() => FetchRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  FetchRequest copyWith(void Function(FetchRequest) updates) => super.copyWith((message) => updates(message as FetchRequest)) as FetchRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static FetchRequest create() => FetchRequest._();
  FetchRequest createEmptyInstance() => create();
  static $pb.PbList<FetchRequest> createRepeated() => $pb.PbList<FetchRequest>();
  @$core.pragma('dart2js:noInline')
  static FetchRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<FetchRequest>(create);
  static FetchRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get type => $_getSZ(0);
  @$pb.TagNumber(1)
  set type($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasType() => $_has(0);
  @$pb.TagNumber(1)
  void clearType() => clearField(1);

  @$pb.TagNumber(2)
  $core.Map<$core.String, $core.String> get args => $_getMap(1);
}

enum Response_ResponseType {
  success, 
  error, 
  needMoreData, 
  notSet
}

/// A message that can hold either success, error or need more data information
class Response extends $pb.GeneratedMessage {
  factory Response({
    SuccessResponse? success,
    ErrorResponse? error,
    NeedMoreDataResponse? needMoreData,
  }) {
    final $result = create();
    if (success != null) {
      $result.success = success;
    }
    if (error != null) {
      $result.error = error;
    }
    if (needMoreData != null) {
      $result.needMoreData = needMoreData;
    }
    return $result;
  }
  Response._() : super();
  factory Response.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Response.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static const $core.Map<$core.int, Response_ResponseType> _Response_ResponseTypeByTag = {
    1 : Response_ResponseType.success,
    2 : Response_ResponseType.error,
    3 : Response_ResponseType.needMoreData,
    0 : Response_ResponseType.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Response', package: const $pb.PackageName(_omitMessageNames ? '' : 'commanddash'), createEmptyInstance: create)
    ..oo(0, [1, 2, 3])
    ..aOM<SuccessResponse>(1, _omitFieldNames ? '' : 'success', subBuilder: SuccessResponse.create)
    ..aOM<ErrorResponse>(2, _omitFieldNames ? '' : 'error', subBuilder: ErrorResponse.create)
    ..aOM<NeedMoreDataResponse>(3, _omitFieldNames ? '' : 'needMoreData', protoName: 'needMoreData', subBuilder: NeedMoreDataResponse.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  Response clone() => Response()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  Response copyWith(void Function(Response) updates) => super.copyWith((message) => updates(message as Response)) as Response;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Response create() => Response._();
  Response createEmptyInstance() => create();
  static $pb.PbList<Response> createRepeated() => $pb.PbList<Response>();
  @$core.pragma('dart2js:noInline')
  static Response getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Response>(create);
  static Response? _defaultInstance;

  Response_ResponseType whichResponseType() => _Response_ResponseTypeByTag[$_whichOneof(0)]!;
  void clearResponseType() => clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  SuccessResponse get success => $_getN(0);
  @$pb.TagNumber(1)
  set success(SuccessResponse v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasSuccess() => $_has(0);
  @$pb.TagNumber(1)
  void clearSuccess() => clearField(1);
  @$pb.TagNumber(1)
  SuccessResponse ensureSuccess() => $_ensure(0);

  @$pb.TagNumber(2)
  ErrorResponse get error => $_getN(1);
  @$pb.TagNumber(2)
  set error(ErrorResponse v) { setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasError() => $_has(1);
  @$pb.TagNumber(2)
  void clearError() => clearField(2);
  @$pb.TagNumber(2)
  ErrorResponse ensureError() => $_ensure(1);

  @$pb.TagNumber(3)
  NeedMoreDataResponse get needMoreData => $_getN(2);
  @$pb.TagNumber(3)
  set needMoreData(NeedMoreDataResponse v) { setField(3, v); }
  @$pb.TagNumber(3)
  $core.bool hasNeedMoreData() => $_has(2);
  @$pb.TagNumber(3)
  void clearNeedMoreData() => clearField(3);
  @$pb.TagNumber(3)
  NeedMoreDataResponse ensureNeedMoreData() => $_ensure(2);
}

class SuccessResponse extends $pb.GeneratedMessage {
  factory SuccessResponse({
    $core.Map<$core.String, $core.String>? args,
  }) {
    final $result = create();
    if (args != null) {
      $result.args.addAll(args);
    }
    return $result;
  }
  SuccessResponse._() : super();
  factory SuccessResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SuccessResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SuccessResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'commanddash'), createEmptyInstance: create)
    ..m<$core.String, $core.String>(1, _omitFieldNames ? '' : 'args', entryClassName: 'SuccessResponse.ArgsEntry', keyFieldType: $pb.PbFieldType.OS, valueFieldType: $pb.PbFieldType.OS, packageName: const $pb.PackageName('commanddash'))
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SuccessResponse clone() => SuccessResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SuccessResponse copyWith(void Function(SuccessResponse) updates) => super.copyWith((message) => updates(message as SuccessResponse)) as SuccessResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SuccessResponse create() => SuccessResponse._();
  SuccessResponse createEmptyInstance() => create();
  static $pb.PbList<SuccessResponse> createRepeated() => $pb.PbList<SuccessResponse>();
  @$core.pragma('dart2js:noInline')
  static SuccessResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SuccessResponse>(create);
  static SuccessResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.Map<$core.String, $core.String> get args => $_getMap(0);
}

class ErrorResponse extends $pb.GeneratedMessage {
  factory ErrorResponse({
    $core.String? errorMessage,
  }) {
    final $result = create();
    if (errorMessage != null) {
      $result.errorMessage = errorMessage;
    }
    return $result;
  }
  ErrorResponse._() : super();
  factory ErrorResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ErrorResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ErrorResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'commanddash'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'errorMessage', protoName: 'errorMessage')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ErrorResponse clone() => ErrorResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ErrorResponse copyWith(void Function(ErrorResponse) updates) => super.copyWith((message) => updates(message as ErrorResponse)) as ErrorResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ErrorResponse create() => ErrorResponse._();
  ErrorResponse createEmptyInstance() => create();
  static $pb.PbList<ErrorResponse> createRepeated() => $pb.PbList<ErrorResponse>();
  @$core.pragma('dart2js:noInline')
  static ErrorResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ErrorResponse>(create);
  static ErrorResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get errorMessage => $_getSZ(0);
  @$pb.TagNumber(1)
  set errorMessage($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasErrorMessage() => $_has(0);
  @$pb.TagNumber(1)
  void clearErrorMessage() => clearField(1);
}

/// Response indicating processor needs further data
class NeedMoreDataResponse extends $pb.GeneratedMessage {
  factory NeedMoreDataResponse({
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
  NeedMoreDataResponse._() : super();
  factory NeedMoreDataResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory NeedMoreDataResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'NeedMoreDataResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'commanddash'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'kind')
    ..m<$core.String, $core.String>(2, _omitFieldNames ? '' : 'args', entryClassName: 'NeedMoreDataResponse.ArgsEntry', keyFieldType: $pb.PbFieldType.OS, valueFieldType: $pb.PbFieldType.OS, packageName: const $pb.PackageName('commanddash'))
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  NeedMoreDataResponse clone() => NeedMoreDataResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  NeedMoreDataResponse copyWith(void Function(NeedMoreDataResponse) updates) => super.copyWith((message) => updates(message as NeedMoreDataResponse)) as NeedMoreDataResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static NeedMoreDataResponse create() => NeedMoreDataResponse._();
  NeedMoreDataResponse createEmptyInstance() => create();
  static $pb.PbList<NeedMoreDataResponse> createRepeated() => $pb.PbList<NeedMoreDataResponse>();
  @$core.pragma('dart2js:noInline')
  static NeedMoreDataResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<NeedMoreDataResponse>(create);
  static NeedMoreDataResponse? _defaultInstance;

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
