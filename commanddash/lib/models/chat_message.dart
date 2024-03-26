enum ChatRole { model, user }

class ChatMessage {
  final ChatRole role;
  final String message;

  ChatMessage({required this.role, required this.message});

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      role: json['role'] == 'model' ? ChatRole.model : ChatRole.user,
      message: json['message'],
    );
  }
}
