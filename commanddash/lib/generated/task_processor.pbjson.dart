//
//  Generated code. Do not modify.
//  source: task_processor.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use fetchRequestDescriptor instead')
const FetchRequest$json = {
  '1': 'FetchRequest',
  '2': [
    {'1': 'type', '3': 1, '4': 1, '5': 9, '10': 'type'},
    {'1': 'args', '3': 2, '4': 3, '5': 11, '6': '.commanddash.FetchRequest.ArgsEntry', '10': 'args'},
  ],
  '3': [FetchRequest_ArgsEntry$json],
};

@$core.Deprecated('Use fetchRequestDescriptor instead')
const FetchRequest_ArgsEntry$json = {
  '1': 'ArgsEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {'1': 'value', '3': 2, '4': 1, '5': 9, '10': 'value'},
  ],
  '7': {'7': true},
};

/// Descriptor for `FetchRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List fetchRequestDescriptor = $convert.base64Decode(
    'CgxGZXRjaFJlcXVlc3QSEgoEdHlwZRgBIAEoCVIEdHlwZRI3CgRhcmdzGAIgAygLMiMuY29tbW'
    'FuZGRhc2guRmV0Y2hSZXF1ZXN0LkFyZ3NFbnRyeVIEYXJncxo3CglBcmdzRW50cnkSEAoDa2V5'
    'GAEgASgJUgNrZXkSFAoFdmFsdWUYAiABKAlSBXZhbHVlOgI4AQ==');

@$core.Deprecated('Use responseDescriptor instead')
const Response$json = {
  '1': 'Response',
  '2': [
    {'1': 'success', '3': 1, '4': 1, '5': 11, '6': '.commanddash.SuccessResponse', '9': 0, '10': 'success'},
    {'1': 'error', '3': 2, '4': 1, '5': 11, '6': '.commanddash.ErrorResponse', '9': 0, '10': 'error'},
    {'1': 'needMoreData', '3': 3, '4': 1, '5': 11, '6': '.commanddash.NeedMoreDataResponse', '9': 0, '10': 'needMoreData'},
  ],
  '8': [
    {'1': 'response_type'},
  ],
};

/// Descriptor for `Response`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List responseDescriptor = $convert.base64Decode(
    'CghSZXNwb25zZRI4CgdzdWNjZXNzGAEgASgLMhwuY29tbWFuZGRhc2guU3VjY2Vzc1Jlc3Bvbn'
    'NlSABSB3N1Y2Nlc3MSMgoFZXJyb3IYAiABKAsyGi5jb21tYW5kZGFzaC5FcnJvclJlc3BvbnNl'
    'SABSBWVycm9yEkcKDG5lZWRNb3JlRGF0YRgDIAEoCzIhLmNvbW1hbmRkYXNoLk5lZWRNb3JlRG'
    'F0YVJlc3BvbnNlSABSDG5lZWRNb3JlRGF0YUIPCg1yZXNwb25zZV90eXBl');

@$core.Deprecated('Use successResponseDescriptor instead')
const SuccessResponse$json = {
  '1': 'SuccessResponse',
  '2': [
    {'1': 'args', '3': 1, '4': 3, '5': 11, '6': '.commanddash.SuccessResponse.ArgsEntry', '10': 'args'},
  ],
  '3': [SuccessResponse_ArgsEntry$json],
};

@$core.Deprecated('Use successResponseDescriptor instead')
const SuccessResponse_ArgsEntry$json = {
  '1': 'ArgsEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {'1': 'value', '3': 2, '4': 1, '5': 9, '10': 'value'},
  ],
  '7': {'7': true},
};

/// Descriptor for `SuccessResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List successResponseDescriptor = $convert.base64Decode(
    'Cg9TdWNjZXNzUmVzcG9uc2USOgoEYXJncxgBIAMoCzImLmNvbW1hbmRkYXNoLlN1Y2Nlc3NSZX'
    'Nwb25zZS5BcmdzRW50cnlSBGFyZ3MaNwoJQXJnc0VudHJ5EhAKA2tleRgBIAEoCVIDa2V5EhQK'
    'BXZhbHVlGAIgASgJUgV2YWx1ZToCOAE=');

@$core.Deprecated('Use errorResponseDescriptor instead')
const ErrorResponse$json = {
  '1': 'ErrorResponse',
  '2': [
    {'1': 'errorMessage', '3': 1, '4': 1, '5': 9, '10': 'errorMessage'},
  ],
};

/// Descriptor for `ErrorResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List errorResponseDescriptor = $convert.base64Decode(
    'Cg1FcnJvclJlc3BvbnNlEiIKDGVycm9yTWVzc2FnZRgBIAEoCVIMZXJyb3JNZXNzYWdl');

@$core.Deprecated('Use needMoreDataResponseDescriptor instead')
const NeedMoreDataResponse$json = {
  '1': 'NeedMoreDataResponse',
  '2': [
    {'1': 'kind', '3': 1, '4': 1, '5': 9, '10': 'kind'},
    {'1': 'args', '3': 2, '4': 3, '5': 11, '6': '.commanddash.NeedMoreDataResponse.ArgsEntry', '10': 'args'},
  ],
  '3': [NeedMoreDataResponse_ArgsEntry$json],
};

@$core.Deprecated('Use needMoreDataResponseDescriptor instead')
const NeedMoreDataResponse_ArgsEntry$json = {
  '1': 'ArgsEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {'1': 'value', '3': 2, '4': 1, '5': 9, '10': 'value'},
  ],
  '7': {'7': true},
};

/// Descriptor for `NeedMoreDataResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List needMoreDataResponseDescriptor = $convert.base64Decode(
    'ChROZWVkTW9yZURhdGFSZXNwb25zZRISCgRraW5kGAEgASgJUgRraW5kEj8KBGFyZ3MYAiADKA'
    'syKy5jb21tYW5kZGFzaC5OZWVkTW9yZURhdGFSZXNwb25zZS5BcmdzRW50cnlSBGFyZ3MaNwoJ'
    'QXJnc0VudHJ5EhAKA2tleRgBIAEoCVIDa2V5EhQKBXZhbHVlGAIgASgJUgV2YWx1ZToCOAE=');

