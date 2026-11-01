part of 'product_bloc.dart';

class ProductState extends Equatable {
  const ProductState({
    this.status = AppStatus.initial,
    this.products = const [],
    this.categories = const [],
    this.query = '',
    this.category = '',
    this.onlyLow = false,
    this.kind = '',
    this.errorCode = '',
    this.saveStatus = AppStatus.initial,
    this.saveErrorCode = '',
    this.deleteStatus = AppStatus.initial,
    this.deleteErrorCode = '',
    this.imageErrorCode = '',
  });

  final AppStatus status;
  final List<ProductModel> products;
  final List<ProductCategoryModel> categories;
  final String query;
  // category = id ของหมวดที่กรอง ('' = ทุกหมวด)
  final String category;
  final bool onlyLow;
  // '' = ทั้งหมด / kindForSale / kindMaterial
  final String kind;

  static const String kindForSale = 'sale';
  static const String kindMaterial = 'material';
  final String errorCode;
  final AppStatus saveStatus;
  final String saveErrorCode;
  final AppStatus deleteStatus;
  final String deleteErrorCode;

  // บันทึกสินค้าแล้ว แต่อัปโหลด / ลบรูปไม่สำเร็จ ('' = ไม่มีปัญหา)
  final String imageErrorCode;

  List<ProductModel> get visibleProducts {
    return products.where((product) {
      final isInCategory = category.isEmpty || product.categoryId == category;
      final isShown = !onlyLow || product.isLowStock;
      return isInCategory && isShown && _isKind(product, kind) && product.matches(query);
    }).toList();
  }

  // จำนวนสินค้าของแต่ละแท็บ (ทั้งหมด / สินค้าขาย / วัสดุ) นับจากสินค้าทั้งหมด
  int kindCount(String kind) => products.where((product) => _isKind(product, kind)).length;

  static bool _isKind(ProductModel product, String kind) {
    if (kind.isEmpty) return true;
    return (kind == kindMaterial) == !product.forSale;
  }

  int get lowStockCount => products.where((product) => product.isLowStock).length;

  ProductState copyWith({
    AppStatus? status,
    List<ProductModel>? products,
    List<ProductCategoryModel>? categories,
    String? query,
    String? category,
    bool? onlyLow,
    String? kind,
    String? errorCode,
    AppStatus? saveStatus,
    String? saveErrorCode,
    AppStatus? deleteStatus,
    String? deleteErrorCode,
    String? imageErrorCode,
  }) {
    return ProductState(
      status: status ?? this.status,
      products: products ?? this.products,
      categories: categories ?? this.categories,
      query: query ?? this.query,
      category: category ?? this.category,
      onlyLow: onlyLow ?? this.onlyLow,
      kind: kind ?? this.kind,
      errorCode: errorCode ?? this.errorCode,
      saveStatus: saveStatus ?? this.saveStatus,
      saveErrorCode: saveErrorCode ?? this.saveErrorCode,
      deleteStatus: deleteStatus ?? this.deleteStatus,
      deleteErrorCode: deleteErrorCode ?? this.deleteErrorCode,
      imageErrorCode: imageErrorCode ?? this.imageErrorCode,
    );
  }

  @override
  List<Object?> get props => [
    status,
    products,
    categories,
    query,
    category,
    onlyLow,
    kind,
    errorCode,
    saveStatus,
    saveErrorCode,
    deleteStatus,
    deleteErrorCode,
    imageErrorCode,
  ];
}
