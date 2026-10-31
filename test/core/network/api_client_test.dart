import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:costbook/core/constants/api_constants.dart';
import 'package:costbook/core/network/api_client.dart';
import 'package:costbook/core/network/api_exception.dart';

void main() {
  tearDown(() {
    ApiClient.token = '';
    ApiClient.onUnauthorized = null;
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
      final api = ApiClient(client: MockClient((request) async => throw http.ClientException('connection refused')));
      expect(await errorCodeOf(api.post('/auth/login', {})), 'network_error');
    });
  });

  group('ApiClient get / put / delete', () {
    late http.Request sentRequest;

    ApiClient recordingClient(int statusCode, String body) {
      return ApiClient(
        client: MockClient((request) async {
          sentRequest = request;
          return http.Response.bytes(utf8.encode(body), statusCode);
        }),
      );
    }

    test('get ส่ง method GET และอ่านภาษาไทยใน JSON ได้ถูก', () async {
      final api = recordingClient(200, '[{"name":"กาแฟ"}]');
      final data = await api.get('/products');
      expect(sentRequest.method, 'GET');
      expect(sentRequest.url.toString(), '${ApiConstants.baseUrl}/products');
      expect(data, [
        {'name': 'กาแฟ'},
      ]);
    });

    test('put ส่ง method PUT พร้อม JSON', () async {
      final api = recordingClient(200, '{}');
      await api.put('/products/1', {'name': 'ชา'});
      expect(sentRequest.method, 'PUT');
      expect(jsonDecode(sentRequest.body), {'name': 'ชา'});
    });

    test('delete ได้ 204 ไม่มี body คืน null ไม่ error', () async {
      final api = recordingClient(204, '');
      expect(await api.delete('/products/1'), isNull);
      expect(sentRequest.method, 'DELETE');
    });

    test('ได้ 409 stock_not_enough ได้ ApiException code นั้น', () async {
      final api = recordingClient(409, '{"error":"stock_not_enough"}');
      expect(await errorCodeOf(api.get('/stock')), 'stock_not_enough');
    });
  });

  group('ApiClient.putFile', () {
    test('ส่งไฟล์แบบ multipart ช่องที่กำหนด พร้อม token', () async {
      late http.Request sentRequest;
      final api = ApiClient(
        client: MockClient((request) async {
          sentRequest = request;
          return http.Response('{"id":"p1"}', 200);
        }),
      );
      ApiClient.token = 'abc';

      final data = await api.putFile('/products/p1/image', 'image', Uint8List.fromList([1, 2, 3]), 'product.jpg');

      expect(sentRequest.method, 'PUT');
      expect(sentRequest.url.toString(), '${ApiConstants.baseUrl}/products/p1/image');
      expect(sentRequest.headers['Authorization'], 'Bearer abc');
      expect(sentRequest.headers['content-type'], startsWith('multipart/form-data'));
      expect(
        utf8.decode(sentRequest.bodyBytes, allowMalformed: true),
        contains('name="image"; filename="product.jpg"'),
      );
      expect(data, {'id': 'p1'});
    });

    test('ได้ 400 product_image_too_large ได้ ApiException code นั้น', () async {
      final api = clientThatReplies(400, '{"error":"product_image_too_large"}');
      final call = api.putFile('/products/p1/image', 'image', Uint8List(1), 'product.jpg');
      expect(await errorCodeOf(call), 'product_image_too_large');
    });

    test('authHeaders ไม่มี token = ว่าง มี token = มี Authorization', () {
      expect(ApiClient.authHeaders, isEmpty);
      ApiClient.token = 'abc';
      expect(ApiClient.authHeaders, {'Authorization': 'Bearer abc'});
    });
  });

  group('ApiClient token หมดอายุ', () {
    test('ได้ 401 unauthorized เรียก onUnauthorized', () async {
      var called = false;
      ApiClient.onUnauthorized = () => called = true;
      final api = clientThatReplies(401, '{"error":"unauthorized"}');
      expect(await errorCodeOf(api.get('/products')), 'unauthorized');
      expect(called, true);
    });

    test('login ไม่ผ่าน (invalid_credentials) ไม่เรียก onUnauthorized', () async {
      var called = false;
      ApiClient.onUnauthorized = () => called = true;
      final api = clientThatReplies(401, '{"error":"invalid_credentials"}');
      await errorCodeOf(api.post('/auth/login', {}));
      expect(called, false);
    });
  });
}
