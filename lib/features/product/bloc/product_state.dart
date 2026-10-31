part of 'product_bloc.dart';

class ProductState extends Equatable {
  const ProductState({
    this.status = AppStatus.initial,
    this.products = const [],
    this.query = '',
    this.errorCode = '',
    this.saveStatus = AppStatus.initial,
    this.saveErrorCode = '',
    this.deleteStatus = AppStatus.initial,
    this.deleteErrorCode = '',
  });

  final AppStatus status;
  final List<ProductModel> products;
  final String query;
  final String errorCode;
  final AppStatus saveStatus;
  final String saveErrorCode;
  final AppStatus deleteStatus;
  final String deleteErrorCode;

  List<ProductModel> get visibleProducts {
    final text = query.trim().toLowerCase();
    if (text.isEmpty) return products;
    return products.where((product) => product.name.toLowerCase().contains(text)).toList();
  }

  ProductState copyWith({
    AppStatus? status,
    List<ProductModel>? products,
    String? query,
    String? errorCode,
    AppStatus? saveStatus,
    String? saveErrorCode,
    AppStatus? deleteStatus,
    String? deleteErrorCode,
  }) {
    return ProductState(
      status: status ?? this.status,
      products: products ?? this.products,
      query: query ?? this.query,
      errorCode: errorCode ?? this.errorCode,
      saveStatus: saveStatus ?? this.saveStatus,
      saveErrorCode: saveErrorCode ?? this.saveErrorCode,
      deleteStatus: deleteStatus ?? this.deleteStatus,
      deleteErrorCode: deleteErrorCode ?? this.deleteErrorCode,
    );
  }

  @override
  List<Object?> get props =>
      [status, products, query, errorCode, saveStatus, saveErrorCode, deleteStatus, deleteErrorCode];
}
