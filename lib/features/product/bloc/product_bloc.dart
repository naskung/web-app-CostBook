import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:costbook/core/constants/app_status.dart';
import 'package:costbook/core/utils/error_util.dart';
import 'package:costbook/features/product/models/product_model.dart';
import 'package:costbook/features/product/repository/product_repository.dart';

part 'product_event.dart';
part 'product_state.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  ProductBloc(this.repository) : super(const ProductState()) {
    on<ProductsRequested>(_onProductsRequested);
    on<ProductSearchChanged>(_onSearchChanged);
    on<ProductCategoryChanged>(_onCategoryChanged);
    on<ProductSaved>(_onProductSaved);
    on<ProductDeleted>(_onProductDeleted);
  }

  final ProductRepository repository;

  Future<void> _onProductsRequested(ProductsRequested event, Emitter<ProductState> emit) async {
    emit(state.copyWith(status: AppStatus.loading));
    try {
      final products = await repository.getProducts();
      emit(state.copyWith(status: AppStatus.success, products: products));
    } catch (error) {
      emit(state.copyWith(status: AppStatus.failure, errorCode: ErrorUtil.codeOf(error)));
    }
  }

  void _onSearchChanged(ProductSearchChanged event, Emitter<ProductState> emit) {
    emit(state.copyWith(query: event.query));
  }

  void _onCategoryChanged(ProductCategoryChanged event, Emitter<ProductState> emit) {
    emit(state.copyWith(category: event.category));
  }

  Future<void> _onProductSaved(ProductSaved event, Emitter<ProductState> emit) async {
    emit(state.copyWith(saveStatus: AppStatus.loading));
    try {
      await repository.saveProduct(event.product);
      final products = await repository.getProducts();
      emit(state.copyWith(saveStatus: AppStatus.success, products: products));
    } catch (error) {
      emit(state.copyWith(saveStatus: AppStatus.failure, saveErrorCode: ErrorUtil.codeOf(error)));
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
    }
  }
}
