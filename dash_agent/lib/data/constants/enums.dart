/// Predefined states that a GitHub issue can have - open, close, all
/// - `open`: Refers to all the open/unresolved issues in the GitHub Repo
/// - `close`: Refers to all the closed/resolved issues in the GitHub Repo
/// - `all`: Refers to both open and closed issues in the GitHub Repo
enum IssueState {
  /// Refers to all the open/unresolved issues in the GitHub Repo
  open('open'),

  /// Refers to all the closed/resolved issues in the GitHub Repo
  closed('closed'),

  /// Refers to both open and closed issues in the GitHub Repo
  all('all');

  const IssueState(this.value);
  final String value;
}

/// Extraction strategies that can be employed to extract data from the GitHub
/// repo:
/// - `code`: Instructs only code extraction for indexing
/// - `issue`: Instructs only issues extraction for indexing
enum GithubExtract {
  /// Instructs only code extraction for indexing.
  code('code'),

  /// Instructs only issues extraction for indexing.
  issue('issue');

  const GithubExtract(this.value);
  final String value;
}
