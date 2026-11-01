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
    this.counts = const ProductCountsModel(),
    this.hasMore = false,
    this.moreStatus = AppStatus.initial,
    this.isFiltering = false,
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

  // products = สินค้าที่โหลดมาแล้วของตัวกรองตอนนี้ (API ค้น / กรองให้ โหลดทีละหน้า)
  // counts = จำนวนสินค้าทั้งร้าน / hasMore = ยังมีหน้าต่อไป / isFiltering = กำลังโหลดใหม่ตามตัวกรองที่เพิ่งเปลี่ยน
  final ProductCountsModel counts;
  final bool hasMore;
  final AppStatus moreStatus;
  final bool isFiltering;

  // จำนวนสินค้าของแต่ละแท็บ (ทั้งหมด / สินค้าขาย / วัสดุ) นับจากสินค้าทั้งร้าน
  int kindCount(String kind) {
    if (kind == kindForSale) return counts.forSale;
    if (kind == kindMaterial) return counts.material;
    return counts.all;
  }

  int get lowStockCount => counts.low;

  // ตัวกรองตอนนี้ เทียบกับตอนเริ่มโหลด → เปลี่ยนไปแล้ว = ผลที่ได้มาเป็นของตัวกรองเก่า ทิ้งได้
  String get filterKey => '${query.trim()}|$category|$kind|$onlyLow';

  // เลื่อนลงแล้วโหลดหน้าต่อไปเองได้ไหม (โหลดเพิ่มพัง → รอผู้ใช้กดลองใหม่ ไม่ยิงซ้ำเอง)
  bool get canLoadMore =>
      status == AppStatus.success &&
      hasMore &&
      !isFiltering &&
      moreStatus != AppStatus.loading &&
      moreStatus != AppStatus.failure;

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
    ProductCountsModel? counts,
    bool? hasMore,
    AppStatus? moreStatus,
    bool? isFiltering,
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
      counts: counts ?? this.counts,
      hasMore: hasMore ?? this.hasMore,
      moreStatus: moreStatus ?? this.moreStatus,
      isFiltering: isFiltering ?? this.isFiltering,
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
    counts,
    hasMore,
    moreStatus,
    isFiltering,
  ];
}
