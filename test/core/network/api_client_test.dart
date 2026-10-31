import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:costbook/core/constants/api_constants.dart';
import 'package:costbook/core/network/api_client.dart';
import 'package:costbook/core/network/api_exception.dart';

void main() {
  tearDown(() {
    ApiClient.token = '';
  });

  ApiClient clientThatReplies(int statusCode, String body) {
    return ApiClient(client: MockClient((request) async => http.Response(body, statusCode)));
  }

  Future<String> errorCodeOf(Future<dynamic> call) async {
    try {
      await call;
    } on ApiException catch (e) {
      return e.code;
    }
    return 'ไม่ได้ throw ApiException';
  }

  group('ApiClient.post', () {
    test('ส่ง JSON ไปที่ baseUrl + path', () async {
      late http.Request sentRequest;
      final api = ApiClient(
        client: MockClient((request) async {
          sentRequest = request;
          return http.Response('{}', 200);
        }),
      );

      await api.post('/auth/login', {'email': 'a@b.com'});

      expect(sentRequest.url.toString(), '${ApiConstants.baseUrl}/auth/login');
      expect(sentRequest.headers['Content-Type'], startsWith('application/json'));
      expect(jsonDecode(sentRequest.body), {'email': 'a@b.com'});
    });

    test('ตอบ 200 ได้ข้อมูล JSON กลับมา', () async {
      final api = clientThatReplies(200, '{"token":"abc"}');
      expect(await api.post('/auth/login', {}), {'token': 'abc'});
    });

    test('ยังไม่มี token ไม่ส่ง header Authorization', () async {
      late http.Request sentRequest;
      final api = ApiClient(
        client: MockClient((request) async {
          sentRequest = request;
          return http.Response('{}', 200);
        }),
      );

      await api.post('/auth/login', {});

      expect(sentRequest.headers.containsKey('Authorization'), false);
    });

    test('มี token แล้ว ส่ง header Authorization: Bearer <token>', () async {
      ApiClient.token = 'abc';
      late http.Request sentRequest;
      final api = ApiClient(
        client: MockClient((request) async {
          sentRequest = request;
          return http.Response('{}', 200);
        }),
      );

      await api.post('/products', {});

      expect(sentRequest.headers['Authorization'], 'Bearer abc');
    });

    test('ตอบ 401 invalid_credentials ได้ ApiException code invalid_credentials', () async {
      final api = clientThatReplies(401, '{"error":"invalid_credentials"}');
      expect(await errorCodeOf(api.post('/auth/login', {})), 'invalid_credentials');
    });

    test('ตอบ error แต่ไม่มี field error ได้ code server_error', () async {
      final api = clientThatReplies(500, '{}');
      expect(await errorCodeOf(api.post('/auth/login', {})), 'server_error');
    });

    test('ตอบ error เป็นข้อความที่ไม่ใช่ JSON ได้ code server_error', () async {
      final api = clientThatReplies(502, 'Bad Gateway');
      expect(await errorCodeOf(api.post('/auth/login', {})), 'server_error');
    });

    test('ต่อ server ไม่ได้ ได้ code network_error', () async {
      final api = ApiClient(
        client: MockClient((request) async => throw http.ClientException('connection refused')),
      );
      expect(await errorCodeOf(api.post('/auth/login', {})), 'network_error');
    });
  });
}
