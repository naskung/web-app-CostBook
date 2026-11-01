import 'dart:async';
import 'dart:typed_data';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:costbook/core/constants/app_status.dart';
import 'package:costbook/core/network/api_exception.dart';
import 'package:costbook/features/category/models/product_category_model.dart';
import 'package:costbook/features/category/repository/category_repository.dart';
import 'package:costbook/features/product/bloc/product_bloc.dart';
import 'package:costbook/features/product/models/product_counts_model.dart';
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
  const counts = ProductCountsModel(all: 3, forSale: 2, material: 1, low: 1);

  // สินค้าตัวที่ n (id ไม่ซ้ำ) ไว้ทำหน้าเต็ม 20 ตัว
  ProductModel productAt(int n) => ProductModel(id: 'p$n', name: 'สินค้า $n');
  final fullPage = [for (var n = 1; n <= 20; n++) productAt(n)];

  // หน้าของสินค้าตามตัวกรองอะไรก็ได้ → ได้ products
  void stubPage(List<ProductModel> products) {
    when(
      () => repository.getProductPage(
        query: any(named: 'query'),
        categoryId: any(named: 'categoryId'),
        kind: any(named: 'kind'),
        onlyLow: any(named: 'onlyLow'),
        offset: any(named: 'offset'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer((_) async => products);
  }

  setUpAll(() {
    registerFallbackValue(const ProductModel(name: ''));
    registerFallbackValue(Uint8List(0));
  });

  setUp(() {
    repository = MockProductRepository();
    categoryRepository = MockCategoryRepository();
    when(() => categoryRepository.getCategories()).thenAnswer((_) async => []);
    when(() => repository.getCounts()).thenAnswer((_) async => counts);
  });

  group('โหลดหน้าแรก', () {
    blocTest<ProductBloc, ProductState>(
      'ProductsRequested: loading → success พร้อมสินค้าหน้าแรก + จำนวนสินค้าทั้งร้าน',
      build: () {
        stubPage([coffee, tea]);
        return ProductBloc(repository, categoryRepository);
      },
      act: (bloc) => bloc.add(ProductsRequested()),
      expect:
          () => [
            const ProductState(status: AppStatus.loading),
            const ProductState(status: AppStatus.success, products: [coffee, tea], counts: counts),
          ],
    );

    blocTest<ProductBloc, ProductState>(
      'ได้ครบ 20 ตัว = ยังมีหน้าต่อไป (hasMore)',
      build: () {
        stubPage(fullPage);
        return ProductBloc(repository, categoryRepository);
      },
      act: (bloc) => bloc.add(ProductsRequested()),
      verify: (bloc) => expect(bloc.state.hasMore, true),
    );

    blocTest<ProductBloc, ProductState>(
      'ProductsRequested ล้มเหลว ได้ failure พร้อม code',
      build: () {
        when(
          () => repository.getProductPage(
            query: any(named: 'query'),
            categoryId: any(named: 'categoryId'),
            kind: any(named: 'kind'),
            onlyLow: any(named: 'onlyLow'),
            offset: any(named: 'offset'),
            limit: any(named: 'limit'),
          ),
        ).thenThrow(ApiException('server_error'));
        return ProductBloc(repository, categoryRepository);
      },
      act: (bloc) => bloc.add(ProductsRequested()),
      expect:
          () => [
            const ProductState(status: AppStatus.loading),
            const ProductState(status: AppStatus.failure, errorCode: 'server_error'),
          ],
    );

    blocTest<ProductBloc, ProductState>(
      'โหลดหมวดหมู่ทั้งหมดมาด้วย (ไว้กรอง + เลือกในฟอร์ม)',
      build: () {
        stubPage([coffee]);
        when(() => categoryRepository.getCategories()).thenAnswer((_) async => [drinks]);
        return ProductBloc(repository, categoryRepository);
      },
      act: (bloc) => bloc.add(ProductsRequested()),
      verify: (bloc) => expect(bloc.state.categories, [drinks]),
    );

    blocTest<ProductBloc, ProductState>(
      'เคยโหลดแล้ว โชว์สินค้าเดิมทันที (ไม่ขึ้นหน้าโหลด) แล้วเปลี่ยนเป็นรายการใหม่เงียบ ๆ',
      build: () {
        when(() => repository.cachedProductPage()).thenReturn([coffee]);
        when(() => categoryRepository.cachedCategories()).thenReturn([drinks]);
        when(() => repository.cachedCounts()).thenReturn(counts);
        when(() => categoryRepository.getCategories()).thenAnswer((_) async => [drinks]);
        stubPage([coffee, tea]);
        return ProductBloc(repository, categoryRepository);
      },
      act: (bloc) => bloc.add(ProductsRequested()),
      expect:
          () => [
            const ProductState(status: AppStatus.success, products: [coffee], categories: [drinks], counts: counts),
            const ProductState(
              status: AppStatus.success,
              products: [coffee, tea],
              categories: [drinks],
              counts: counts,
            ),
          ],
    );

    test('เปิดหน้ามาแบบ onlyLow (จากหน้าภาพรวม) state เริ่มต้นกรองใกล้หมดเลย', () {
      expect(ProductBloc(repository, categoryRepository, onlyLow: true).state.onlyLow, true);
    });
  });

  group('ตัวกรอง (API ค้น / กรองให้ แล้วโหลดหน้าแรกใหม่)', () {
    const loaded = ProductState(status: AppStatus.success, products: [coffee, tea, cake], counts: counts);

    blocTest<ProductBloc, ProductState>(
      'เลือกหมวด → ขึ้นแถบกำลังกรอง (รายการเดิมยังอยู่) → ได้สินค้าของหมวดนั้น',
      build: () {
        stubPage([cake]);
        return ProductBloc(repository, categoryRepository);
      },
      seed: () => loaded,
      act: (bloc) => bloc.add(ProductCategoryChanged('c-snack')),
      expect:
          () => [
            loaded.copyWith(category: 'c-snack'),
            loaded.copyWith(category: 'c-snack', isFiltering: true),
            loaded.copyWith(category: 'c-snack', products: [cake]),
          ],
      verify:
          (_) => verify(
            () => repository.getProductPage(categoryId: 'c-snack', kind: '', onlyLow: false, offset: 0, limit: 20),
          ).called(1),
    );

    blocTest<ProductBloc, ProductState>(
      'พิมพ์ค้นหาต่อกัน ถาม API ครั้งเดียวด้วยคำล่าสุด (รอพิมพ์เสร็จ)',
      build: () {
        stubPage([tea]);
        return ProductBloc(repository, categoryRepository);
      },
      seed: () => loaded,
      act: (bloc) {
        bloc.add(ProductSearchChanged('ช'));
        bloc.add(ProductSearchChanged('ชา'));
      },
      wait: ProductBloc.searchDelay * 2,
      verify: (bloc) {
        verify(() => repository.getProductPage(query: 'ชา', offset: 0, limit: 20)).called(1);
        verifyNever(() => repository.getProductPage(query: 'ช', offset: 0, limit: 20));
        expect(bloc.state.products, [tea]);
      },
    );

    blocTest<ProductBloc, ProductState>(
      'เฉพาะใกล้หมด / แท็บวัสดุ ส่งตัวกรองไปให้ API',
      build: () {
        stubPage([]);
        return ProductBloc(repository, categoryRepository);
      },
      seed: () => loaded,
      act: (bloc) async {
        bloc.add(ProductLowStockFilterChanged(onlyLow: true));
        await Future<void>.delayed(Duration.zero);
        bloc.add(ProductKindChanged(ProductState.kindMaterial));
      },
      verify: (bloc) {
        verify(() => repository.getProductPage(onlyLow: true, kind: '', offset: 0, limit: 20)).called(1);
        verify(
          () => repository.getProductPage(onlyLow: true, kind: ProductState.kindMaterial, offset: 0, limit: 20),
        ).called(1);
        expect(bloc.state.products, isEmpty);
      },
    );

    blocTest<ProductBloc, ProductState>(
      'เปลี่ยนตัวกรองเร็ว ๆ ผลของตัวกรองเก่าที่มาทีหลัง ไม่ทับผลของตัวกรองล่าสุด',
      build: () {
        final slow = Completer<List<ProductModel>>();
        when(
          () => repository.getProductPage(
            categoryId: 'c-drink',
            kind: any(named: 'kind'),
            onlyLow: any(named: 'onlyLow'),
            offset: any(named: 'offset'),
            limit: any(named: 'limit'),
          ),
        ).thenAnswer((_) => slow.future);
        when(
          () => repository.getProductPage(
            categoryId: 'c-snack',
            kind: any(named: 'kind'),
            onlyLow: any(named: 'onlyLow'),
            offset: any(named: 'offset'),
            limit: any(named: 'limit'),
          ),
        ).thenAnswer((_) async {
          Future<void>.delayed(const Duration(milliseconds: 10), () => slow.complete([coffee, tea]));
          return [cake];
        });
        return ProductBloc(repository, categoryRepository);
      },
      seed: () => loaded,
      act: (bloc) {
        bloc.add(ProductCategoryChanged('c-drink'));
        bloc.add(ProductCategoryChanged('c-snack'));
      },
      wait: const Duration(milliseconds: 50),
      verify: (bloc) {
        expect(bloc.state.category, 'c-snack');
        expect(bloc.state.products, [cake]);
        expect(bloc.state.isFiltering, false);
      },
    );
  });

  group('เลื่อนลงโหลดหน้าต่อไป', () {
    blocTest<ProductBloc, ProductState>(
      'ต่อท้ายรายการเดิม ด้วยตัวกรองเดิม (offset = จำนวนที่โหลดแล้ว) ได้น้อยกว่า 20 = หมดแล้ว',
      build: () {
        stubPage([productAt(21)]);
        return ProductBloc(repository, categoryRepository);
      },
      seed: () => ProductState(status: AppStatus.success, products: fullPage, hasMore: true, kind: 'sale'),
      act: (bloc) => bloc.add(ProductsMoreRequested()),
      expect:
          () => [
            ProductState(
              status: AppStatus.success,
              products: fullPage,
              hasMore: true,
              kind: 'sale',
              moreStatus: AppStatus.loading,
            ),
            ProductState(
              status: AppStatus.success,
              products: [...fullPage, productAt(21)],
              kind: 'sale',
              moreStatus: AppStatus.success,
            ),
          ],
      verify: (_) => verify(() => repository.getProductPage(kind: 'sale', offset: 20, limit: 20)).called(1),
    );

    blocTest<ProductBloc, ProductState>(
      'หมดแล้ว / กำลังกรองอยู่ → ไม่โหลด',
      build: () => ProductBloc(repository, categoryRepository),
      seed: () => ProductState(status: AppStatus.success, products: fullPage, hasMore: true, isFiltering: true),
      act: (bloc) => bloc.add(ProductsMoreRequested()),
      expect: () => <ProductState>[],
    );

    blocTest<ProductBloc, ProductState>(
      'โหลดหน้าต่อไปไม่สำเร็จ → moreStatus failure รายการเดิมยังอยู่ (canLoadMore = false รอกดลองใหม่)',
      build: () {
        when(
          () => repository.getProductPage(
            query: any(named: 'query'),
            categoryId: any(named: 'categoryId'),
            kind: any(named: 'kind'),
            onlyLow: any(named: 'onlyLow'),
            offset: any(named: 'offset'),
            limit: any(named: 'limit'),
          ),
        ).thenThrow(ApiException('network_error'));
        return ProductBloc(repository, categoryRepository);
      },
      seed: () => ProductState(status: AppStatus.success, products: fullPage, hasMore: true),
      act: (bloc) => bloc.add(ProductsMoreRequested()),
      verify: (bloc) {
        expect(bloc.state.moreStatus, AppStatus.failure);
        expect(bloc.state.products, fullPage);
        expect(bloc.state.canLoadMore, false);
      },
    );
  });

  group('จำนวนบนแท็บ / ปุ่มใกล้หมด มาจากจำนวนสินค้าทั้งร้าน', () {
    test('kindCount / lowStockCount ใช้ counts (ไม่ใช่สินค้าที่โหลดมา)', () {
      const state = ProductState(products: [coffee], counts: counts);
      expect(
        [state.kindCount(''), state.kindCount(ProductState.kindForSale), state.kindCount(ProductState.kindMaterial)],
        [3, 2, 1],
      );
      expect(state.lowStockCount, 1);
    });

    test('filterKey เปลี่ยนเมื่อตัวกรองเปลี่ยน (ช่องว่างหน้า-หลังคำค้นไม่นับ)', () {
      const state = ProductState(query: ' ชา ');
      expect(state.filterKey, const ProductState(query: 'ชา').filterKey);
      expect(state.filterKey == state.copyWith(onlyLow: true).filterKey, false);
    });
  });

  group('บันทึก / ลบ', () {
    final photo = Uint8List.fromList([1, 2, 3]);
    const teaWithImage = ProductModel(id: '2', name: 'ชาไทย', sellPrice: 40, imageVersion: 5);
    final loaded45 = [for (var n = 1; n <= 45; n++) productAt(n)];

    blocTest<ProductBloc, ProductState>(
      'บันทึกแล้วโหลดใหม่เท่าที่เลื่อนไว้ (45 ตัว ไม่หดกลับเหลือ 20) + นับจำนวนใหม่',
      build: () {
        when(() => repository.saveProduct(any())).thenAnswer((_) async => tea);
        stubPage(loaded45);
        return ProductBloc(repository, categoryRepository);
      },
      seed: () => ProductState(status: AppStatus.success, products: loaded45, hasMore: true),
      act: (bloc) => bloc.add(ProductSaved(tea)),
      verify: (bloc) {
        verify(() => repository.getProductPage(offset: 0, limit: 45)).called(1);
        expect(bloc.state.saveStatus, AppStatus.success);
        expect(bloc.state.counts, counts);
        expect(bloc.state.hasMore, true);
      },
    );

    blocTest<ProductBloc, ProductState>(
      'มีรูปใหม่ บันทึกสินค้าแล้วอัปโหลดรูปของสินค้านั้น',
      build: () {
        when(() => repository.saveProduct(any())).thenAnswer((_) async => tea);
        when(() => repository.uploadImage('2', photo)).thenAnswer((_) async => teaWithImage);
        stubPage([teaWithImage]);
        return ProductBloc(repository, categoryRepository);
      },
      act: (bloc) => bloc.add(ProductSaved(const ProductModel(name: 'ชาไทย'), image: photo)),
      verify: (bloc) {
        verify(() => repository.uploadImage('2', photo)).called(1);
        expect(bloc.state.products, [teaWithImage]);
      },
    );

    blocTest<ProductBloc, ProductState>(
      'กดลบรูป สินค้ามีรูปอยู่ ลบรูปให้ / ไม่มีรูป ไม่เรียกลบ',
      build: () {
        when(() => repository.saveProduct(teaWithImage)).thenAnswer((_) async => teaWithImage);
        when(() => repository.saveProduct(tea)).thenAnswer((_) async => tea);
        when(() => repository.deleteImage('2')).thenAnswer((_) async => tea);
        stubPage([tea]);
        return ProductBloc(repository, categoryRepository);
      },
      act: (bloc) async {
        bloc.add(ProductSaved(teaWithImage, removeImage: true));
        await Future<void>.delayed(Duration.zero);
        bloc.add(ProductSaved(tea, removeImage: true));
      },
      verify: (_) => verify(() => repository.deleteImage('2')).called(1),
    );

    blocTest<ProductBloc, ProductState>(
      'อัปโหลดรูปไม่สำเร็จ สินค้ายังนับว่าบันทึกแล้ว + imageErrorCode',
      build: () {
        when(() => repository.saveProduct(any())).thenAnswer((_) async => tea);
        when(() => repository.uploadImage(any(), any())).thenThrow(ApiException('product_image_too_large'));
        stubPage([tea]);
        return ProductBloc(repository, categoryRepository);
      },
      act: (bloc) => bloc.add(ProductSaved(const ProductModel(name: 'ชาไทย'), image: photo)),
      verify: (bloc) {
        expect(bloc.state.saveStatus, AppStatus.success);
        expect(bloc.state.imageErrorCode, 'product_image_too_large');
      },
    );

    blocTest<ProductBloc, ProductState>(
      'ชื่อว่าง ได้ saveStatus failure พร้อม code',
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
      'ลบสำเร็จ สินค้าหายจากรายการ + นับจำนวนใหม่',
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
            const ProductState(
              status: AppStatus.success,
              products: [tea],
              deleteStatus: AppStatus.success,
              counts: counts,
            ),
          ],
    );

    blocTest<ProductBloc, ProductState>(
      'ลบสินค้าที่อยู่ในใบกำกับ ได้ deleteStatus failure และสินค้ายังอยู่',
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
  });
}
