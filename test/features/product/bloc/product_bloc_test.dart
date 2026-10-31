import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:costbook/core/constants/app_status.dart';
import 'package:costbook/core/network/api_exception.dart';
import 'package:costbook/features/product/bloc/product_bloc.dart';
import 'package:costbook/features/product/models/product_model.dart';
import 'package:costbook/features/product/repository/product_repository.dart';

class MockProductRepository extends Mock implements ProductRepository {}

void main() {
  late MockProductRepository repository;

  const coffee = ProductModel(id: '1', name: 'กาแฟเย็น', sellPrice: 45);
  const tea = ProductModel(id: '2', name: 'ชาไทย', sellPrice: 40);

  setUpAll(() {
    registerFallbackValue(const ProductModel(name: ''));
  });

  setUp(() {
    repository = MockProductRepository();
  });

  blocTest<ProductBloc, ProductState>(
    'ProductsRequested สำเร็จ ได้ loading แล้ว success พร้อมรายการสินค้า',
    build: () {
      when(() => repository.getProducts()).thenAnswer((_) async => [coffee, tea]);
      return ProductBloc(repository);
    },
    act: (bloc) => bloc.add(ProductsRequested()),
    expect: () => [
      const ProductState(status: AppStatus.loading),
      const ProductState(status: AppStatus.success, products: [coffee, tea]),
    ],
  );

  blocTest<ProductBloc, ProductState>(
    'ProductsRequested ล้มเหลว ได้ failure พร้อม code',
    build: () {
      when(() => repository.getProducts()).thenThrow(ApiException('server_error'));
      return ProductBloc(repository);
    },
    act: (bloc) => bloc.add(ProductsRequested()),
    expect: () => [
      const ProductState(status: AppStatus.loading),
      const ProductState(status: AppStatus.failure, errorCode: 'server_error'),
    ],
  );

  test('ค้นหา "ชา" เหลือแค่ชาไทย (ไม่สนตัวพิมพ์เล็ก-ใหญ่)', () {
    const state = ProductState(products: [coffee, tea], query: ' ชา ');
    expect(state.visibleProducts, [tea]);
  });

  test('ไม่พิมพ์ค้นหา เห็นสินค้าทั้งหมด', () {
    const state = ProductState(products: [coffee, tea]);
    expect(state.visibleProducts, [coffee, tea]);
  });

  blocTest<ProductBloc, ProductState>(
    'ProductSaved สำเร็จ บันทึกแล้วโหลดรายการใหม่',
    build: () {
      when(() => repository.saveProduct(any())).thenAnswer((_) async => tea);
      when(() => repository.getProducts()).thenAnswer((_) async => [coffee, tea]);
      return ProductBloc(repository);
    },
    seed: () => const ProductState(status: AppStatus.success, products: [coffee]),
    act: (bloc) => bloc.add(ProductSaved(const ProductModel(name: 'ชาไทย', sellPrice: 40))),
    expect: () => [
      const ProductState(status: AppStatus.success, products: [coffee], saveStatus: AppStatus.loading),
      const ProductState(status: AppStatus.success, products: [coffee, tea], saveStatus: AppStatus.success),
    ],
  );

  blocTest<ProductBloc, ProductState>(
    'ProductSaved ชื่อว่าง ได้ saveStatus failure พร้อม code',
    build: () {
      when(() => repository.saveProduct(any())).thenThrow(ApiException('product_name_required'));
      return ProductBloc(repository);
    },
    act: (bloc) => bloc.add(ProductSaved(const ProductModel(name: ''))),
    expect: () => [
      const ProductState(saveStatus: AppStatus.loading),
      const ProductState(saveStatus: AppStatus.failure, saveErrorCode: 'product_name_required'),
    ],
  );

  blocTest<ProductBloc, ProductState>(
    'ProductDeleted สำเร็จ สินค้าหายจากรายการ',
    build: () {
      when(() => repository.deleteProduct('1')).thenAnswer((_) async {});
      return ProductBloc(repository);
    },
    seed: () => const ProductState(status: AppStatus.success, products: [coffee, tea]),
    act: (bloc) => bloc.add(ProductDeleted('1')),
    expect: () => [
      const ProductState(status: AppStatus.success, products: [coffee, tea], deleteStatus: AppStatus.loading),
      const ProductState(status: AppStatus.success, products: [tea], deleteStatus: AppStatus.success),
    ],
  );

  blocTest<ProductBloc, ProductState>(
    'ProductDeleted สินค้าอยู่ในใบกำกับ ได้ deleteStatus failure และสินค้ายังอยู่',
    build: () {
      when(() => repository.deleteProduct('1')).thenThrow(ApiException('product_in_use'));
      return ProductBloc(repository);
    },
    seed: () => const ProductState(status: AppStatus.success, products: [coffee]),
    act: (bloc) => bloc.add(ProductDeleted('1')),
    expect: () => [
      const ProductState(status: AppStatus.success, products: [coffee], deleteStatus: AppStatus.loading),
      const ProductState(
        status: AppStatus.success,
        products: [coffee],
        deleteStatus: AppStatus.failure,
        deleteErrorCode: 'product_in_use',
      ),
    ],
  );
}
