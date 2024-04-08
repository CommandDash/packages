import 'package:commanddash/agent/loader_model.dart';
import 'package:commanddash/agent/output_model.dart';
import 'package:commanddash/agent/step_model.dart';
import 'package:commanddash/models/chat_message.dart';
import 'package:commanddash/repositories/dash_repository.dart';
import 'package:commanddash/repositories/generation_repository.dart';
import 'package:commanddash/server/task_assist.dart';
import 'package:commanddash/steps/steps_utils.dart';

class ChatStep extends Step {
  final List<ChatMessage> messages;
  final String lastMessage;
  ChatStep(
      {required List<String> outputIds,
      required this.messages,
      required this.lastMessage,
      Loader loader = const MessageLoader('Preparing Result')})
      : super(outputIds: outputIds, type: StepType.chat, loader: loader);

  factory ChatStep.fromJson(
    Map<String, dynamic> json,
    List<ChatMessage> chatMessages,
    String lastMessage,
  ) {
    return ChatStep(
      outputIds:
          (json['outputs'] as List<dynamic>).map((e) => e.toString()).toList(),
      messages: chatMessages,
      lastMessage: lastMessage,
    );
  }

  @override
  Future<List<DefaultOutput>> run(
      TaskAssist taskAssist, GenerationRepository generationRepository,
      [DashRepository? dashRepository]) async {
    await super.run(taskAssist, generationRepository);
    final response =
        await generationRepository.getChatCompletion(messages, lastMessage);
    return [DefaultOutput(response)];
  }
}
