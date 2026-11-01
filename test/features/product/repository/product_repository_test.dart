import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:costbook/core/network/api_client.dart';
import 'package:costbook/features/product/repository/product_repository.dart';

class MockApiClient extends Mock implements ApiClient {}

void main() {
  late MockApiClient api;
  late ProductRepository repository;

  setUp(() {
    api = MockApiClient();
    repository = ProductRepository(api);
    when(() => api.get(any())).thenAnswer((_) async => []);
  });

  String requestedPath() => verify(() => api.get(captureAny())).captured.single as String;

  test('หน้าแรกไม่มีตัวกรอง ส่งแค่ limit / offset', () async {
    await repository.getProductPage();
    expect(requestedPath(), '/products?limit=20&offset=0');
  });

  test('ใส่ตัวกรองที่ใช้ครบ / คำค้นภาษาไทยแปลงให้ส่งใน URL ได้ / ตัดช่องว่างหน้า-หลัง', () async {
    await repository.getProductPage(
      query: ' ชา ',
      categoryId: 'c1',
      kind: 'material',
      onlyLow: true,
      offset: 40,
      limit: 20,
    );
    final uri = Uri.parse(requestedPath());
    expect(uri.path, '/products');
    expect(uri.queryParameters, {
      'q': 'ชา',
      'category_id': 'c1',
      'kind': 'material',
      'low': 'true',
      'limit': '20',
      'offset': '40',
    });
  });

  test('จำนวนสินค้าทั้งร้านจาก /products/counts', () async {
    when(() => api.get('/products/counts')).thenAnswer((_) async => {'all': 8, 'for_sale': 2, 'material': 6, 'low': 8});
    final counts = await repository.getCounts();
    expect([counts.all, counts.forSale, counts.material, counts.low], [8, 2, 6, 8]);
  });
}
