// lib/data/objects/web_data_object.dart
abstract class WebDataObject {
  String get version;
  const WebDataObject();

  static WebPage fromWebPage(String url) {
    return WebPage(url);
  }

  static SiteMap fromSiteMap(String xml) {
    return SiteMap(xml);
  }

  Future<Map<String, dynamic>> process();
}

class WebPage extends WebDataObject {
  WebPage(this.url);
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
  String get version => '1.0.0';
}

class SiteMap extends WebDataObject {
  SiteMap(this.xml);
  final String xml;

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
  String get version => '1.0.0';
}
