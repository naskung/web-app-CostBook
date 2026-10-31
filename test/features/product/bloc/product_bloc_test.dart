import 'dart:typed_data';

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

  const coffee = ProductModel(id: '1', name: 'กาแฟเย็น', category: 'เครื่องดื่ม', sellPrice: 45);
  const tea = ProductModel(id: '2', name: 'ชาไทย', category: 'เครื่องดื่ม', sellPrice: 40);
  const cake = ProductModel(id: '3', name: 'เค้กส้ม', category: 'ขนม', sellPrice: 60);

  setUpAll(() {
    registerFallbackValue(const ProductModel(name: ''));
    registerFallbackValue(Uint8List(0));
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
    expect:
        () => [
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
    expect:
        () => [
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
    expect:
        () => [
          const ProductState(status: AppStatus.success, products: [coffee], saveStatus: AppStatus.loading),
          const ProductState(status: AppStatus.success, products: [coffee, tea], saveStatus: AppStatus.success),
        ],
  );

  final photo = Uint8List.fromList([1, 2, 3]);
  const teaWithImage = ProductModel(id: '2', name: 'ชาไทย', sellPrice: 40, imageVersion: 5);

  blocTest<ProductBloc, ProductState>(
    'ProductSaved มีรูปใหม่ บันทึกสินค้าแล้วอัปโหลดรูปของสินค้านั้น',
    build: () {
      when(() => repository.saveProduct(any())).thenAnswer((_) async => tea);
      when(() => repository.uploadImage('2', photo)).thenAnswer((_) async => teaWithImage);
      when(() => repository.getProducts()).thenAnswer((_) async => [teaWithImage]);
      return ProductBloc(repository);
    },
    act: (bloc) => bloc.add(ProductSaved(const ProductModel(name: 'ชาไทย'), image: photo)),
    expect:
        () => [
          const ProductState(saveStatus: AppStatus.loading),
          const ProductState(products: [teaWithImage], saveStatus: AppStatus.success),
        ],
    verify: (_) => verify(() => repository.uploadImage('2', photo)).called(1),
  );

  blocTest<ProductBloc, ProductState>(
    'ProductSaved กดลบรูป สินค้ามีรูปอยู่ ลบรูปให้',
    build: () {
      when(() => repository.saveProduct(any())).thenAnswer((_) async => teaWithImage);
      when(() => repository.deleteImage('2')).thenAnswer((_) async => tea);
      when(() => repository.getProducts()).thenAnswer((_) async => [tea]);
      return ProductBloc(repository);
    },
    act: (bloc) => bloc.add(ProductSaved(teaWithImage, removeImage: true)),
    expect:
        () => [
          const ProductState(saveStatus: AppStatus.loading),
          const ProductState(products: [tea], saveStatus: AppStatus.success),
        ],
    verify: (_) => verify(() => repository.deleteImage('2')).called(1),
  );

  blocTest<ProductBloc, ProductState>(
    'ProductSaved กดลบรูป แต่สินค้าไม่มีรูป ไม่เรียกลบรูป',
    build: () {
      when(() => repository.saveProduct(any())).thenAnswer((_) async => tea);
      when(() => repository.getProducts()).thenAnswer((_) async => [tea]);
      return ProductBloc(repository);
    },
    act: (bloc) => bloc.add(ProductSaved(tea, removeImage: true)),
    skip: 1,
    expect:
        () => [
          const ProductState(products: [tea], saveStatus: AppStatus.success),
        ],
    verify: (_) => verifyNever(() => repository.deleteImage(any())),
  );

  blocTest<ProductBloc, ProductState>(
    'ProductSaved อัปโหลดรูปไม่สำเร็จ สินค้ายังนับว่าบันทึกแล้ว + imageErrorCode',
    build: () {
      when(() => repository.saveProduct(any())).thenAnswer((_) async => tea);
      when(() => repository.uploadImage(any(), any())).thenThrow(ApiException('product_image_too_large'));
      when(() => repository.getProducts()).thenAnswer((_) async => [tea]);
      return ProductBloc(repository);
    },
    act: (bloc) => bloc.add(ProductSaved(const ProductModel(name: 'ชาไทย'), image: photo)),
    skip: 1,
    expect:
        () => [
          const ProductState(products: [tea], saveStatus: AppStatus.success, imageErrorCode: 'product_image_too_large'),
        ],
  );

  blocTest<ProductBloc, ProductState>(
    'ProductSaved ชื่อว่าง ได้ saveStatus failure พร้อม code',
    build: () {
      when(() => repository.saveProduct(any())).thenThrow(ApiException('product_name_required'));
      return ProductBloc(repository);
    },
    act: (bloc) => bloc.add(ProductSaved(const ProductModel(name: ''))),
    expect:
        () => [
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
    expect:
        () => [
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
    expect:
        () => [
          const ProductState(status: AppStatus.success, products: [coffee], deleteStatus: AppStatus.loading),
          const ProductState(
            status: AppStatus.success,
            products: [coffee],
            deleteStatus: AppStatus.failure,
            deleteErrorCode: 'product_in_use',
          ),
        ],
  );

  test('categories ได้หมวดไม่ซ้ำ เรียงตามชื่อ ไม่รวมหมวดว่าง', () {
    const state = ProductState(products: [coffee, cake, tea, ProductModel(name: 'ไม่มีหมวด')]);
    expect(state.categories, ['ขนม', 'เครื่องดื่ม']);
  });

  test('เลือกหมวด "ขนม" เห็นแค่เค้กส้ม', () {
    const state = ProductState(products: [coffee, tea, cake], category: 'ขนม');
    expect(state.visibleProducts, [cake]);
  });

  test('เลือกหมวดพร้อมค้นหา ต้องตรงทั้งสองอย่าง', () {
    const state = ProductState(products: [coffee, tea, cake], category: 'เครื่องดื่ม', query: 'ชา');
    expect(state.visibleProducts, [tea]);
  });

  blocTest<ProductBloc, ProductState>(
    'ProductCategoryChanged เปลี่ยนหมวด ไม่โหลดใหม่',
    build: () => ProductBloc(repository),
    act: (bloc) => bloc.add(ProductCategoryChanged('ขนม')),
    expect: () => [const ProductState(category: 'ขนม')],
  );
}
