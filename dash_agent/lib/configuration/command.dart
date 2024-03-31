import 'package:dash_agent/variables/dash_input.dart';
import 'package:dash_agent/steps/steps.dart';
import 'package:dash_agent/variables/dash_output.dart';

abstract class Command {
  String get version => '0.0.1';
  Command();

  String get slug;
  String get intent;
  String get textFieldLayout;
  List<DashInput> get registerInputs;

  List<Step> steps();

  Future<Map<String, dynamic>> process() async {
    final Map<String, dynamic> processedJson = {};
    List<DashOutput> registerOutputs = [];
    processedJson['slug'] = slug;
    processedJson['intent'] = intent;
    processedJson['text_field_layout'] = textFieldLayout;

    processedJson['steps'] = [];
    for (final step in steps()) {
      registerOutputs.addAll(step.dashOutputs.nonNulls);
      processedJson['steps'].add(await step.process());
    }

    processedJson['registered_inputs'] = [];
    for (final input in registerInputs) {
      processedJson['registered_inputs'].add(await input.process());
    }

    processedJson['registered_outputs'] = [];
    for (final output in registerOutputs.toSet().toList()) {
      processedJson['registered_outputs'].add(await output.process());
    }

    processedJson['version'] = version;
    return processedJson;
  }
}
