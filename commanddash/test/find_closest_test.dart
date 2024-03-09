@Timeout(const Duration(seconds: 160))
import 'dart:convert';
import 'dart:io';
import 'package:async/async.dart';
import 'package:test/test.dart';

void main() {
  test('Valid Task Kind with Additional Data', () async {
    final process = await Process.start(
        'dart', ['run', 'bin/commanddash.dart', 'process'],
        runInShell: true);
    final processOutput =
        process.stdout.transform(utf8.decoder).asBroadcastStream();
    final queue = StreamQueue<String>(processOutput);
    processOutput.listen((event) {});
    // send a task start message
    process.stdin.writeln(jsonEncode({
      'method': 'task_start',
      'id': 1,
      'params': {
        'data': {
          "query": "Where is the themeing of the app?",
          "workspacePath":
              "/Users/keval/Desktop/dev/welltested/projects/RickAndMortyAndFlutter",
          "apiKey": "AIzaSyDuPgJQG2Q43VFAZ6Xr-3_5NGIuAdVEMnQ",
        },
        'kind': 'find_closest_files',
      }
    }));
    // expect the server to ask for additional data
    var result = await queue.next;
    print(result);
    expect(
        jsonDecode(result),
        equals({
          'method': 'process_step',
          'id': 1,
          'params': {'kind': 'cache', 'args': {}}
        }));
    // send additional data
    process.stdin.writeln(jsonEncode({
      'method': 'process_step_response',
      'id': 1,
      'params': {'value': '{}'}
    }));
    result = await queue.next;
    print(result);
    expect(
        jsonDecode(result),
        equals({
          'method': 'log',
          'id': 1,
          'params': {'message': 'Cache recieved successfully', 'data': {}}
        }));
    result = await queue.next;
    print(result);
    expect(jsonDecode(result)['method'], equals('result'));
    // close the process
    process.stdin.writeln('exit');
    await expectLater(await process.exitCode, 0);
  });
}
