import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:costbook/core/constants/api_constants.dart';
import 'package:costbook/core/network/api_exception.dart';

class ApiClient {
  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  static String token = '';

  final http.Client _client;

  Future<dynamic> post(String path, Map<String, dynamic> body) async {
    final http.Response response;
    try {
      response = await _client.post(
        Uri.parse('${ApiConstants.baseUrl}$path'),
        headers: _headers(),
        body: jsonEncode(body),
      );
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
    if (isSuccess) return jsonDecode(response.body);
    throw ApiException(_errorCode(response.body));
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
