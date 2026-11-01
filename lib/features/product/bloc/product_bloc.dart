import 'dart:typed_data';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:costbook/core/constants/api_constants.dart';
import 'package:costbook/core/constants/app_status.dart';
import 'package:costbook/core/utils/error_util.dart';
import 'package:costbook/core/utils/page_util.dart';
import 'package:costbook/features/category/models/product_category_model.dart';
import 'package:costbook/features/category/repository/category_repository.dart';
import 'package:costbook/features/product/models/product_counts_model.dart';
import 'package:costbook/features/product/models/product_model.dart';
import 'package:costbook/features/product/repository/product_repository.dart';

part 'product_event.dart';
part 'product_state.dart';

// หน้ารายการสินค้า: โหลดทีละ 20 / ค้นหา กรองหมวด แท็บ เฉพาะใกล้หมด ให้ API ทำ (เปลี่ยนตัวกรอง = โหลดหน้าแรกใหม่)
class ProductBloc extends Bloc<ProductEvent, ProductState> {
  // onlyLow = เปิดหน้ามาแบบกรองเฉพาะใกล้หมด (เช่น กดจากหน้าภาพรวม)
  ProductBloc(this.repository, this.categoryRepository, {bool onlyLow = false})
    : super(ProductState(onlyLow: onlyLow)) {
    on<ProductsRequested>(_onProductsRequested);
    on<ProductsMoreRequested>(_onMoreRequested);
    on<ProductSearchChanged>(_onSearchChanged);
    on<ProductCategoryChanged>(_onCategoryChanged);
    on<ProductLowStockFilterChanged>(_onLowStockFilterChanged);
    on<ProductKindChanged>(_onKindChanged);
    on<ProductSaved>(_onProductSaved);
    on<ProductDeleted>(_onProductDeleted);
  }

  final ProductRepository repository;
  final CategoryRepository categoryRepository;

  // พิมพ์ค้นหา: รอพิมพ์เสร็จเท่านี้ก่อนค่อยถาม API (ไม่ยิงทุกตัวอักษรที่พิมพ์)
  static const Duration searchDelay = Duration(milliseconds: 300);

  // หมวด (ปุ่มกรอง / ฟอร์ม) + จำนวนสินค้า (ตัวเลขบนแท็บ) + หน้าแรกของตัวกรองตอนนี้
  Future<void> _onProductsRequested(ProductsRequested event, Emitter<ProductState> emit) async {
    _showCachedFirst(emit);
    final filterKey = state.filterKey;
    try {
      final categories = await categoryRepository.getCategories();
      final counts = await repository.getCounts();
      final products = await _fetchPage();
      if (state.filterKey != filterKey) {
        // ตัวกรองเปลี่ยนระหว่างรอ → เก็บหมวด / จำนวนไว้ ส่วนรายการรอผลของตัวกรองใหม่
        emit(state.copyWith(categories: categories, counts: counts));
        return;
      }
      emit(
        state.copyWith(
          status: AppStatus.success,
          products: products,
          categories: categories,
          counts: counts,
          hasMore: PageUtil.hasMore(products.length, ApiConstants.pageSize),
          moreStatus: AppStatus.initial,
        ),
      );
    } catch (error) {
      // มีของเดิมโชว์อยู่ (จาก cache) แล้วโหลดใหม่ไม่ได้ → โชว์ของเดิมต่อ ไม่ขึ้นหน้า error
      if (state.status == AppStatus.success) return;
      emit(state.copyWith(status: AppStatus.failure, errorCode: ErrorUtil.codeOf(error)));
    }
  }

  // เคยโหลดแล้ว → โชว์ของเดิมทันที (ไม่ขึ้นหน้าโหลด) แล้วค่อยโหลดใหม่เงียบ ๆ / ยังไม่เคย → หน้าโหลด
  void _showCachedFirst(Emitter<ProductState> emit) {
    final products = repository.cachedProductPage(
      query: state.query,
      categoryId: state.category,
      kind: state.kind,
      onlyLow: state.onlyLow,
    );
    final categories = categoryRepository.cachedCategories();
    final counts = repository.cachedCounts();
    if (products == null || categories == null || counts == null) {
      emit(state.copyWith(status: AppStatus.loading));
      return;
    }
    emit(
      state.copyWith(
        status: AppStatus.success,
        products: products,
        categories: categories,
        counts: counts,
        hasMore: PageUtil.hasMore(products.length, ApiConstants.pageSize),
      ),
    );
  }

  // สินค้าตามตัวกรองตอนนี้ ตั้งแต่ตัวที่ offset จำนวน limit ตัว
  Future<List<ProductModel>> _fetchPage({int offset = 0, int limit = ApiConstants.pageSize}) {
    return repository.getProductPage(
      query: state.query,
      categoryId: state.category,
      kind: state.kind,
      onlyLow: state.onlyLow,
      offset: offset,
      limit: limit,
    );
  }

