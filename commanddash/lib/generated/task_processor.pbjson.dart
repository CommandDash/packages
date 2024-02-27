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

@$core.Deprecated('Use clientMessageDescriptor instead')
const ClientMessage$json = {
  '1': 'ClientMessage',
  '2': [
    {'1': 'taskStart', '3': 1, '4': 1, '5': 11, '6': '.commanddash.TaskStartMessage', '9': 0, '10': 'taskStart'},
    {'1': 'additionalData', '3': 2, '4': 1, '5': 11, '6': '.commanddash.AdditionalDataMessage', '9': 0, '10': 'additionalData'},
  ],
  '8': [
    {'1': 'request_type'},
  ],
};

/// Descriptor for `ClientMessage`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List clientMessageDescriptor = $convert.base64Decode(
    'Cg1DbGllbnRNZXNzYWdlEj0KCXRhc2tTdGFydBgBIAEoCzIdLmNvbW1hbmRkYXNoLlRhc2tTdG'
    'FydE1lc3NhZ2VIAFIJdGFza1N0YXJ0EkwKDmFkZGl0aW9uYWxEYXRhGAIgASgLMiIuY29tbWFu'
    'ZGRhc2guQWRkaXRpb25hbERhdGFNZXNzYWdlSABSDmFkZGl0aW9uYWxEYXRhQg4KDHJlcXVlc3'
    'RfdHlwZQ==');

@$core.Deprecated('Use processorMessageDescriptor instead')
const ProcessorMessage$json = {
  '1': 'ProcessorMessage',
  '2': [
    {'1': 'success', '3': 1, '4': 1, '5': 11, '6': '.commanddash.SuccessMessage', '9': 0, '10': 'success'},
    {'1': 'error', '3': 2, '4': 1, '5': 11, '6': '.commanddash.ErrorMessage', '9': 0, '10': 'error'},
    {'1': 'getAdditionalData', '3': 3, '4': 1, '5': 11, '6': '.commanddash.GetAdditionalDataMessage', '9': 0, '10': 'getAdditionalData'},
  ],
  '8': [
    {'1': 'response_type'},
  ],
};

/// Descriptor for `ProcessorMessage`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List processorMessageDescriptor = $convert.base64Decode(
    'ChBQcm9jZXNzb3JNZXNzYWdlEjcKB3N1Y2Nlc3MYASABKAsyGy5jb21tYW5kZGFzaC5TdWNjZX'
    'NzTWVzc2FnZUgAUgdzdWNjZXNzEjEKBWVycm9yGAIgASgLMhkuY29tbWFuZGRhc2guRXJyb3JN'
    'ZXNzYWdlSABSBWVycm9yElUKEWdldEFkZGl0aW9uYWxEYXRhGAMgASgLMiUuY29tbWFuZGRhc2'
    'guR2V0QWRkaXRpb25hbERhdGFNZXNzYWdlSABSEWdldEFkZGl0aW9uYWxEYXRhQg8KDXJlc3Bv'
    'bnNlX3R5cGU=');

@$core.Deprecated('Use taskStartMessageDescriptor instead')
const TaskStartMessage$json = {
  '1': 'TaskStartMessage',
  '2': [
    {'1': 'task', '3': 1, '4': 1, '5': 9, '10': 'task'},
    {'1': 'args', '3': 2, '4': 3, '5': 11, '6': '.commanddash.TaskStartMessage.ArgsEntry', '10': 'args'},
  ],
  '3': [TaskStartMessage_ArgsEntry$json],
};

@$core.Deprecated('Use taskStartMessageDescriptor instead')
const TaskStartMessage_ArgsEntry$json = {
  '1': 'ArgsEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {'1': 'value', '3': 2, '4': 1, '5': 9, '10': 'value'},
  ],
  '7': {'7': true},
};

/// Descriptor for `TaskStartMessage`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List taskStartMessageDescriptor = $convert.base64Decode(
    'ChBUYXNrU3RhcnRNZXNzYWdlEhIKBHRhc2sYASABKAlSBHRhc2sSOwoEYXJncxgCIAMoCzInLm'
    'NvbW1hbmRkYXNoLlRhc2tTdGFydE1lc3NhZ2UuQXJnc0VudHJ5UgRhcmdzGjcKCUFyZ3NFbnRy'
    'eRIQCgNrZXkYASABKAlSA2tleRIUCgV2YWx1ZRgCIAEoCVIFdmFsdWU6AjgB');

@$core.Deprecated('Use additionalDataMessageDescriptor instead')
const AdditionalDataMessage$json = {
  '1': 'AdditionalDataMessage',
  '2': [
    {'1': 'args', '3': 1, '4': 3, '5': 11, '6': '.commanddash.AdditionalDataMessage.ArgsEntry', '10': 'args'},
  ],
  '3': [AdditionalDataMessage_ArgsEntry$json],
};

@$core.Deprecated('Use additionalDataMessageDescriptor instead')
const AdditionalDataMessage_ArgsEntry$json = {
  '1': 'ArgsEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {'1': 'value', '3': 2, '4': 1, '5': 9, '10': 'value'},
  ],
  '7': {'7': true},
};

