import 'package:args/command_runner.dart';
import 'package:commanddash/runner.dart';

void main(List<String> arguments) async {
  var runner = CommandRunner("commanddash", "CLI enhancements for Dash AI")
    ..addCommand(ProcessCommand());
  await runner.run(arguments);
}
