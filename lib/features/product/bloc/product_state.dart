part of 'product_bloc.dart';

class ProductState extends Equatable {
  const ProductState({
    this.status = AppStatus.initial,
    this.products = const [],
    this.query = '',
    this.category = '',
    this.errorCode = '',
    this.saveStatus = AppStatus.initial,
    this.saveErrorCode = '',
    this.deleteStatus = AppStatus.initial,
    this.deleteErrorCode = '',
  });

  final AppStatus status;
  final List<ProductModel> products;
  final String query;
  final String category;
  final String errorCode;
  final AppStatus saveStatus;
  final String saveErrorCode;
  final AppStatus deleteStatus;
  final String deleteErrorCode;

  List<ProductModel> get visibleProducts {
    return products.where((product) {
      final isInCategory = category.isEmpty || product.category == category;
      return isInCategory && product.matches(query);
    }).toList();
  }

  List<String> get categories {
    final names = products.map((product) => product.category).where((name) => name.isNotEmpty).toSet().toList();
    names.sort();
    return names;
  }

  ProductState copyWith({
    AppStatus? status,
    List<ProductModel>? products,
    String? query,
    String? category,
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
      category: category ?? this.category,
      errorCode: errorCode ?? this.errorCode,
      saveStatus: saveStatus ?? this.saveStatus,
      saveErrorCode: saveErrorCode ?? this.saveErrorCode,
      deleteStatus: deleteStatus ?? this.deleteStatus,
      deleteErrorCode: deleteErrorCode ?? this.deleteErrorCode,
    );
  }

  @override
  List<Object?> get props => [
    status,
    products,
    query,
    category,
    errorCode,
    saveStatus,
    saveErrorCode,
    deleteStatus,
    deleteErrorCode,
  ];
}
