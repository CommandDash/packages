import 'dart:convert';
import 'dart:io';
import 'package:async/async.dart';
import 'package:test/test.dart';

void main() {
  test('Valid Task Kind with Additional Data', () async {
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
        'kind': 'random_task',
      }
    }));
    // expect the server to ask for additional data
    var result = await queue.next;
    expect(
        jsonDecode(result),
        equals({
          'method': 'process_step',
          'id': 1,
          'params': {'kind': 'random_data_kind', 'args': {}}
        }));
    // send additional data
    process.stdin.writeln(jsonEncode({
      'method': 'process_step_response',
      'id': 1,
      'params': {'value': 'unique_value'}
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
}
