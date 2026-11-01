import 'dart:typed_data';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:costbook/core/constants/app_status.dart';
import 'package:costbook/core/network/api_exception.dart';
import 'package:costbook/features/category/models/product_category_model.dart';
import 'package:costbook/features/category/repository/category_repository.dart';
import 'package:costbook/features/product/bloc/product_bloc.dart';
import 'package:costbook/features/product/models/product_model.dart';
import 'package:costbook/features/product/repository/product_repository.dart';

class MockProductRepository extends Mock implements ProductRepository {}

class MockCategoryRepository extends Mock implements CategoryRepository {}

void main() {
  late MockProductRepository repository;
  late MockCategoryRepository categoryRepository;

  const drinks = ProductCategoryModel(id: 'c-drink', name: 'เครื่องดื่ม', productCount: 2);
  const coffee = ProductModel(id: '1', name: 'กาแฟเย็น', categoryId: 'c-drink', category: 'เครื่องดื่ม', sellPrice: 45);
  const tea = ProductModel(id: '2', name: 'ชาไทย', categoryId: 'c-drink', category: 'เครื่องดื่ม', sellPrice: 40);
  const cake = ProductModel(id: '3', name: 'เค้กส้ม', categoryId: 'c-snack', category: 'ขนม', sellPrice: 60);

  setUpAll(() {
    registerFallbackValue(const ProductModel(name: ''));
    registerFallbackValue(Uint8List(0));
  });

  setUp(() {
    repository = MockProductRepository();
    categoryRepository = MockCategoryRepository();
    when(() => categoryRepository.getCategories()).thenAnswer((_) async => []);
  });

  blocTest<ProductBloc, ProductState>(
    'ProductsRequested สำเร็จ ได้ loading แล้ว success พร้อมรายการสินค้า',
    build: () {
      when(() => repository.getProducts()).thenAnswer((_) async => [coffee, tea]);
      return ProductBloc(repository, categoryRepository);
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
      return ProductBloc(repository, categoryRepository);
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
      return ProductBloc(repository, categoryRepository);
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
      return ProductBloc(repository, categoryRepository);
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
      return ProductBloc(repository, categoryRepository);
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
      return ProductBloc(repository, categoryRepository);
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
      return ProductBloc(repository, categoryRepository);
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
      return ProductBloc(repository, categoryRepository);
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
      return ProductBloc(repository, categoryRepository);
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
      return ProductBloc(repository, categoryRepository);
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

  blocTest<ProductBloc, ProductState>(
    'ProductsRequested โหลดหมวดหมู่จาก API มาด้วย (ไว้กรอง + เลือกในฟอร์ม)',
    build: () {
      when(() => repository.getProducts()).thenAnswer((_) async => [coffee]);
      when(() => categoryRepository.getCategories()).thenAnswer((_) async => [drinks]);
      return ProductBloc(repository, categoryRepository);
    },
    act: (bloc) => bloc.add(ProductsRequested()),
    skip: 1,
    expect:
        () => [
          const ProductState(status: AppStatus.success, products: [coffee], categories: [drinks]),
        ],
  );

  test('เลือกหมวด (id) c-snack เห็นแค่เค้กส้ม', () {
    const state = ProductState(products: [coffee, tea, cake], category: 'c-snack');
    expect(state.visibleProducts, [cake]);
  });

  test('เลือกหมวดพร้อมค้นหา ต้องตรงทั้งสองอย่าง', () {
    const state = ProductState(products: [coffee, tea, cake], category: 'c-drink', query: 'ชา');
    expect(state.visibleProducts, [tea]);
  });

  const lowCoffee = ProductModel(id: '4', name: 'กาแฟดำ', stock: 1, minStock: 5);
  const service = ProductModel(id: '5', name: 'ค่าออกแบบ', trackStock: false);

  const okTea = ProductModel(id: '6', name: 'ชาเขียว', stock: 20, minStock: 5);

  test('เฉพาะใกล้หมด เห็นแค่สินค้าที่นับสต็อกและคงเหลือ ≤ ขั้นต่ำ', () {
    const state = ProductState(products: [okTea, lowCoffee, service], onlyLow: true);
    expect(state.visibleProducts, [lowCoffee]);
    expect(state.lowStockCount, 1);
  });

  blocTest<ProductBloc, ProductState>(
    'ProductCategoryChanged เปลี่ยนหมวด ไม่โหลดใหม่',
    build: () => ProductBloc(repository, categoryRepository),
    act: (bloc) => bloc.add(ProductCategoryChanged('c-snack')),
    expect: () => [const ProductState(category: 'c-snack')],
  );

  blocTest<ProductBloc, ProductState>(
    'ProductLowStockFilterChanged เปิดกรองใกล้หมด ไม่โหลดใหม่',
    build: () => ProductBloc(repository, categoryRepository),
    act: (bloc) => bloc.add(ProductLowStockFilterChanged(onlyLow: true)),
    expect: () => [const ProductState(onlyLow: true)],
  );

  test('เปิดหน้ามาแบบ onlyLow (จากหน้าภาพรวม) state เริ่มต้นกรองใกล้หมดเลย', () {
    expect(ProductBloc(repository, categoryRepository, onlyLow: true).state.onlyLow, true);
  });

  const pla = ProductModel(id: '7', name: 'เส้น PLA', unit: 'กรัม', stock: 900, minStock: 200, forSale: false);

  test('กรองวัสดุ เห็นแค่สินค้าที่ไม่ขาย / กรองสินค้าขาย ไม่เห็นวัสดุ', () {
    const materials = ProductState(products: [coffee, pla], kind: ProductState.kindMaterial);
    const forSale = ProductState(products: [coffee, pla], kind: ProductState.kindForSale);
    expect(materials.visibleProducts, [pla]);
    expect(forSale.visibleProducts, [coffee]);
  });

  test('นับจำนวนสินค้าของแต่ละแท็บ จากสินค้าทั้งหมด (ไม่สนคำค้น / แท็บที่เลือกอยู่)', () {
    const state = ProductState(products: [coffee, tea, pla], kind: ProductState.kindMaterial, query: 'ชา');
    expect(
      [state.kindCount(''), state.kindCount(ProductState.kindForSale), state.kindCount(ProductState.kindMaterial)],
      [3, 2, 1],
    );
  });

  blocTest<ProductBloc, ProductState>(
    'ProductKindChanged เปลี่ยนตัวกรองขาย / วัสดุ ไม่โหลดใหม่',
    build: () => ProductBloc(repository, categoryRepository),
    act: (bloc) => bloc.add(ProductKindChanged(ProductState.kindMaterial)),
    expect: () => [const ProductState(kind: ProductState.kindMaterial)],
  );
}
