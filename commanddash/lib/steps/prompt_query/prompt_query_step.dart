import 'dart:io';

import 'package:commanddash/agent/input_model.dart';
import 'package:commanddash/agent/loader_model.dart';
import 'package:commanddash/agent/output_model.dart';
import 'package:commanddash/agent/step_model.dart';
import 'package:commanddash/models/contextual_code.dart';
import 'package:commanddash/models/workspace_file.dart';
import 'package:commanddash/repositories/dash_repository.dart';
import 'package:commanddash/repositories/generation_repository.dart';
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
    double availableToken = (26000 * 2.7) -
        promptLength; // Max limit should come from the generation repository
    // If there are available token, we will add the outputs
    if (availableToken <= 0) {
      taskAssist.sendErrorMessage(
          message: "Context length of prompt too long",
          data: {"promptLength": promptLength});
      return [];
    }

    /// replace prompt with our common logic and reduce total tokens replaced.
    prompt = prompt.replacePlaceholder(inputs, outputsUntilNow,
        totalTokensAddedCallback: (newReplacedTokens) =>
            availableToken -= newReplacedTokens);

    if (availableToken <= 0) {
      taskAssist.sendErrorMessage(
          message: "Context length of prompt with given inputs is too long",
          data: {"promptLength": promptLength});
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
              final listOfContext = context as List<Map<String, dynamic>>;
              for (final nestedCode in listOfContext) {
                final filePath = nestedCode['filePath'];
                appendNestedCodeCount(filePath);
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

    /// TODO: Verify the code file is not already included in other code snippets
    ///  - Include entire file if under a certain file size
    ///  - or only occurency objects if not
    /// TODO:

    // nestedCode sorted by frequency
    final sortedNestedCode = nestedCodes.entries.toList()
      ..sort(((a, b) {
        return b.value.compareTo(a.value);
      }));

    int indexForNested = 0;
    prompt = "$prompt\nHere is some contextual code which might be helpful\n";
    while (availableToken > 0 && indexForNested < sortedNestedCode.length) {
      final code = sortedNestedCode[indexForNested].key;
      prompt = '$prompt${code.filePath}\n```${code.content}```';
      indexForNested++;
      availableToken = availableToken - code.content!.length;
      includedInPrompt.add(code);
    }

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

List<BaseCodeInput> processCurrentlyAddedInputs(
    List<BaseCodeInput> currentlyAdded) {
  Map<String, List<BaseCodeInput>> groupedCurrentlyAdded = currentlyAdded.fold(
    {},
    (Map<String, List<BaseCodeInput>> map, BaseCodeInput input) {
      map[input.filePath ?? ''] ??= [];
      map[input.filePath ?? '']!.add(input);
      return map;
    },
  );

  List<BaseCodeInput> processedInputs = [];

  for (final entry in groupedCurrentlyAdded.entries) {
    if (entry.key != '') {
      final fileContent = entry.value.first.fileContent ?? '';
      final sortedInputs = entry.value.toList()
        ..sort((a, b) {
          final aStart = a.range!.start;
          final bStart = b.range!.start;
          if (bStart.line != aStart.line) {
            return bStart.line.compareTo(aStart.line);
          } else {
            return bStart.character.compareTo(aStart.character);
          }
        });

      String updatedFileContent = fileContent;

      for (final input in sortedInputs) {
        final range = input.range!;
        final startIndex = range.start;
        final endIndex = range.end;

        updatedFileContent = updatedFileContent.replaceRange(
          startIndex,
          endIndex,
          '(already included in currently added)',
        );
      }

      processedInputs.add(
        BaseCodeInput(
          id: entry.value.first.id,
          filePath: entry.key,
          fileContent: updatedFileContent,
          includeContextualCode: false,
        ),
      );
    }
  }

  return processedInputs;
}
