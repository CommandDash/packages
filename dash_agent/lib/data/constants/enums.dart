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
