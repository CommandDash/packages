/// Base class for adding data to [DataSource] from the web pages
///
/// This class should not be directly used to add data as this is a `abstract` class.
/// Instead its derivative classes should be used: [WebPage], [SiteMap]
abstract class WebDataObject {
  String get version;
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
  WebPage(this.url);

  /// url of the web page that contains the content that you want to save for referencing.
  final String url;

  @override
  Future<Map<String, dynamic>> process() async {
    return {
      'id': hashCode.toString(),
      'type': 'web_page',
      'url': url,
      'version': version
    };
  }

  @override
  String get version => '0.0.1';
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
      'version': version
    };
  }

  @override
  String get version => '0.0.1';
}
