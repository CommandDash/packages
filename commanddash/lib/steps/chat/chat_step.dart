import 'dart:io';

import 'package:commanddash/agent/input_model.dart';
import 'package:commanddash/agent/loader_model.dart';
import 'package:commanddash/agent/output_model.dart';
import 'package:commanddash/agent/step_model.dart';
import 'package:commanddash/models/chat_message.dart';
import 'package:commanddash/models/workspace_file.dart';
import 'package:commanddash/repositories/dash_repository.dart';
import 'package:commanddash/repositories/generation_repository.dart';
import 'package:commanddash/server/task_assist.dart';
import 'package:commanddash/steps/steps_utils.dart';

class ChatStep extends Step {
  final List<ChatMessage> messages;
  final String lastMessage;
  final Map<String, Input> inputs;
  final Map<String, Output> outputs;
  final String? systemPrompt;
  ChatStep(
      {required List<String> outputIds,
      required this.messages,
      required this.inputs,
      this.systemPrompt,
      required this.lastMessage,
      required this.outputs,
      Loader loader = const MessageLoader('Preparing Result')})
      : super(outputIds: outputIds, type: StepType.chat, loader: loader);

  // This is for now useless as the chat step is not accesible to agent builders.
  factory ChatStep.fromJson(
    Map<String, dynamic> json,
    List<ChatMessage> chatMessages,
  ) {
    return ChatStep(
      outputIds:
          (json['outputs'] as List<dynamic>).map((e) => e.toString()).toList(),
      messages: chatMessages,
      outputs: {},
      inputs: {},
      lastMessage: json['last_message'],
    );
  }

  @override
  Future<List<DefaultOutput>> run(
      TaskAssist taskAssist, GenerationRepository generationRepository,
      [DashRepository? dashRepository]) async {
    await super.run(taskAssist, generationRepository);
    String prompt = lastMessage.replacePlaceholder(inputs, outputs);
    final List<CodeInput> codeInputs = inputs.values
        .whereType<CodeInput>()
        .toList(); // These are the inputs to be used to get contextual code;
    double promptLength = 0;
    for (final message in messages) {
      if (message.role == ChatRole.user) {
        if (message.data != null && message.data!['prompt'] != null) {
          promptLength += message.data!['prompt'].length;
          // Content for all the previours messages is the prompt constructed at the time of their request
          message.message = message.data!['prompt'];
        } else {
          promptLength += message.message.length;
        }
      } else {
        promptLength += message.message.length;
      }
    }
    double availableToken = generationRepository.characterLimit - promptLength;
    if (availableToken <= 0) {
      return [];
    }

    List<WorkspaceFile> includedInPrompt = [];
    final Map<String, int> nestedCodes = {};

    void appendNestedCodeCount(String filePath, {int priority = 1}) {
      nestedCodes[filePath] = (nestedCodes[filePath] ?? 0) + priority;
    }

    void markIncludedInPrompt(
        {required String path, required List<Range> ranges}) {
      final existingFileIndex =
          includedInPrompt.indexWhere((file) => file.path == path);
      if (existingFileIndex != -1) {
        includedInPrompt[existingFileIndex].selectedRanges.addAll(ranges);
      } else {
        includedInPrompt
            .add(WorkspaceFile.fromPath(path, selectedRanges: ranges));
      }
    }

    for (CodeInput code in codeInputs) {
      /// add the code file itself as context
      appendNestedCodeCount(code.filePath, priority: 10);

      final data = await taskAssist.processStep(
        kind: "context",
        args: {
          "filePath": code.filePath,
          "range": code.range.toJson(),
        },
        timeoutKind: TimeoutKind.stretched,
      );
      final context = data['context'];
      if (context != null) {
        final listOfContext = List<Map<String, dynamic>>.from(context);
        for (final nestedCode in listOfContext) {
          final filePath = nestedCode['filePath'];
          appendNestedCodeCount(filePath);
        }
      }
    }
    // nestedCode sorted by frequency
    final sortedNestedCode = nestedCodes.entries.toList()
      ..sort(((a, b) {
        return b.value.compareTo(a.value);
      }));
    String contextualCodePrefix =
        "[CONTEXTUAL CODE FOR YOUR INFORMATION FROM USER PROJECT]\n\n";
    String contextualCode = "";

    ///TODO: Figure out a way to attach the most relevant part of the file if the full file is extremely long
    for (final nestedFilePath in sortedNestedCode.map((e) => e.key)) {
      final includedInPromptIndex = includedInPrompt
          .indexWhere((element) => element.path == nestedFilePath);
      if (includedInPromptIndex != -1) {
        final content =
            includedInPrompt[includedInPromptIndex].surroundingContent;
        if (content != null) {
          if (availableToken - content.length > 0) {
            contextualCode =
                '$contextualCode$nestedFilePath\n```$content```\n\n';
            availableToken -= content.length;
          }
        }
        continue;
      }
      final content = (await File(nestedFilePath).readAsString())
          .replaceAll(RegExp(r"[\n\s]+"), "");
      if (content.length > 9500) {
        continue; // Don't include extremely large nested code files.
      }
      if (availableToken - content.length < 0) continue;
      contextualCode = '$contextualCode$nestedFilePath\n```$content```\n\n';
      availableToken -= content.length;
    }
    if (contextualCode.isNotEmpty) {
      contextualCode =
          '$contextualCodePrefix$contextualCode\n\n[END OF CONTEXTUAL CODE.]\n\n';
      prompt = '$contextualCode$prompt';
    }
    print(prompt);
    var filesInvolved = Set<String>.from(
            includedInPrompt.map((e) => e.path).toList() +
                nestedCodes.keys.toList())
        .map((e) => e.split('/').last)
        .take(7)
        .toList();
    await taskAssist.processStep(
        kind: 'prompt_update',
        args: {"prompt": prompt},
        timeoutKind: TimeoutKind.sync);
    await taskAssist.processStep(
        kind: 'loader_update',
        args: ProcessingFilesLoader(filesInvolved, message: 'Preparing Result')
            .toJson(),
        timeoutKind: TimeoutKind.sync);
    final response = await generationRepository.getChatCompletion(
      messages,
      prompt,
      systemPrompt: systemPrompt,
    );
    print(response);
    return [DefaultOutput(response)];
  }
}
