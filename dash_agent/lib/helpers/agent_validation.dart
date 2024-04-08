import 'package:dash_agent/extension/list_extension.dart';

class AgentValidation {
  static Map<String, Map<String, String>>? validateDashCommandVariableUsage(
      Map<String, dynamic> commandJson) {
    final registeredInputs =
        (commandJson['registered_inputs']?.cast<Map<String, dynamic>>())
            .map<String>((Map<String, dynamic> input) => input['id'] as String)
            .toList();
    final registeredOutput = (commandJson['registered_outputs']
            ?.cast<Map<String, dynamic>>())
        .map<String>((Map<String, dynamic> output) => output['id'] as String)
        .toList();

    final registeredVariables = <String>[
      ...registeredInputs,
      ...registeredOutput
    ];
    final nonRegisteredStepVariables = <String, Map<String, String>>{};
    final steps = commandJson['steps']?.cast<Map<String, dynamic>>();
    for (final step in steps) {
      final type = step['type'];
      if (step['type'] == 'search_in_sources') {
        final validationResponse =
            _validateMachingDocumentStep(step, registeredVariables);
        if (validationResponse != null) {
          if (!nonRegisteredStepVariables.containsKey(type)) {
            nonRegisteredStepVariables[type] = {};
          }
          nonRegisteredStepVariables[type]
              ?.addAll({'MachingDocumentStep': validationResponse});
        }
      } else if (step['type'] == 'search_in_workspace') {
        final validationResponse =
            _validateWorkspaceQueryStep(step, registeredVariables);
        if (validationResponse != null) {
          if (!nonRegisteredStepVariables.containsKey(type)) {
            nonRegisteredStepVariables[type] = {};
          }
          nonRegisteredStepVariables[type]
              ?.addAll({'WorkspaceQueryStep': validationResponse});
        }
      } else if (step['type'] == 'prompt_query') {
        final validationResponse =
            _validatePromptQueryStep(step, registeredVariables);
        if (validationResponse != null) {
          if (!nonRegisteredStepVariables.containsKey(type)) {
            nonRegisteredStepVariables[type] = {};
          }
          nonRegisteredStepVariables[type]
              ?.addAll({'PromptQueryStep': validationResponse});
        }
      } else if (step['type'] == 'append_to_chat') {
        final validationResponse =
            _validateAppendToChatStep(step, registeredVariables);
        if (validationResponse != null) {
          if (!nonRegisteredStepVariables.containsKey(type)) {
            nonRegisteredStepVariables[type] = {};
          }
          nonRegisteredStepVariables[type]
              ?.addAll({'AppendToChatStep': validationResponse});
        }
      }
    }

    if (nonRegisteredStepVariables.isEmpty) {
      return null;
    }
    return nonRegisteredStepVariables;
  }

  static String? _validateAppendToChatStep(
      Map<String, dynamic> step, List<String> registeredVariables) {
    final nonRegisteredValueIds = _extractNonRegisteredVariablesInStep(
        step['value'], registeredVariables);

    if (nonRegisteredValueIds.isNotEmpty) {
      return _invalidDashVariableMessage(['value']);
    }
    return null;
  }

  static String? _validatePromptQueryStep(
      Map<String, dynamic> step, List<String> registeredVariables) {
    final nonRegisteredPromptIds = _extractNonRegisteredVariablesInStep(
        step['prompt'], registeredVariables);
    final stepOutputs = step['outputs'] as List<String>;
    final nonRegisteredOutputIds = [
      for (final output in stepOutputs)
        ..._extractNonRegisteredVariablesInStep(output, registeredVariables)
    ];

    if (nonRegisteredPromptIds.isNotEmpty &&
        nonRegisteredOutputIds.isNotEmpty) {
      return _invalidDashVariableMessage(['prompt', 'outputs']);
    } else if (nonRegisteredOutputIds.isNotEmpty) {
      return _invalidDashVariableMessage(['outputs']);
    } else if (nonRegisteredPromptIds.isNotEmpty) {
      return _invalidDashVariableMessage(['prompt']);
    }
    return null;
  }

  static String? _validateWorkspaceQueryStep(
      Map<String, dynamic> step, List<String> registeredVariables) {
    final nonRegisteredQueryIds = _extractNonRegisteredVariablesInStep(
        step['query'], registeredVariables);
    final stepOutputs = step['outputs'] as List<String>;
    final nonRegisteredOutputIds = [
      for (final output in stepOutputs)
        ..._extractNonRegisteredVariablesInStep(output, registeredVariables)
    ];

    if (nonRegisteredQueryIds.isNotEmpty && nonRegisteredOutputIds.isNotEmpty) {
      return _invalidDashVariableMessage(['query', 'outputs']);
    } else if (nonRegisteredOutputIds.isNotEmpty) {
      return _invalidDashVariableMessage(['outputs']);
    } else if (nonRegisteredQueryIds.isNotEmpty) {
      return _invalidDashVariableMessage(['query']);
    }
    return null;
  }

  static String? _validateMachingDocumentStep(
      Map<String, dynamic> step, List<String> registeredVariables) {
    final nonRegisteredQueryIds = _extractNonRegisteredVariablesInStep(
        step['query'], registeredVariables);
    final stepOutputs = step['outputs'] as List<String>;
    final nonRegisteredOutputIds = [
      for (final output in stepOutputs)
        ..._extractNonRegisteredVariablesInStep(output, registeredVariables)
    ];

    if (nonRegisteredQueryIds.isNotEmpty && nonRegisteredOutputIds.isNotEmpty) {
      return _invalidDashVariableMessage(['query', 'outputs']);
    } else if (nonRegisteredOutputIds.isNotEmpty) {
      return _invalidDashVariableMessage(['outputs']);
    } else if (nonRegisteredQueryIds.isNotEmpty) {
      return _invalidDashVariableMessage(['query']);
    }
    return null;
  }

  static String _invalidDashVariableMessage(List<String> propertyList) {
    final property = propertyList.humanPreferredString(propertyList.length);
    if (propertyList.length == 1) {
      return '$property property contain one or more unregistered/invalid Dash Variable (DashInput or DashOuput)';
    }
    return '$property properties contain one or more unregistered/invalid Dash Variable (DashInput or DashOuput)';
  }

  static List<String> _extractNonRegisteredVariablesInStep(
      String property, List<String> registeredVariables) {
    final propertyIds = _getVariableIdFromText(property);

    return propertyIds
        .where((id) => !registeredVariables.contains(id))
        .toList();
  }

  static List<String> _getVariableIdFromText(String text) {
    final ids = <String>[];
    final regExp = RegExp(r'<(\d+)>');
    final matches = regExp.allMatches(text);
    for (Match match in matches) {
      final id = match.group(1);
      if (id != null) {
        ids.add(id);
      }
    }
    return ids;
  }
}
