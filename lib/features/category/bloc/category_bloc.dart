import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:costbook/core/constants/app_status.dart';
import 'package:costbook/core/utils/error_util.dart';
import 'package:costbook/features/category/models/product_category_model.dart';
import 'package:costbook/features/category/repository/category_repository.dart';

part 'category_event.dart';
part 'category_state.dart';

class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  CategoryBloc(this.repository) : super(const CategoryState()) {
    on<CategoriesRequested>(_onRequested);
    on<CategorySaved>(_onSaved);
    on<CategoryDeleted>(_onDeleted);
  }

  final CategoryRepository repository;

  // เคยโหลดแล้ว → โชว์ของเดิมทันที (ไม่ขึ้นหน้าโหลด) แล้วค่อยโหลดใหม่เงียบ ๆ / ยังไม่เคย → หน้าโหลด
  Future<void> _onRequested(CategoriesRequested event, Emitter<CategoryState> emit) async {
    final cached = repository.cachedCategories();
    emit(
      cached == null
          ? state.copyWith(status: AppStatus.loading)
          : state.copyWith(status: AppStatus.success, categories: cached),
    );
    try {
      final categories = await repository.getCategories();
      emit(state.copyWith(status: AppStatus.success, categories: categories));
    } catch (error) {
      // มีของเดิมโชว์อยู่ (จาก cache) แล้วโหลดใหม่ไม่ได้ → โชว์ของเดิมต่อ ไม่ขึ้นหน้า error
      if (state.status == AppStatus.success) return;
      emit(state.copyWith(status: AppStatus.failure, errorCode: ErrorUtil.codeOf(error)));
    }
  }

  // บันทึกแล้วโหลดใหม่ (ได้ชื่อเรียงใหม่ + จำนวนสินค้าล่าสุด)
  Future<void> _onSaved(CategorySaved event, Emitter<CategoryState> emit) async {
    emit(state.copyWith(saveStatus: AppStatus.loading));
    try {
      await repository.saveCategory(event.category);
      final categories = await repository.getCategories();
      emit(state.copyWith(saveStatus: AppStatus.success, categories: categories));
    } catch (error) {
      emit(state.copyWith(saveStatus: AppStatus.failure, saveErrorCode: ErrorUtil.codeOf(error)));
    }
  }

  Future<void> _onDeleted(CategoryDeleted event, Emitter<CategoryState> emit) async {
    emit(state.copyWith(deleteStatus: AppStatus.loading));
    try {
      await repository.deleteCategory(event.id);
      final categories = state.categories.where((category) => category.id != event.id).toList();
      emit(state.copyWith(deleteStatus: AppStatus.success, categories: categories));
    } catch (error) {
      emit(state.copyWith(deleteStatus: AppStatus.failure, deleteErrorCode: ErrorUtil.codeOf(error)));
    }
  }
}
