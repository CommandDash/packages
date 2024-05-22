import '../constants/enums.dart';

/// Base class for provide filters to [DataSource] objects.
///
/// This class should not be directly used to add data as this is a `abstract` class.
/// Instead its derivative classes should be used: [CodeFilter], [IssueFilter]
abstract class Filter {
  String get minCliVersion;

  /// Internal method used by dash_agent to convert the shared `DataSource` to json
  /// format that can be sent on the web
  ///
  /// **Note**: Ideally, this method is not supposed to be overriden by the child
  /// objects and should not be altered. It is called automatically by the framework.
  Future<Map<String, dynamic>> process();
}

/// [CodeFilter] defines the filter used to filter out specific files that needs
/// to be indexed from the project.
///
/// Use this class when you need to index specific files from the project,
/// for example, when you only want to index Dart files, you can use this
/// class with a regex expression .*\.dart to filter out all other files
/// except the Dart files.
///
/// Example:
/// ```dart
///  final codeFilter = CodeFilter(pathRegex: r'.*\.dart');
///  ```
/// This will only index the files with .dart extension.
class CodeFilter extends Filter {
  /// Regex expression for filtering out the specific files that is needed to
  /// be indexed from the project.
  ///
  /// Default value is * which indexes all the files from the project.
  final String pathRegex;

  /// Creates a [CodeFilter] object.
  ///
  /// ```dart
  /// final codeFilter = CodeFilter(pathRegex: r'.*\.dart');
  /// ```
  ///
  /// This will only index the files with `.dart` extension
  CodeFilter({this.pathRegex = '.*'});

  /// Internal method used by dash_agent to convert the shared `DataSource` to json
  /// format that can be sent on the web
  ///
  /// **Note**: Ideally, this method is not supposed to be overriden by the child
  /// objects and should not be altered. It is called automatically by the framework.
  @override
  Future<Map<String, dynamic>> process() async {
    return {'path_regex': pathRegex, 'version': minCliVersion};
  }

  @override
  String get minCliVersion => '0.0.1';
}

/// [IssueFilter] defines the filter used to filter out specific issues that needs
/// to be indexed from the GitHub repository.
///
/// Use this class to choose specific issues that are needed to be indexed,
/// like you only want to index the issues that are labeled as bug, you can
/// use this class to filter out all other issues.
///
/// Example:
/// ```dart
///  final issueFilter = IssueFilter(labels: ['bug']);
/// ```
/// This will only index the issues with bug label.
class IssueFilter extends Filter {
  /// List of labels whose issues are needs to be indexed from the from the
  /// GitHub issues.
  ///
  /// This list can be empty which will index all the issues from the GitHub Repo.
  final List<String>? labels;

  /// Kind of issues that is required to be indexed. Like, open issues,
  /// closed issues, or all the issues. It accepts [IssueState] as a value. Use:
  /// - `IssueState.open` to index all the open/unresolved issues in the GitHub Repo
  /// - `IssueState.closed` to index all the closed/resolved issues in the GitHub Repo
  /// - `IssuesState.all` to index all the issues in the GitHub Repo
  /// Default value is `IssueState.closed`
  final IssueState issueStatus;

  /// Duration of how older updated issues needs to be extracted.
  ///
  ///  - It should be a [Duration] object.
  ///  - It represents the time difference in days, hours, minutes, or seconds.
  ///
  /// **Example:**
  /// ```dart
  /// final issueFilter = IssueFilter(since: Duration(days: 30));
  /// ```
  /// This will only index the issues that were updated in the last 30 days.
  final Duration? since;

  /// Creates a [IssueFilter] object.
  ///
  /// ```dart
  /// final issueFilter = IssueFilter(labels: ['bug', 'enhancement'], issueStatus: IssueState.open);
  /// ```
  ///
  /// This will only index the issues with `bug` or `enhancement` label that are `open`
  IssueFilter({this.labels, this.issueStatus = IssueState.closed, this.since});

  /// Internal method used by dash_agent to convert the shared `DataSource` to json
  /// format that can be sent on the web
  ///
  /// **Note**: Ideally, this method is not supposed to be overriden by the child
  /// objects and should not be altered. It is called automatically by the framework.
  @override
  Future<Map<String, dynamic>> process() async {
    final isoFormatSince = since != null
        ? DateTime.now().subtract(since!).toIso8601String()
        : null;
    return {
      'labels': labels,
      'state': issueStatus,
      'version': minCliVersion,
      'since': isoFormatSince
    };
  }

  @override
  String get minCliVersion => '0.0.1';
}
