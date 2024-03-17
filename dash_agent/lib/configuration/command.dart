import 'package:dash_agent/variables/dash_input.dart';
import 'package:dash_agent/steps/steps.dart';
import 'package:dash_agent/variables/dash_output.dart';

abstract class Command {
  Command();

  String get slug;
  String get intent;
  String get textFieldLayout;
  List<DashInput> get registerInputs;
  List<DashOutput> get registerOutputs;
  List<Step> get steps;

  Future<Map<String, dynamic>> process() async {
    final Map<String, dynamic> processedJson = {};
    processedJson['slug'] = slug;
    processedJson['intent'] = intent;
    processedJson['text_field_layout'] = textFieldLayout;
    processedJson['registered_inputs'] = [];
    for (final input in registerInputs) {
      processedJson['registered_inputs'].add(await input.process());
    }
    processedJson['registered_output'] = [];
    for (final output in registerOutputs) {
      processedJson['registered_output'].add(await output.process());
    }
    processedJson['steps'] = [];
    for (final step in steps) {
      processedJson['steps'].add(await step.process());
    }
    return processedJson;
  }
}
