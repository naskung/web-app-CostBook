import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:costbook/core/constants/app_status.dart';
import 'package:costbook/core/network/api_exception.dart';
import 'package:costbook/features/category/bloc/category_bloc.dart';
import 'package:costbook/features/category/models/product_category_model.dart';
import 'package:costbook/features/category/repository/category_repository.dart';

class MockCategoryRepository extends Mock implements CategoryRepository {}

void main() {
  late MockCategoryRepository repository;

  const print3d = ProductCategoryModel(id: 'c1', name: 'งานพิมพ์ 3D', productCount: 2);
  const keychain = ProductCategoryModel(id: 'c2', name: 'พวงกุญแจ');

  setUpAll(() => registerFallbackValue(const ProductCategoryModel(name: '')));

  setUp(() => repository = MockCategoryRepository());

  blocTest<CategoryBloc, CategoryState>(
    'CategoriesRequested สำเร็จ ได้หมวดทั้งหมด',
    build: () {
      when(() => repository.getCategories()).thenAnswer((_) async => [print3d]);
      return CategoryBloc(repository);
    },
    act: (bloc) => bloc.add(CategoriesRequested()),
    expect:
        () => [
          const CategoryState(status: AppStatus.loading),
          const CategoryState(status: AppStatus.success, categories: [print3d]),
        ],
  );

  blocTest<CategoryBloc, CategoryState>(
    'CategoriesRequested ล้มเหลว ได้ failure พร้อม code',
    build: () {
      when(() => repository.getCategories()).thenThrow(ApiException('server_error'));
      return CategoryBloc(repository);
    },
    act: (bloc) => bloc.add(CategoriesRequested()),
    expect:
        () => [
          const CategoryState(status: AppStatus.loading),
          const CategoryState(status: AppStatus.failure, errorCode: 'server_error'),
        ],
  );

  blocTest<CategoryBloc, CategoryState>(
    'CategorySaved สำเร็จ บันทึกแล้วโหลดหมวดใหม่',
    build: () {
      when(() => repository.saveCategory(any())).thenAnswer((_) async {});
      when(() => repository.getCategories()).thenAnswer((_) async => [print3d, keychain]);
      return CategoryBloc(repository);
    },
    seed: () => const CategoryState(status: AppStatus.success, categories: [print3d]),
    act: (bloc) => bloc.add(CategorySaved(const ProductCategoryModel(name: 'พวงกุญแจ'))),
    expect:
        () => [
          const CategoryState(status: AppStatus.success, categories: [print3d], saveStatus: AppStatus.loading),
          const CategoryState(
            status: AppStatus.success,
            categories: [print3d, keychain],
            saveStatus: AppStatus.success,
          ),
        ],
  );

  blocTest<CategoryBloc, CategoryState>(
    'CategorySaved ชื่อซ้ำ ได้ saveStatus failure พร้อม code',
    build: () {
      when(() => repository.saveCategory(any())).thenThrow(ApiException('category_name_taken'));
      return CategoryBloc(repository);
    },
    act: (bloc) => bloc.add(CategorySaved(const ProductCategoryModel(name: 'งานพิมพ์ 3D'))),
    expect:
        () => [
          const CategoryState(saveStatus: AppStatus.loading),
          const CategoryState(saveStatus: AppStatus.failure, saveErrorCode: 'category_name_taken'),
        ],
  );

  blocTest<CategoryBloc, CategoryState>(
    'CategoryDeleted สำเร็จ หมวดหายจากรายการ',
    build: () {
      when(() => repository.deleteCategory('c1')).thenAnswer((_) async {});
      return CategoryBloc(repository);
    },
    seed: () => const CategoryState(status: AppStatus.success, categories: [print3d, keychain]),
    act: (bloc) => bloc.add(CategoryDeleted('c1')),
    expect:
        () => [
          const CategoryState(
            status: AppStatus.success,
            categories: [print3d, keychain],
            deleteStatus: AppStatus.loading,
          ),
          const CategoryState(status: AppStatus.success, categories: [keychain], deleteStatus: AppStatus.success),
        ],
  );

  blocTest<CategoryBloc, CategoryState>(
    'CategoryDeleted ล้มเหลว หมวดยังอยู่ ได้ deleteErrorCode',
    build: () {
      when(() => repository.deleteCategory('c1')).thenThrow(ApiException('category_not_found'));
      return CategoryBloc(repository);
    },
    seed: () => const CategoryState(status: AppStatus.success, categories: [print3d]),
    act: (bloc) => bloc.add(CategoryDeleted('c1')),
    skip: 1,
    expect:
        () => [
          const CategoryState(
            status: AppStatus.success,
            categories: [print3d],
            deleteStatus: AppStatus.failure,
            deleteErrorCode: 'category_not_found',
          ),
        ],
  );
}
