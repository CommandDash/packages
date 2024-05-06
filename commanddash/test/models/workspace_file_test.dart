import 'package:commanddash/models/workspace_file.dart';
import 'package:test/test.dart';

void main() {
  group('WorkspaceFile', () {
    test('mergeOverlappingRanges should merge overlapping ranges correctly',
        () {
      // Test case 1: Non-overlapping ranges
      WorkspaceFile file1 = WorkspaceFile('path',
          contentLines: [],
          codeHash: '',
          selectedRanges: [
            Range(
                start: Position(line: 0, character: 0),
                end: Position(line: 0, character: 5)),
            Range(
                start: Position(line: 1, character: 0),
                end: Position(line: 1, character: 5)),
          ]);
      expect(
          file1.mergeOverlappingRanges,
          equals([
            Range(
                start: Position(line: 0, character: 0),
                end: Position(line: 0, character: 5)),
            Range(
                start: Position(line: 1, character: 0),
                end: Position(line: 1, character: 5)),
          ]));

      // Test case 2: Overlapping ranges
      WorkspaceFile file2 = WorkspaceFile('path',
          contentLines: [],
          codeHash: '',
          selectedRanges: [
            Range(
                start: Position(line: 0, character: 0),
                end: Position(line: 0, character: 5)),
            Range(
                start: Position(line: 0, character: 3),
                end: Position(line: 0, character: 8)),
          ]);
      expect(
          file2.mergeOverlappingRanges,
          equals([
            Range(
                start: Position(line: 0, character: 0),
                end: Position(line: 0, character: 8)),
          ]));

      // Test case 3: Multiple overlapping ranges
      WorkspaceFile file3 = WorkspaceFile('path',
          contentLines: [],
          codeHash: '',
          selectedRanges: [
            Range(
                start: Position(line: 0, character: 0),
                end: Position(line: 0, character: 5)),
            Range(
                start: Position(line: 0, character: 3),
                end: Position(line: 0, character: 8)),
            Range(
                start: Position(line: 0, character: 6),
                end: Position(line: 0, character: 10)),
          ]);
      expect(
          file3.mergeOverlappingRanges,
          equals([
            Range(
                start: Position(line: 0, character: 0),
                end: Position(line: 0, character: 10)),
          ]));

      // Test case 4: Edge case - Empty selected ranges
      WorkspaceFile file4 = WorkspaceFile('path',
          contentLines: [], codeHash: '', selectedRanges: []);
      expect(file4.mergeOverlappingRanges, equals([]));
    });

    test('getSelectedContent should return the correct selected content', () {
      // Test case 1: Single line selection
      WorkspaceFile file1 = WorkspaceFile('path',
          contentLines: ['Hello, World!'],
          codeHash: '',
          selectedRanges: [
            Range(
                start: Position(line: 0, character: 0),
                end: Position(line: 0, character: 5)),
          ]);
      expect(file1.selectedContent, equals('Hello'));

      // Test case 2: Multi-line selection
      WorkspaceFile file2 = WorkspaceFile('path',
          contentLines: ['Hello,', 'World!'],
          codeHash: '',
          selectedRanges: [
            Range(
                start: Position(line: 0, character: 0),
                end: Position(line: 1, character: 5)),
          ]);
      expect(file2.selectedContent, equals('Hello,\nWorld'));

      // Test case 3: Multiple selections
      WorkspaceFile file3 = WorkspaceFile('path',
          contentLines: ['Hello, World!'],
          codeHash: '',
          selectedRanges: [
            Range(
                start: Position(line: 0, character: 0),
                end: Position(line: 0, character: 5)),
            Range(
                start: Position(line: 0, character: 7),
                end: Position(line: 0, character: 12)),
          ]);
      expect(file3.selectedContent, equals('HelloWorld'));

      // Test case 4: Edge case - Empty selected ranges
      WorkspaceFile file4 = WorkspaceFile('path',
          contentLines: ['Hello, World!'], codeHash: '', selectedRanges: []);
      expect(file4.selectedContent, equals(''));
    });
    test('surroundingContent should return the correct surrounding content',
        () {
      // Test case 1: Selected content less than 80% and more than 3 lines
      WorkspaceFile file1 = WorkspaceFile('path',
          contentLines: [
            'Line 1',
            'Line 2',
            'Line 3',
            'Line 4',
            'Line 5',
            'Line 6'
          ],
          codeHash: '',
          selectedRanges: [
            Range(
                start: Position(line: 1, character: 0),
                end: Position(line: 4, character: 5)),
          ]);
      expect(file1.surroundingContent,
          equals('Line 1\n...(already attached by user)...\nLine 6'));

      // Test case 2: Selected content less than 80% and less than 3 lines
      WorkspaceFile file2 = WorkspaceFile('path',
          contentLines: ['Line 1', 'Line 2', 'Line 3', 'Line 4', 'Line 5'],
          codeHash: '',
          selectedRanges: [
            Range(
                start: Position(line: 1, character: 0),
                end: Position(line: 2, character: 5)),
          ]);
      expect(file2.surroundingContent,
          equals('Line 1\nLine 2\nLine 3\nLine 4\nLine 5'));

      // Test case 3: Selected content covers 80% or more of the lines
      WorkspaceFile file3 = WorkspaceFile('path',
          contentLines: ['Line 1', 'Line 2', 'Line 3', 'Line 4', 'Line 5'],
          codeHash: '',
          selectedRanges: [
            Range(
                start: Position(line: 0, character: 0),
                end: Position(line: 4, character: 5)),
          ]);
      expect(file3.surroundingContent, null);

      // Test case 4: Edge case - Empty selected ranges
      WorkspaceFile file4 = WorkspaceFile('path',
          contentLines: ['Line 1', 'Line 2', 'Line 3', 'Line 4', 'Line 5'],
          codeHash: '',
          selectedRanges: []);
      expect(file4.surroundingContent,
          equals('Line 1\nLine 2\nLine 3\nLine 4\nLine 5'));
    });
  });
}
