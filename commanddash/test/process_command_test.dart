import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:async/async.dart';
import 'package:test/test.dart';

///TODO[FIX]: Tests fail when ran at once.
void main() {
  group('Task with process step, ', () {
    test('Valid Task Kind', () async {
      final process = await Process.start(
          'dart', ['run', 'bin/commanddash.dart', 'process'],
          runInShell: true);
      final processOutput = process.stdout.transform(utf8.decoder);
      final queue = StreamQueue<String>(processOutput);
      // send a task start message
      process.stdin.writeln(jsonEncode({
        'method': 'task_start',
        'id': 1,
        'params': {
          'data': {'example': 'data'},
          'kind': 'random_task_with_step',
        }
      }));
      // expect the server to ask for additional data
      var result = await queue.next;
      expect(
          jsonDecode(result),
          equals({
            'method': 'step',
            'id': 1,
            'params': {'kind': 'step_data_kind', 'args': {}}
          }));
      // send additional data
      process.stdin.writeln(jsonEncode({
        'method': 'step_response',
        'id': 1,
        'kind': 'step_data_kind',
        'data': {'value': 'unique_value'}
      }));
      result = await queue.next;
      expect(
          jsonDecode(result),
          equals({
            'method': 'result',
            'id': 1,
            'params': {'message': 'TASK_COMPLETED', 'data': {}}
          }));

      // close the process
      process.stdin.writeln('exit');
      await expectLater(await process.exitCode, 0);
    });
    test('Invalid Task Kind', () async {
      final process = await Process.start(
          'dart', ['run', 'bin/commanddash.dart', 'process'],
          runInShell: true);
      final processOutput = process.stdout.transform(utf8.decoder);
      final queue = StreamQueue<String>(processOutput);
      // send an invalid task start message
      process.stdin.writeln(jsonEncode({
        'method': 'task_start',
        'id': 1,
        'params': {
          'data': {'example': 'data'},
          'kind': 'invalid_task',
        }
      }));

      var result = await queue.next;
      expect(
          jsonDecode(result),
          equals({
            'method': 'error',
            'id': 1,
            'params': {
              'message': 'INVALID_TASK_KIND',
              'data': {},
            }
          }));

      // close the process
      process.stdin.writeln('exit');
      await expectLater(await process.exitCode, 0);
    });
  });

  group('Task with side operation, ', () {
    test('Valid Task Kind executes succesfully', () async {
      final process = await Process.start(
          'dart', ['run', 'bin/commanddash.dart', 'process'],
          runInShell: true);

      final processOutput = process.stdout.transform(utf8.decoder);
      final queue = StreamQueue<String>(processOutput);
      // send a task start message
      process.stdin.writeln(jsonEncode({
        'method': 'task_start',
        'id': 1,
        'params': {
          'data': {'example': 'data'},
          'kind': 'random_task_with_side_operation',
        }
      }));
      // expect the server to send an operation message
      var result = await queue.next;
      expect(
          jsonDecode(result),
          equals({
            'id': -1,
            'method': 'operation',
            'params': {'kind': 'operation_data_kind', 'args': {}}
          }));
      // send an operation response message
      process.stdin.writeln(jsonEncode({
        'method': 'operation_response',
        'kind': 'operation_data_kind',
        'data': {'value': 'operation_value'}
      }));
      result = await queue.next;
      expect(
          jsonDecode(result),
          equals({
            'method': 'result',
            'id': 1,
            'params': {'message': 'TASK_COMPLETED', 'data': {}}
          }));

      // close the process
      process.stdin.writeln('exit');
      await expectLater(await process.exitCode, 0);
    });
    test('Invalid Task Kind never finishes', () async {
      final process = await Process.start(
          'dart', ['run', 'bin/commanddash.dart', 'process'],
          runInShell: true);
      final processOutput = process.stdout.transform(utf8.decoder);
      final queue = StreamQueue<String>(processOutput);
      // send a task start message
      process.stdin.writeln(jsonEncode({
        'method': 'task_start',
        'id': 1,
        'params': {
          'data': {'example': 'data'},
          'kind': 'random_task_with_side_operation',
        }
      }));
      // expect the server to send an operation message
      var result = await queue.next;
      expect(
          jsonDecode(result),
          equals({
            'id': -1,
            'method': 'operation',
            'params': {'kind': 'operation_data_kind', 'args': {}}
          }));
      // send an operation response message
      process.stdin.writeln(jsonEncode({
        'method': 'operation_response',
        'kind': 'operation_data_kind_wrong',
        'data': {'value': 'operation_value'}
      }));

      await expectLater(
        queue.next.timeout(Duration(milliseconds: 50)),
        throwsA(isA<TimeoutException>()),
      );
    });
  });
}
