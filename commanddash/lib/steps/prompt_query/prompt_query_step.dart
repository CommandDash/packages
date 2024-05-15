import 'dart:io';

import 'package:commanddash/agent/input_model.dart';
import 'package:commanddash/agent/loader_model.dart';
import 'package:commanddash/agent/output_model.dart';
import 'package:commanddash/agent/step_model.dart';
import 'package:commanddash/models/workspace_file.dart';
import 'package:commanddash/repositories/dash_repository.dart';
import 'package:commanddash/repositories/generation_repository.dart';
import 'package:commanddash/server/server.dart';
import 'package:commanddash/server/task_assist.dart';
import 'package:commanddash/steps/prompt_query/prompt_response_parsers.dart';
import 'package:commanddash/steps/steps_utils.dart';

class PromptQueryStep extends Step {
  final String query;
  final List<Output> outputs;
  Map<String, Input> inputs;
  Map<String, Output> outputsUntilNow; //TODO:rename needed
  PromptQueryStep(
      {required List<String>? outputIds,
      required this.outputs,
      required this.query,
      required this.inputs,
      required this.outputsUntilNow,
      Loader loader = const MessageLoader('Preparing Result')})
      : super(outputIds: outputIds, type: StepType.promptQuery, loader: loader);

  factory PromptQueryStep.fromJson(
    Map<String, dynamic> json,
    String query,
    List<Output> outputs,
    Map<String, Input> inputs,
    Map<String, Output> outputsUntilNow,
  ) {
    return PromptQueryStep(
      outputIds:
          (json['outputs'] as List<dynamic>).map((e) => e.toString()).toList(),
      outputs: outputs,
      query: query,
      inputs: inputs,
      outputsUntilNow: outputsUntilNow,
    );
  }

  @override
  Future<List<Output>> run(
      TaskAssist taskAssist, GenerationRepository generationRepository,
      [DashRepository? dashRepository]) async {
    await super.run(taskAssist, generationRepository);

    final List<String> usedIds = query
        .getInputIds(); // These are the input or output ids which are used in the prompt query

    String prompt = query;
    int promptLength = prompt.length;

    double availableToken = generationRepository.characterLimit -
        promptLength; // Max limit should come from the generation repository
    // If there are available token, we will add the outputs
    if (availableToken <= 0) {
      taskAssist.sendErrorMessage(
          message: "Context length of prompt too long",
          data: {"available_tokens": availableToken});
      return [];
    }

    /// replace prompt with our common logic and reduce total tokens replaced.
    prompt = prompt.replacePlaceholder(inputs, outputsUntilNow,
        totalTokensAddedCallback: (newReplacedTokens) {
      availableToken = availableToken - newReplacedTokens;
    });

    if (availableToken <= 0) {
      taskAssist.sendErrorMessage(
          message: "Context length of prompt with given inputs is too long",
          data: {"available_tokens": availableToken});
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

    for (String id in usedIds) {
      if (inputs.containsKey(id)) {
        switch (inputs[id].runtimeType) {
          case CodeInput:
            final code = inputs[id] as CodeInput;
            markIncludedInPrompt(
                path: (inputs[id] as CodeInput).filePath,
                ranges: [(inputs[id] as CodeInput).range]);
            if ((inputs[id] as CodeInput).includeContextualCode) {
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
            break;
        }
      } else if (outputsUntilNow.containsKey(id)) {
        switch (outputsUntilNow[id].runtimeType) {
          case MultiCodeOutput:
            final value = outputsUntilNow[id] as MultiCodeOutput;
            if (value.value != null) {
              for (WorkspaceFile file in value.value!) {
                markIncludedInPrompt(
                    path: file.path, ranges: file.selectedRanges);
              }
            }
            break;
        }
      }
    }

    // nestedCode sorted by frequency
    final sortedNestedCode = nestedCodes.entries.toList()
      ..sort(((a, b) {
        return b.value.compareTo(a.value);
      }));
    String contextualCode =
        "[CONTEXTUAL CODE FOR YOUR INFORMATION FROM USER PROJECT]\n\n";

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
    contextualCode = '$contextualCode\n\n[END OF CONTEXTUAL CODE.]\n\n';
    prompt = '$contextualCode$prompt';

    var filesInvolved = Set<String>.from(
            includedInPrompt.map((e) => e.path).toList() +
                nestedCodes.keys.toList())
        .map((e) => e.split('/').last)
        .take(7)
        .toList();
    await taskAssist.processStep(
        kind: 'loader_update',
        args: ProcessingFilesLoader(filesInvolved, message: 'Preparing Result')
            .toJson(),
        timeoutKind: TimeoutKind.sync);
    final response = await generationRepository.getCompletion(prompt);
    final result = <Output>[];
    for (Output output in outputs) {
      if (output is CodeOutput) {
        final parsedResponse =
            CodeExtractPromptResponseParser().parse(response);
        result.add(CodeOutput(parsedResponse));
      } else if (output is DefaultOutput) {
        final parsedResponse = RawPromptResponseParser().parse(response);
        result.add(DefaultOutput(parsedResponse));
      }
    }
    return result;
  }
}
