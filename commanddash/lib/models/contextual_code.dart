import 'package:commanddash/agent/input_model.dart';

String? checkIfUnique(List<CodeInput> current, CodeInput newInput) {
  for (CodeInput input in current) {
    if (newInput.filePath != input.filePath) {
      return null;
    } else {
      if (newInput.range == null) {
        return null;
      }
      final isNew = input.range!.includes(newInput.range!);
      if (isNew) {
        return input.id;
      }
    }
  }
  return null;
}
