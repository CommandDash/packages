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
    process.stdin.writeln(
      jsonEncode(
        {
          "method": "agent-execute",
          "id": 1,
          "params": {
            "inputs": [
              {
                "id": "736841542",
                "type": "string_input",
                "value":
                    "Where do you think AI is heading in the field of programming? Give a short answer."
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
                "type": "prompt_query",
                "query": "736841542",
                "post_process": {"type": "raw"},
                "output": "90611917"
              }
            ]
          }
        },
      ),
    );
    var result = await queue.next;
    print(result);
    expect(jsonDecode(result)['method'], equals('result'));
    // close the process
    process.stdin.writeln('exit');
    await expectLater(await process.exitCode, 0);
  });
}
