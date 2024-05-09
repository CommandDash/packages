import 'package:commanddash/agent/input_model.dart';

enum ChatRole { model, user }

class ChatMessage {
  final ChatRole role;
  final String message;
  final Map<String, Input> inputs;

  ChatMessage(
      {required this.role, required this.message, required this.inputs});

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    final inputs = <String, Input>{};
    if (json['inputs'] != null) {
      for (Map<String, dynamic> input in (json['inputs'] as List)) {
        inputs.addAll({input['id']: Input.fromJson(input)});
      }
    }
    return ChatMessage(
      role: json['role'] == 'model' ? ChatRole.model : ChatRole.user,
      message: json['parts'],
      inputs: inputs,
    );
  }
}
