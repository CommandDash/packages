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
    List<CodeInput> currentlyAdded = [];
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

    for (String id in usedIds) {
      if (inputs.containsKey(id)) {
        switch (inputs[id].runtimeType) {
          case CodeInput:
            currentlyAdded.add(inputs[id] as CodeInput);
            break;
        }
      } else if (outputsUntilNow.containsKey(id)) {
        switch (outputsUntilNow[id].runtimeType) {
          case MultiCodeOutput:
            final value = outputsUntilNow[id] as MultiCodeOutput;
            if (value.value != null) {
              for (WorkspaceFile file in value.value!) {
                final CodeInput codeInput = CodeInput(
                  id: id,
                  content: file.content,
                  range: file.range,
                );

                currentlyAdded.add(codeInput);
              }
            }
            break;
        }
      }
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
    final Map<CodeInput, int> nestedCodes = {};

    for (CodeInput code in inputs.values.whereType<CodeInput>()) {
      if (!usedIds.contains(code.id) && !code.includeContextualCode) {
        continue;
      }

      /// TODO: Verify the code file is not already included in other code snippets
      ///  - Include entire file if under a certain file size
      ///  - or only occurency objects if not
      /// TODO: Include the file of the code inputs as the context.

      final data = await taskAssist.processStep(
        kind: "context",
        args: {
          "filePath": code.filePath,
          "range": code.range!.toJson(),
        },
        timeoutKind: TimeoutKind.stretched,
      );
      final context = data['context'];
      final listOfContext = context as List<Map<String, dynamic>>;
      for (final nestedCode in listOfContext) {
        final CodeInput codeInput = CodeInput(
          id: "${code.id}-context",
          content: nestedCode['content'],
          filePath: nestedCode['filePath'],
          range: Range(
            start: Position(line: 1, character: 1),
            end: Position(
              line: (nestedCode['content'] as String).split('\n').length,
              character:
                  (nestedCode['content'] as String).split('\n').last.length,
            ),
          ),
        );
        if (currentlyAdded.indexWhere((e) =>
                e.fileContent?.contains(nestedCode['content']) ?? false) !=
            -1) {
          /// If the nested code is already added somewhere in the prompt (code input or matching documents), skip it!
          continue;
        }

        final duplicatedId =
            checkIfUnique(nestedCodes.keys.toList(), codeInput);

        if (duplicatedId == null) {
          nestedCodes.addAll({codeInput: 1});
        } else {
          final key = nestedCodes.keys
              .where((element) => element.id == duplicatedId)
              .first;
          nestedCodes[key] = nestedCodes[key]! + 1;
        }
      }

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
        currentlyAdded.add(code);
      }
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
