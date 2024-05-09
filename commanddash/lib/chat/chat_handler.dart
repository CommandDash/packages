import 'package:commanddash/agent/input_model.dart';
import 'package:commanddash/agent/loader_model.dart';
import 'package:commanddash/models/chat_message.dart';
import 'package:commanddash/repositories/generation_repository.dart';
import 'package:commanddash/server/task_assist.dart';
import 'package:commanddash/steps/append_to_chat/append_to_chat_step.dart';

class ChatHandler {
  final List<ChatMessage> messages;
  late GenerationRepository generationRepository;

  ChatHandler({
    required this.messages,
    required Map<String, dynamic> authDetails,
  }) {
    this.generationRepository = GenerationRepository.fromJson(authDetails);
  }

  factory ChatHandler.fromJson(
    Map<String, dynamic> json,
  ) {
    return ChatHandler(
        messages: (json['messages'] != null)
            ? ChatQueryInput.fromJson(json['messages'] as Map<String, dynamic>)
                    .messages ??
                []
            : [],
        authDetails: json['auth_details']);
  }

  Future<void> run(
    TaskAssist taskAssist,
  ) async {
    await taskAssist.processStep(
        kind: 'loader_update',
        args: CircularLoader().toJson(),
        timeoutKind: TimeoutKind.sync);
    final lastMessage = messages.last;
    messages.removeLast();

    final response = await generationRepository.getChatCompletion(
        messages, lastMessage.message);

    AppendToChatStep appendToChatStep =
        AppendToChatStep(message: 'sample response');
    await appendToChatStep.run(taskAssist, generationRepository);
    taskAssist.sendResultMessage(message: "TASK_COMPLETE", data: {});
  }
}
