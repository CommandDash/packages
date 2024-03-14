@Timeout(Duration(seconds: 300))
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
      "method": "agent-execute",
      "id": 1,
      "params": {
        "inputs": [
          {
            "id": "736841542",
            "type": "string_input",
            "value": "Where is the themeing of the app?"
          }
        ],
        "outputs": [],
        "authdetails": {
          "type": "gemini",
          "key": "AIzaSyCUgTsTlr_zgfM7eElSYC488j7msF2b948",
          "githubToken": ""
        },
        "steps": [
          {
            "type": "search_in_workspace",
            "query": "<422243666>",
            "workspace_object_type": "all",
            "workspacePath":
                "/Users/keval/Desktop/dev/welltested/projects/dart_files",
            "output": "436621806"
          }
        ]
      }
    }));
    // expect the server to ask for additional data
    var result = await queue.next;
    expect(
        jsonDecode(result),
        equals({
          "id": 1,
          "method": "step",
          "params": {"kind": "cache", "args": {}}
        }));
    // send additional data
    process.stdin.writeln(jsonEncode({
      "method": "step_response",
      "id": 1,
      "kind": "cache_response",
      "data": {"value": "{}"}
    }));
    result = await queue.next;
    print(result);
    expect(jsonDecode(result)['method'], equals('result'));
    // close the process
    process.stdin.writeln('exit');
    await expectLater(await process.exitCode, 0);
  });
}
