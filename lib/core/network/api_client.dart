import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:costbook/core/constants/api_constants.dart';
import 'package:costbook/core/network/api_exception.dart';

class ApiClient {
  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  static String token = '';
  static void Function()? onUnauthorized;

  final http.Client _client;

  Future<dynamic> get(String path) => _send('GET', path);

  Future<dynamic> post(String path, Map<String, dynamic> body) => _send('POST', path, body);

  Future<dynamic> put(String path, Map<String, dynamic> body) => _send('PUT', path, body);

  Future<dynamic> delete(String path) => _send('DELETE', path);

  Future<dynamic> _send(String method, String path, [Map<String, dynamic>? body]) async {
    final request = http.Request(method, Uri.parse('${ApiConstants.baseUrl}$path'));
    request.headers.addAll(_headers());
    if (body != null) request.body = jsonEncode(body);

    final http.Response response;
    try {
      response = await http.Response.fromStream(await _client.send(request));
    } on http.ClientException {
      throw ApiException('network_error');
    }
    return _readBody(response);
  }

  Map<String, String> _headers() {
    final headers = {'Content-Type': 'application/json'};
    if (token.isNotEmpty) headers['Authorization'] = 'Bearer $token';
    return headers;
  }

  dynamic _readBody(http.Response response) {
    final isSuccess = response.statusCode >= 200 && response.statusCode < 300;
    if (isSuccess && response.body.isEmpty) return null;
    if (isSuccess) return jsonDecode(utf8.decode(response.bodyBytes));

    final code = _errorCode(response.body);
    if (code == 'unauthorized') onUnauthorized?.call();
    throw ApiException(code);
  }

  String _errorCode(String body) {
    try {
      final data = jsonDecode(body);
      if (data is Map && data['error'] is String) return data['error'] as String;
      return 'server_error';
    } on FormatException {
      return 'server_error';
    }
  }
}
