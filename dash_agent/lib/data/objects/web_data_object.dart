import '../constants/enums.dart';
import '../filters/filter.dart';

/// Base class for adding data to [DataSource] from the web pages
///
/// This class should not be directly used to add data as this is a `abstract` class.
/// Instead its derivative classes should be used: [WebPage], [SiteMap]
abstract class WebDataObject {
  String get minCliVersion;
  const WebDataObject();

  /// static method to create and return [WebPage]. It takes `url` of web page as
  /// an argument
  ///
  /// Example:
  /// ```dart
  /// final webUrl = 'https://sampleurl.com';
  /// final webPageObject = WebDataObject.fromWebPage(webUrl);
  /// ```
  static WebPage fromWebPage(String url) {
    return WebPage(url);
  }

  /// static method to create and return [SiteMap]. It takes `xml` as an argument
  /// which will contain the url of the relevant of web pages that we need to save
  /// as reference.
  ///
  /// Example:
  /// ```dart
  /// final siteMapUrl = 'https://sitemaps.example.com/sitemap-example-com.xml';
  /// final siteMapObject = WebDataObject.fromSiteMap(siteMapUrl);
  /// ```
  static SiteMap fromSiteMap(String xml) {
    return SiteMap(xml);
  }

  /// static method to create and return [Github]. It takes a GitHub repository
  /// `url` as input and optionally accepts [CodeFilter], [IssueFilter],
  /// and [GithubExtract] objects.
  ///
  /// Example:
  /// ```dart
  /// final githubUrl = 'https://github.com/flutter/flutter';
  ///
  /// final accessToken = 'your personal github access token'
  ///
  /// // filter out dart files
  /// final codeFilter = CodeFilter(pathRegex: '.*\.dart');
  ///
  /// // filter out issues with label "bug"
  /// final issueFilter = IssueFilter(labels: ['bug']);
  ///
  /// // specificy what objects need to be extracted - code, issue, both
  /// final extractObject = GithubExtract.code
  ///
  /// final githubObject = WebDataObject.fromGithub(githubUrl, accessToken,
  ///     codeFilter: codeFilter, issueFilter: issueFilter, extractOnly: extractObject);
  /// ```
  static Github fromGithub(String url, String accessToken,
      {CodeFilter? codeFilter,
      IssueFilter? issueFilter,
      List<GithubExtract> extractOnly = const [GithubExtract.code]}) {
    return Github(
        url: url,
        accessToken: accessToken,
        codeFilter: codeFilter,
        issueFilter: issueFilter,
        extractOnly: extractOnly);
  }

  /// Internal method used by dash_agent to convert the shared `DataSource` to json
  /// format that can be sent on the web
  ///
  /// **Note**: Ideally, this method is not supposed to be overriden by the child
  /// objects and should not be altered. It is called automatically by the framework.
  Future<Map<String, dynamic>> process();
}

/// [WebPage] is used to add web page content to the [DataSource] in the cloud which
/// can be later used for referencing by Agent.
///
/// Example:
/// ```dart
/// final webUrl = 'https://sampleurl.com';
/// final webPageObject = WebDataObject.fromWebPage(webUrl);
/// ```
class WebPage extends WebDataObject {
  /// Creates a new [WebPage] object.
  ///
  /// * url: URL of the web page that contains the content that you want to save for referencing.
  WebPage(this.url);

  /// url of the web page that contains the content that you want to save for referencing.
  final String url;

  @override
  Future<Map<String, dynamic>> process() async {
    return {
      'id': hashCode.toString(),
      'type': 'web_page',
      'url': url,
      'version': minCliVersion
    };
  }

  @override
  String get minCliVersion => '0.0.1';
}

/// [SiteMap] is used to add web pages containing the relevant content to the [DataSource]
/// in the cloud which can be later used for referencing. [SiteMap] object takes the
/// `xml` link as input which contains the references of all the web pages that you
/// need for referencing.
///
/// Example:
/// ```dart
/// final siteMapUrl = 'https://sitemaps.example.com/sitemap-example-com.xml';
/// final siteMapObject = WebDataObject.fromSiteMap(siteMapUrl);
/// ```
class SiteMap extends WebDataObject {
  /// Creates a new [SiteMap] object.
  ///
  /// * `xml`: xml link that contains the link of all the web pages of the domain
  /// which are relevant to agent and can be used for referencing.
  SiteMap(this.xml);

