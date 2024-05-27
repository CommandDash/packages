import 'package:http/http.dart' as http;
import 'package:xml/xml.dart' as xml;

class SitemapHelper {
  static Future<List<String>> fetchAndFilterUrls(
      String sitemapUrl, List<RegExp> urlPatterns) async {
    final response = await http.get(Uri.parse(sitemapUrl));

    if (response.statusCode == 200) {
      final xmlDoc = xml.XmlDocument.parse(response.body);
      final urls = xmlDoc
          .findAllElements('loc')
          .map((element) => element.text)
          .where((url) => urlPatterns.any((pattern) => pattern.hasMatch(url)))
          .toList();

      return urls;
    } else {
      throw Exception('Failed to fetch sitemap: ${response.statusCode}');
    }
  }
}
