import 'dart:convert';
import 'dart:io';
import 'package:commanddash/agent/input_model.dart';
import 'package:commanddash/agent/loader_model.dart';
import 'package:commanddash/agent/output_model.dart';
import 'package:commanddash/agent/step_model.dart';
import 'package:commanddash/models/chat_message.dart';
import 'package:commanddash/models/data_source.dart';
import 'package:commanddash/models/workspace_file.dart';
import 'package:commanddash/repositories/dash_repository.dart';
import 'package:commanddash/repositories/gemini_repository.dart';
import 'package:commanddash/server/task_assist.dart';
import 'package:commanddash/steps/steps_utils.dart';
import 'package:commanddash/utils/embedding_utils.dart';

class ChatStep extends Step {
  final String agentName;
  final List<ChatMessage> existingMessages;
  final String lastMessage;
  final Map<String, Input> inputs;
  final Map<String, Output> outputs;
  final String? systemPrompt;
  final List<DataSourceResultOutput> newDocuments;
  final String?
      existingDocuments; //TODO: See if we can save data source result output only
  ChatStep(
      {required this.agentName,
      required List<String> outputIds,
      required this.existingMessages,
      required this.inputs,
      this.systemPrompt,
      required this.lastMessage,
      required this.outputs,
      required this.newDocuments,
      required this.existingDocuments,
      Loader loader = const MessageLoader('Preparing Result')})
      : super(outputIds: outputIds, type: StepType.chat, loader: loader);

  @override
  Future<List<DefaultOutput>> run(
      TaskAssist taskAssist, GeminiRepository generationRepository,
      [DashRepository? dashRepository]) async {
    await super.run(taskAssist, generationRepository);

    /// Part 1: Reference Documents attachment
    final String referencesStart =
        "Please note the below references from the latest documentations, examples and github issues that would be helpful in answering user's requests:\n\n";
    String chatDocuments = existingDocuments ?? referencesStart;

    if (chatDocuments.length > 75000.tokenized) {
      /// keep reducing references size to accomodate new documents
      chatDocuments =
          referencesStart + chatDocuments.substring(30000.tokenized);
    }
    if (newDocuments.isNotEmpty) {
      for (DataSource doc in newDocuments.first.value!) {
        if (!chatDocuments.contains(doc.content)) {
          if (chatDocuments.length + doc.content.length < 90000.tokenized) {
            chatDocuments = "$chatDocuments\n\n${doc.content}";
          }
        }
      }
    }

    /// Part 2: Converation history
    for (final message in existingMessages) {
      if (message.role == ChatRole.user) {
        if (message.data != null && message.data!['prompt'] != null) {
          // data['prompt'] is the actual message sent to the LLM which contains the contextual code as well.
          message.message = message.data!['prompt'];
        }
      }
    }

    /// Part 3: Trigger Message
    List<WorkspaceFile> includedInPrompt = [];
    final Map<String, int> nestedCodes = {};

    // This function is commented out because it is not used as contextual code is not added for now.
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

    final List<CodeInput> codeInputs = inputs.values
        .whereType<CodeInput>()
        .toList(); // These are the inputs to be used to get contextual code;

    for (CodeInput code in codeInputs) {
      /// add the code file itself as context
      appendNestedCodeCount(code.filePath, priority: 10);
      markIncludedInPrompt(path: code.filePath, ranges: [code.range]);
    }
    // nestedCode sorted by frequency
    final sortedNestedCode = nestedCodes.entries.toList()
      ..sort(((a, b) {
        return b.value.compareTo(a.value);
      }));
    String contextualCodePrefix =
        "[CONTEXTUAL CODE FOR YOUR INFORMATION FROM USER PROJECT]\n\n";
    String contextualCode = "";

    for (final nestedFilePath in sortedNestedCode.map((e) => e.key)) {
      final includedInPromptIndex = includedInPrompt
          .indexWhere((element) => element.path == nestedFilePath);
      if (includedInPromptIndex != -1) {
        final content =
            includedInPrompt[includedInPromptIndex].surroundingContent;
        if (content != null) {
          contextualCode = '$contextualCode$nestedFilePath\n```$content```\n\n';
        }
        continue;
      }
      final content = (await File(nestedFilePath).readAsString())
          .replaceAll(RegExp(r"[\n\s]+"), "");

      contextualCode = '$contextualCode$nestedFilePath\n```$content```\n\n';
    }

    String prompt = lastMessage.replacePlaceholder(inputs, outputs);
    if (contextualCode.isNotEmpty) {
      contextualCode =
          '$contextualCodePrefix$contextualCode\n\n[END OF CONTEXTUAL CODE.]\n\n';
      prompt = '$contextualCode$prompt';
    }

    /// remove messages earlier in the history to comply with limits
    while ((systemPrompt?.length ?? 0) +
            chatDocuments.length +
            existingMessages.map((e) => e.message).join('').length >
        generationRepository.characterLimit) {
      if (existingMessages.length < 3) {
        break; // we want to preserve the last couple messages.
      }
      existingMessages.removeAt(0);
    }

    var filesInvolved = Set<String>.from(
            includedInPrompt.map((e) => e.path).toList() +
                nestedCodes.keys.toList())
        .map((e) => e.split('/').last)
        .take(7)
        .toList();

    taskAssist.sendLogMessage(message: 'prompt', data: {
      'system_prompt': systemPrompt,
      'chat_documents': chatDocuments,
      'chat_documents_length': chatDocuments.length,
      'prompt': prompt,
      'data': json.encode(
          existingMessages.map((e) => "${e.role}: ${e.message}").toList())
    });
    // TODO: send complete conversation history to IDE to replace
    await taskAssist.processStep(
        kind: 'chat_document_update',
        args: {'content': chatDocuments},
        timeoutKind: TimeoutKind.sync);
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
      [
        ChatMessage(role: ChatRole.user, message: chatDocuments, data: {}),
        ...existingMessages
      ],
      prompt,
      agent: agentName,
      systemPrompt: systemPrompt,
    );
    return [DefaultOutput(response)];
  }
}
