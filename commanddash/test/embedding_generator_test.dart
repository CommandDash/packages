import 'package:commanddash/models/workspace_file.dart';
import 'package:commanddash/repositories/gemini_repository.dart';
import 'package:commanddash/steps/find_closest_files/embedding_generator.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import 'embedding_generator_test.mocks.dart';

@GenerateMocks([GeminiRepository, WorkspaceFile])
void main() {
  group('updateEmbeddings', () {
    late MockGeminiRepository mockGeminiRepository;

    setUp(() {
      mockGeminiRepository = MockGeminiRepository();
    });

    test('should batch and update file embeddings < 100', () async {
      final files = List.generate(99, (i) {
        return WorkspaceFile(
          'path/to/file$i.dart',
          codeHash: '',
          contentLines: ['content of file $i'],
          selectedRanges: [
            Range(
                start: Position(line: 0, character: 0),
                end: Position(
                    line: 0, character: 'content of file $i'.length - 1))
          ],
        );
      });

      when(mockGeminiRepository.getCodeBatchEmbeddings(files
              .map((file) => {'content': file.fileContent, 'title': file.path})
              .toList()))
          .thenAnswer((_) async => files
              .map((e) => getMockEmbeddingForString(e.fileContent))
              .toList());

      final updatedFiles = await EmbeddingGenerator.updateEmbeddings(
          files, mockGeminiRepository);
      for (int i = 0; i < files.length; i++) {
        expect(updatedFiles[i].embedding,
            getMockEmbeddingForString(files[i].fileContent));
      }
      verify(mockGeminiRepository.getCodeBatchEmbeddings(any)).called(1);
    });
    test('should batch and update file embeddings > 100', () async {
      final files = List.generate(125, (i) {
        return WorkspaceFile(
          'path/to/file$i.dart',
          codeHash: '',
          contentLines: ['content of file $i'],
          selectedRanges: [
            Range(
                start: Position(line: 0, character: 0),
                end: Position(
                    line: 0, character: 'content of file $i'.length - 1))
          ],
        );
      });

      when(mockGeminiRepository.getCodeBatchEmbeddings(files
              .sublist(0, 100)
              .map((file) => {'content': file.fileContent, 'title': file.path})
              .toList()))
          .thenAnswer((_) async => files
              .sublist(0, 100)
              .map((e) => getMockEmbeddingForString(e.fileContent))
              .toList());
      when(mockGeminiRepository.getCodeBatchEmbeddings(files
              .sublist(100)
              .map((file) => {'content': file.fileContent, 'title': file.path})
              .toList()))
          .thenAnswer((_) async => files
              .sublist(100)
              .map((e) => getMockEmbeddingForString(e.fileContent))
              .toList());

      final updatedFiles = await EmbeddingGenerator.updateEmbeddings(
          files, mockGeminiRepository);
      for (int i = 0; i < files.length; i++) {
        expect(updatedFiles[i].embedding,
            getMockEmbeddingForString(files[i].fileContent!));
      }
      verify(mockGeminiRepository.getCodeBatchEmbeddings(any)).called(2);
    });
    test('should batch and update file embeddings > 200', () async {
      final files = List.generate(250, (i) {
        return WorkspaceFile(
          'path/to/file$i.dart',
          codeHash: '',
          contentLines: ['content of file $i'],
          selectedRanges: [
            Range(
                start: Position(line: 0, character: 0),
                end: Position(
                    line: 0, character: 'content of file $i'.length - 1))
          ],
        );
      });

      when(mockGeminiRepository.getCodeBatchEmbeddings(files
              .sublist(0, 100)
              .map((file) => {'content': file.fileContent, 'title': file.path})
              .toList()))
          .thenAnswer((_) async => files
              .sublist(0, 100)
              .map((e) => getMockEmbeddingForString(e.fileContent))
              .toList());
      when(mockGeminiRepository.getCodeBatchEmbeddings(files
              .sublist(100, 200)
              .map((file) => {'content': file.fileContent, 'title': file.path})
              .toList()))
          .thenAnswer((_) async => files
              .sublist(100, 200)
              .map((e) => getMockEmbeddingForString(e.fileContent!))
              .toList());
      when(mockGeminiRepository.getCodeBatchEmbeddings(files
              .sublist(200)
              .map((file) => {'content': file.fileContent, 'title': file.path})
              .toList()))
          .thenAnswer((_) async => files
              .sublist(200)
              .map((e) => getMockEmbeddingForString(e.fileContent))
              .toList());

      final updatedFiles = await EmbeddingGenerator.updateEmbeddings(
          files, mockGeminiRepository);
      for (int i = 0; i < files.length; i++) {
        expect(updatedFiles[i].embedding,
            getMockEmbeddingForString(files[i].fileContent));
      }
      verify(mockGeminiRepository.getCodeBatchEmbeddings(any)).called(3);
    });
  });
}

List<double> getMockEmbeddingForString(String value) {
  return value.codeUnits.map((e) => e.toDouble()).toList();
}
