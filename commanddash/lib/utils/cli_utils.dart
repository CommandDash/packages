import 'dart:io';

class CLIUtils {
  // Terminate the CLI when the client inputs "exit"
  static void terminateOnExit() {
    stdin.listen((List<int> data) {
      final input = String.fromCharCodes(data).trim();
      if (input == "exit") {
        exit(0);
      }
    });
  }
}
