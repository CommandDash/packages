import 'dart:convert';
import 'dart:io';
import 'package:async/async.dart';
import 'package:test/test.dart';

void main() {
  test('process command', () async {
    final process = await Process.start(
        'dart', ['run', 'bin/commanddash.dart', 'process'],
        runInShell: true);

    final processOutput = process.stdout.transform(utf8.decoder);
    final queue = StreamQueue<String>(processOutput);

    // send a task start message
    process.stdin.writeln(jsonEncode({
      'method': 'taskStart',
      'id': 'task-1',
      'params': {
        'data': {'example': 'data'},
        'kind': 'randomTask',
      }
    }));
    var result = await queue.next;
    expect(
        jsonDecode(result),
        equals({
          'method': 'result',
          'id': 'task-1',
          'result': {
            'message': 'TASK_COMPLETED',
            'data': {},
          }
        }));

    // send an invalid task start message
    process.stdin.writeln(jsonEncode({
      'method': 'taskStart',
      'id': 'task-2',
      'params': {
        'data': {'example': 'data'},
        'kind': 'invalidTask',
      }
    }));
    result = await queue.next;
    expect(
        jsonDecode(result),
        equals({
          'method': 'error',
          'id': 'task-2',
          'error': {
            'message': 'INVALID_TASK_KIND',
            'data': {},
          }
        }));

    // close the process
    process.stdin.writeln('exit');
    await expectLater(process.exitCode, 0);
  });
}