  // โหลดหน้าแรกใหม่ตามตัวกรองตอนนี้ (รายการเดิมยังแสดงอยู่ระหว่างรอ + แถบโหลดบาง ๆ)
  // ระหว่างรอ ตัวกรองเปลี่ยนอีก → ทิ้งผลนี้ (ผลของตัวกรองล่าสุดตามมาเอง)
  Future<void> _reloadFirstPage(Emitter<ProductState> emit, {int limit = ApiConstants.pageSize}) async {
    final filterKey = state.filterKey;
    emit(state.copyWith(isFiltering: true, moreStatus: AppStatus.initial));
    try {
      final products = await _fetchPage(limit: limit);
      if (state.filterKey != filterKey) return;
      emit(
        state.copyWith(
          status: AppStatus.success,
          products: products,
          hasMore: PageUtil.hasMore(products.length, limit),
          isFiltering: false,
        ),
      );
    } catch (error) {
      if (state.filterKey != filterKey) return;
      emit(state.copyWith(status: AppStatus.failure, errorCode: ErrorUtil.codeOf(error), isFiltering: false));
    }
  }

  // หน้าต่อไป: ต่อท้ายรายการเดิม / กำลังโหลดอยู่ หมดแล้ว หรือกำลังเปลี่ยนตัวกรอง → ไม่โหลด
  Future<void> _onMoreRequested(ProductsMoreRequested event, Emitter<ProductState> emit) async {
    final isBusy = state.moreStatus == AppStatus.loading || state.isFiltering;
    if (state.status != AppStatus.success || !state.hasMore || isBusy) return;
    final filterKey = state.filterKey;
    emit(state.copyWith(moreStatus: AppStatus.loading));
    try {
      final next = await _fetchPage(offset: state.products.length);
      if (state.filterKey != filterKey) return;
      emit(
        state.copyWith(
          moreStatus: AppStatus.success,
          products: PageUtil.append(state.products, next, (product) => product.id),
          hasMore: PageUtil.hasMore(next.length, ApiConstants.pageSize),
        ),
      );
    } catch (_) {
      if (state.filterKey != filterKey) return;
      emit(state.copyWith(moreStatus: AppStatus.failure));
    }
  }

  // พิมพ์ค้นหา: เก็บคำค้นทันที (ช่องค้นหาไม่หน่วง) แต่รอ searchDelay — พิมพ์ต่อระหว่างนั้น = รอคำล่าสุดแทน
  Future<void> _onSearchChanged(ProductSearchChanged event, Emitter<ProductState> emit) async {
    emit(state.copyWith(query: event.query));
    await Future<void>.delayed(searchDelay);
    if (state.query != event.query) return;
    await _reloadFirstPage(emit);
  }

  Future<void> _onCategoryChanged(ProductCategoryChanged event, Emitter<ProductState> emit) async {
    emit(state.copyWith(category: event.category));
    await _reloadFirstPage(emit);
  }

  Future<void> _onLowStockFilterChanged(ProductLowStockFilterChanged event, Emitter<ProductState> emit) async {
    emit(state.copyWith(onlyLow: event.onlyLow));
    await _reloadFirstPage(emit);
  }

  Future<void> _onKindChanged(ProductKindChanged event, Emitter<ProductState> emit) async {
    emit(state.copyWith(kind: event.kind));
    await _reloadFirstPage(emit);
  }

  // บันทึกสินค้าก่อน แล้วค่อยอัปโหลด / ลบรูป
  // รูปพังแต่สินค้าบันทึกแล้ว → ยังนับว่าสำเร็จ (ปิดกล่องฟอร์ม กันกดบันทึกซ้ำจนได้สินค้าซ้ำ) แล้วบอกผ่าน imageErrorCode
  // แล้วโหลดใหม่เท่าที่เลื่อนไว้ (รายการไม่หดกลับเหลือหน้าแรก) + นับจำนวนใหม่
  Future<void> _onProductSaved(ProductSaved event, Emitter<ProductState> emit) async {
    emit(state.copyWith(saveStatus: AppStatus.loading, imageErrorCode: ''));
    final ProductModel saved;
    try {
      saved = await repository.saveProduct(event.product);
    } catch (error) {
      emit(state.copyWith(saveStatus: AppStatus.failure, saveErrorCode: ErrorUtil.codeOf(error)));
      return;
    }

    var imageErrorCode = '';
    try {
      final image = event.image;
      if (image != null) {
        await repository.uploadImage(saved.id, image);
      } else if (event.removeImage && saved.hasImage) {
        await repository.deleteImage(saved.id);
      }
    } catch (error) {
      imageErrorCode = ErrorUtil.codeOf(error);
    }

    try {
      final limit = PageUtil.reloadLimit(state.products.length);
      final products = await _fetchPage(limit: limit);
      final counts = await repository.getCounts();
      emit(
        state.copyWith(
          saveStatus: AppStatus.success,
          products: products,
          counts: counts,
          hasMore: PageUtil.hasMore(products.length, limit),
          imageErrorCode: imageErrorCode,
        ),
      );
    } catch (error) {
      emit(state.copyWith(saveStatus: AppStatus.success, imageErrorCode: imageErrorCode));
    }
  }

  Future<void> _onProductDeleted(ProductDeleted event, Emitter<ProductState> emit) async {
    emit(state.copyWith(deleteStatus: AppStatus.loading));
    try {
      await repository.deleteProduct(event.id);
      final products = state.products.where((product) => product.id != event.id).toList();
      emit(state.copyWith(deleteStatus: AppStatus.success, products: products));
    } catch (error) {
      emit(state.copyWith(deleteStatus: AppStatus.failure, deleteErrorCode: ErrorUtil.codeOf(error)));
      return;
    }
    try {
      emit(state.copyWith(counts: await repository.getCounts()));
    } catch (_) {
      // นับใหม่ไม่ได้ → ใช้ตัวเลขเดิมไปก่อน (เปิดหน้าใหม่ก็ถูกเอง)
    }
  }
}
