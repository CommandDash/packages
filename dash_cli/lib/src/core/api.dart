import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';

import '../utils/logger.dart';

class BaseApi extends IOClient {
  BaseApi([this.inner]) : super(inner);

  HttpClient? inner;

  static BaseApi get getInstance => BaseApi(
        HttpClient(context: SecurityContext(withTrustedRoots: true)),
      );

  @override
  Future<http.Response> delete(Uri url,
      {Map<String, String>? headers, Object? body, Encoding? encoding}) async {
    wtLog.log('DELETE: $url', verbose: true);
    http.Response res = await super.delete(url, headers: headers, body: body);
    return res;
  }

  @override
  Future<http.Response> get(Uri url, {Map<String, String>? headers}) async {
    wtLog.log('GET: $url', verbose: true);
    http.Response res = await super.get(url, headers: headers);
    return res;
  }

  @override
  Future<http.Response> head(Uri url, {Map<String, String>? headers}) async {
    wtLog.log('HEAD: $url', verbose: true);
    http.Response res = await super.head(url, headers: headers);
    return res;
  }

  @override
  Future<http.Response> patch(Uri url,
      {Map<String, String>? headers, Object? body, Encoding? encoding}) async {
    wtLog.log('PATCH: $url', verbose: true);
    http.Response res = await super.patch(url, headers: headers, body: body);
    return res;
  }

  @override
  Future<http.Response> post(Uri url,
      {Map<String, String>? headers, Object? body, Encoding? encoding}) async {
    wtLog.log('POST: $url', verbose: true);
    http.Response res = await super.post(url, headers: headers, body: body);
    return res;
  }

  @override
  Future<http.Response> put(Uri url,
      {Map<String, String>? headers, Object? body, Encoding? encoding}) async {
    wtLog.log('PUT: $url', verbose: true);
    http.Response res = await super.put(url, headers: headers, body: body);
    return res;
  }

  @override
  Future<String> read(Uri url, {Map<String, String>? headers}) async {
    wtLog.log('READ: $url', verbose: true);
    return super.read(url);
  }

  @override
  Future<IOStreamedResponse> send(http.BaseRequest request) async {
    http.StreamedResponse response;
    try {
      response = await super.send(request);
      return response as IOStreamedResponse;
    } catch (e) {
      rethrow;
    }
  }
}