/// Descriptor for `AdditionalDataMessage`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List additionalDataMessageDescriptor = $convert.base64Decode(
    'ChVBZGRpdGlvbmFsRGF0YU1lc3NhZ2USQAoEYXJncxgBIAMoCzIsLmNvbW1hbmRkYXNoLkFkZG'
    'l0aW9uYWxEYXRhTWVzc2FnZS5BcmdzRW50cnlSBGFyZ3MaNwoJQXJnc0VudHJ5EhAKA2tleRgB'
    'IAEoCVIDa2V5EhQKBXZhbHVlGAIgASgJUgV2YWx1ZToCOAE=');

@$core.Deprecated('Use successMessageDescriptor instead')
const SuccessMessage$json = {
  '1': 'SuccessMessage',
  '2': [
    {'1': 'message', '3': 1, '4': 1, '5': 9, '10': 'message'},
    {'1': 'args', '3': 2, '4': 3, '5': 11, '6': '.commanddash.SuccessMessage.ArgsEntry', '10': 'args'},
  ],
  '3': [SuccessMessage_ArgsEntry$json],
};

@$core.Deprecated('Use successMessageDescriptor instead')
const SuccessMessage_ArgsEntry$json = {
  '1': 'ArgsEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {'1': 'value', '3': 2, '4': 1, '5': 9, '10': 'value'},
  ],
  '7': {'7': true},
};

/// Descriptor for `SuccessMessage`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List successMessageDescriptor = $convert.base64Decode(
    'Cg5TdWNjZXNzTWVzc2FnZRIYCgdtZXNzYWdlGAEgASgJUgdtZXNzYWdlEjkKBGFyZ3MYAiADKA'
    'syJS5jb21tYW5kZGFzaC5TdWNjZXNzTWVzc2FnZS5BcmdzRW50cnlSBGFyZ3MaNwoJQXJnc0Vu'
    'dHJ5EhAKA2tleRgBIAEoCVIDa2V5EhQKBXZhbHVlGAIgASgJUgV2YWx1ZToCOAE=');

@$core.Deprecated('Use errorMessageDescriptor instead')
const ErrorMessage$json = {
  '1': 'ErrorMessage',
  '2': [
    {'1': 'message', '3': 1, '4': 1, '5': 9, '10': 'message'},
    {'1': 'args', '3': 2, '4': 3, '5': 11, '6': '.commanddash.ErrorMessage.ArgsEntry', '10': 'args'},
  ],
  '3': [ErrorMessage_ArgsEntry$json],
};

@$core.Deprecated('Use errorMessageDescriptor instead')
const ErrorMessage_ArgsEntry$json = {
  '1': 'ArgsEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {'1': 'value', '3': 2, '4': 1, '5': 9, '10': 'value'},
  ],
  '7': {'7': true},
};

/// Descriptor for `ErrorMessage`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List errorMessageDescriptor = $convert.base64Decode(
    'CgxFcnJvck1lc3NhZ2USGAoHbWVzc2FnZRgBIAEoCVIHbWVzc2FnZRI3CgRhcmdzGAIgAygLMi'
    'MuY29tbWFuZGRhc2guRXJyb3JNZXNzYWdlLkFyZ3NFbnRyeVIEYXJncxo3CglBcmdzRW50cnkS'
    'EAoDa2V5GAEgASgJUgNrZXkSFAoFdmFsdWUYAiABKAlSBXZhbHVlOgI4AQ==');

@$core.Deprecated('Use getAdditionalDataMessageDescriptor instead')
const GetAdditionalDataMessage$json = {
  '1': 'GetAdditionalDataMessage',
  '2': [
    {'1': 'kind', '3': 1, '4': 1, '5': 9, '10': 'kind'},
    {'1': 'args', '3': 2, '4': 3, '5': 11, '6': '.commanddash.GetAdditionalDataMessage.ArgsEntry', '10': 'args'},
  ],
  '3': [GetAdditionalDataMessage_ArgsEntry$json],
};

@$core.Deprecated('Use getAdditionalDataMessageDescriptor instead')
const GetAdditionalDataMessage_ArgsEntry$json = {
  '1': 'ArgsEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {'1': 'value', '3': 2, '4': 1, '5': 9, '10': 'value'},
  ],
  '7': {'7': true},
};

/// Descriptor for `GetAdditionalDataMessage`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getAdditionalDataMessageDescriptor = $convert.base64Decode(
    'ChhHZXRBZGRpdGlvbmFsRGF0YU1lc3NhZ2USEgoEa2luZBgBIAEoCVIEa2luZBJDCgRhcmdzGA'
    'IgAygLMi8uY29tbWFuZGRhc2guR2V0QWRkaXRpb25hbERhdGFNZXNzYWdlLkFyZ3NFbnRyeVIE'
    'YXJncxo3CglBcmdzRW50cnkSEAoDa2V5GAEgASgJUgNrZXkSFAoFdmFsdWUYAiABKAlSBXZhbH'
    'VlOgI4AQ==');

