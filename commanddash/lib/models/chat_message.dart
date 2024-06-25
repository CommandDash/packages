enum ChatRole { model, user, unknown }

class ChatMessage {
  final ChatRole role;
  String message;
  Map<String, dynamic>? data;
  ChatMessage({
    required this.role,
    required this.message,
    required this.data,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      role: json['role'] == 'model'
          ? ChatRole.model
          : json['role'] == 'user'
              ? ChatRole.user
              : ChatRole.unknown,
      message: json['parts'],
      data: json['data'],
    );
  }
}
