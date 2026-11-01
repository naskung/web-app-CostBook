import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:costbook/core/constants/api_constants.dart';
import 'package:costbook/core/constants/app_status.dart';
import 'package:costbook/core/utils/error_util.dart';
import 'package:costbook/core/utils/page_util.dart';
import 'package:costbook/features/category/models/product_category_model.dart';
import 'package:costbook/features/category/repository/category_repository.dart';

part 'category_event.dart';
part 'category_state.dart';

class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  CategoryBloc(this.repository) : super(const CategoryState()) {
    on<CategoriesRequested>(_onRequested);
    on<CategorySaved>(_onSaved);
    on<CategoryDeleted>(_onDeleted);
    on<CategoriesMoreRequested>(_onMoreRequested);
  }

  final CategoryRepository repository;

  // เคยโหลดแล้ว → โชว์ของเดิมทันที (ไม่ขึ้นหน้าโหลด) แล้วค่อยโหลดใหม่เงียบ ๆ / ยังไม่เคย → หน้าโหลด
  Future<void> _onRequested(CategoriesRequested event, Emitter<CategoryState> emit) async {
    final cached = repository.cachedCategoryPage();
    emit(
      cached == null
          ? state.copyWith(status: AppStatus.loading)
          : state.copyWith(
            status: AppStatus.success,
            categories: cached,
            hasMore: PageUtil.hasMore(cached.length, ApiConstants.pageSize),
          ),
    );
    try {
      final categories = await repository.getCategoryPage();
      emit(
        state.copyWith(
          status: AppStatus.success,
          categories: categories,
          hasMore: PageUtil.hasMore(categories.length, ApiConstants.pageSize),
        ),
      );
    } catch (error) {
      // มีของเดิมโชว์อยู่ (จาก cache) แล้วโหลดใหม่ไม่ได้ → โชว์ของเดิมต่อ ไม่ขึ้นหน้า error
      if (state.status == AppStatus.success) return;
      emit(state.copyWith(status: AppStatus.failure, errorCode: ErrorUtil.codeOf(error)));
    }
  }

  // บันทึกแล้วโหลดใหม่ (ได้ชื่อเรียงใหม่ + จำนวนสินค้าล่าสุด) เท่าที่เลื่อนโหลดไว้แล้ว
  Future<void> _onSaved(CategorySaved event, Emitter<CategoryState> emit) async {
    emit(state.copyWith(saveStatus: AppStatus.loading));
    try {
      await repository.saveCategory(event.category);
      final limit = PageUtil.reloadLimit(state.categories.length);
      final categories = await repository.getCategoryPage(limit: limit);
      emit(
        state.copyWith(
          saveStatus: AppStatus.success,
          categories: categories,
          hasMore: PageUtil.hasMore(categories.length, limit),
        ),
      );
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

  // หน้าต่อไป: ต่อท้ายรายการเดิม / กำลังโหลดอยู่ หรือหมดแล้ว → ไม่โหลดซ้ำ
  Future<void> _onMoreRequested(CategoriesMoreRequested event, Emitter<CategoryState> emit) async {
    if (state.status != AppStatus.success || !state.hasMore || state.moreStatus == AppStatus.loading) return;
    emit(state.copyWith(moreStatus: AppStatus.loading));
    try {
      final next = await repository.getCategoryPage(offset: state.categories.length);
      emit(
        state.copyWith(
          moreStatus: AppStatus.success,
          categories: PageUtil.append(state.categories, next, (category) => category.id),
          hasMore: PageUtil.hasMore(next.length, ApiConstants.pageSize),
        ),
      );
    } catch (_) {
      emit(state.copyWith(moreStatus: AppStatus.failure));
    }
  }
}
