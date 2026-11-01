import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import 'package:costbook/core/constants/api_constants.dart';
import 'package:costbook/core/network/api_exception.dart';

class ApiClient {
  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  static String token = '';
  static void Function()? onUnauthorized;

  final http.Client _client;

  // header ที่ต้องส่งตอนโหลดรูปที่ต้อง login (เช่น รูปสินค้า) ด้วย Image.network
  static Map<String, String> get authHeaders => token.isEmpty ? const {} : {'Authorization': 'Bearer $token'};

  Future<dynamic> get(String path) => _send('GET', path);

  Future<dynamic> post(String path, Map<String, dynamic> body) => _send('POST', path, body);

  Future<dynamic> put(String path, Map<String, dynamic> body) => _send('PUT', path, body);

  Future<dynamic> delete(String path) => _send('DELETE', path);

  // ส่งไฟล์แบบ multipart/form-data (PUT) ในช่องชื่อ field เช่น รูปสินค้า
  Future<dynamic> putFile(String path, String field, Uint8List bytes, String filename) {
    final request = http.MultipartRequest('PUT', Uri.parse('${ApiConstants.baseUrl}$path'));
    request.headers.addAll(authHeaders);
    request.files.add(http.MultipartFile.fromBytes(field, bytes, filename: filename));
    return _sendRequest(request);
  }

  Future<dynamic> _send(String method, String path, [Map<String, dynamic>? body]) {
    final request = http.Request(method, Uri.parse('${ApiConstants.baseUrl}$path'));
    request.headers.addAll(_headers());
    if (body != null) request.body = jsonEncode(body);
    return _sendRequest(request);
  }

  Future<dynamic> _sendRequest(http.BaseRequest request) async {
    final http.Response response;
    try {
      response = await http.Response.fromStream(await _client.send(request));
    } on http.ClientException {
      throw ApiException('network_error');
    }
    return _readBody(response);
  }

  Map<String, String> _headers() => {'Content-Type': 'application/json', ...authHeaders};

  dynamic _readBody(http.Response response) {
    final isSuccess = response.statusCode >= 200 && response.statusCode < 300;
    if (isSuccess && response.body.isEmpty) return null;
    if (isSuccess) return jsonDecode(utf8.decode(response.bodyBytes));

    final code = _errorCode(response.body);
    if (code == 'unauthorized') onUnauthorized?.call();
    throw ApiException(code, params: _errorParams(response.bodyBytes));
  }

  // ค่าอื่นที่มากับ error เช่น {"error":"material_not_enough","material":"เส้น TPU","need":300} → {material: เส้น TPU, need: 300}
  Map<String, String> _errorParams(List<int> bodyBytes) {
    try {
      final data = jsonDecode(utf8.decode(bodyBytes));
      if (data is! Map) return const {};
      return {
        for (final entry in data.entries)
          if (entry.key != 'error') entry.key.toString(): entry.value.toString(),
      };
    } on FormatException {
      return const {};
    }
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