  /// xml link that contains the link of all the web pages of the domain which are
  /// relevant to agent and can be used for referencing.
  final String xml;

  /// Internal method used by dash_agent to convert the shared `DataSource` to json
  /// format that can be sent on the web
  ///
  /// **Note**: Ideally, this method is not supposed to be overriden by the child
  /// objects and should not be altered. It is called automatically by the framework.
  @override
  Future<Map<String, dynamic>> process() async {
    return {
      'id': hashCode.toString(),
      'type': 'site_map',
      'xml': xml,
      'version': minCliVersion
    };
  }

  @override
  String get minCliVersion => '0.0.1';
}

/// [Github] is used to index and add github repository codes and issues to the
/// [DataSource] in the cloud which can be later used for referencing.
///
/// This object takes a GitHub repository `url` as input. It can be used to index
/// the code files in the repository or specific issues from the repository.
///
/// You can optionally provide [CodeFilter] object to filter out the specific
/// files that you want to index from the repository. It accepts a regex string
/// to filter out the files based on a specific pattern.
///
/// You can also provide [IssueFilter] object to filter out the issues that you
/// want to index from the repository. It allows you to filter the issues based
/// on their labels and state (open, closed, or all).
///
/// Example:
/// ```dart
/// final githubUrl = 'https://github.com/flutter/flutter';
///
/// // filter out dart files
/// final codeFilter = CodeFilter(pathRegex: '.*\.dart');
///
/// // filter out issues with label "bug"
/// final issueFilter = IssueFilter(labels: ['bug']);
///
/// final githubObject = WebDataObject.fromGithub(githubUrl,
///     codeFilter: codeFilter, issueFilter: issueFilter);
/// ```
class Github extends WebDataObject {
  /// GitHub repo link that you want to extract and save for referencing
  final String url;

  /// This parameter is optional. [CodeFilter] object to selectively choose the
  /// repository codes files based on the specified pattern. Currently you can
  /// choose the files by proving regex string for fetching files that
  /// follow specific patterns
  final CodeFilter? codeFilter;

  /// This parameter is optional. [IssueFilter] object to pick selected issues
  /// from the GitHub repository. You can filter the issues based on:
  /// **labels**: Issues which contain specific labels
  /// **issue status**: Issues which are either open, closed, or all of them
  final IssueFilter? issueFilter;

  /// This parameter is optional. [GithubExtract] enum allows you to specify
  /// what do you want to extract from the shared github repo.
  /// - `GithubExtract.code` - Instructs only extracting code from the repo.
  /// - `GithubExtract.issue` - Instructs only extrating issues from the repo.
  ///
  /// By default `GithubExtract.code` is added to the list. Therefore, it only
  /// extracts code from the repo
  final List<GithubExtract> extractOnly;

  /// Your personal github access token that can be used to get data from the
  /// Github APIs. See [here](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens#creating-a-personal-access-token-classic)
  /// to learn to generate one for you.
  ///
  /// Note: Make sure to not exponse this token in public
  final String accessToken;

  /// Creates a new [Github] object.
  ///
  /// * `url`: GitHub repo link that you want to extract and save for referencing.
  /// * `codeFilter`: [CodeFilter] object to selectively choose the
  /// repository codes files based on the specified pattern.
  /// * `issueFilter`: [IssueFilter] object to pick selected issues
  /// from the GitHub repository.
  Github(
      {required this.url,
      required this.accessToken,
      this.codeFilter,
      this.issueFilter,
      this.extractOnly = const [GithubExtract.code]});

  /// Internal method used by dash_agent to convert the shared `DataSource` to json
  /// format that can be sent on the web
  ///
  /// **Note**: Ideally, this method is not supposed to be overriden by the child
  /// objects and should not be altered. It is called automatically by the framework.
  @override
  Future<Map<String, dynamic>> process() async {
    final codeFilterJson = await codeFilter?.process();
    final issueFilterJson = await issueFilter?.process();
    return {
      'id': hashCode.toString(),
      'type': 'github',
      'github_url': url,
      'access_token': accessToken,
      'extract_only': extractOnly.map((item) => item.value).toList(),
      'code_filter': codeFilterJson,
      'issue_filter': issueFilterJson,
      'version': minCliVersion
    };
  }

  @override
  String get minCliVersion => '0.0.1';
}
