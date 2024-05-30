import 'package:commanddash/agent/input_model.dart';

enum ChatRole { model, user }

class ChatMessage {
  final ChatRole role;
  String message;
  final Map<String, dynamic>? data;
  ChatMessage({
    required this.role,
    required this.message,
    required this.data,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      role: json['role'] == 'model' ? ChatRole.model : ChatRole.user,
      message: json['parts'],
      data: json['data'],
    );
  }
}
