part of 'invoice_form_bloc.dart';

class InvoiceFormState extends Equatable {
  const InvoiceFormState({
    this.status = AppStatus.initial,
    this.products = const [],
    this.company = const CompanyModel(),
    this.items = const [],
    this.discount = 0,
    this.scanMissCount = 0,
    this.outOfStockCount = 0,
    this.errorCode = '',
    this.submitStatus = AppStatus.initial,
    this.submitErrorCode = '',
    this.submitErrorParams = const {},
    this.createdInvoice,
  });

  final AppStatus status;
  final List<ProductModel> products;
  final CompanyModel company;
  final List<InvoiceDraftItemModel> items;
  final double discount;
  final int scanMissCount;
  final int outOfStockCount;
  final String errorCode;
  final AppStatus submitStatus;
  final String submitErrorCode;
  // ค่าที่มากับ error เช่น วัสดุไม่พอ: ชื่อวัสดุ / ต้องใช้ / มีอยู่
  final Map<String, String> submitErrorParams;
  final InvoiceModel? createdInvoice;

  DocumentAmounts get amounts {
    final draft = InvoiceDraftModel(issueDate: '', items: items, discount: discount);
    return draft.amounts(vatRegistered: company.vatRegistered, pricesIncludeVat: company.pricesIncludeVat);
  }

  bool get needsCustomerName => company.vatRegistered;

  int get itemCount => items.fold(0, (count, item) => count + item.quantity);

  // category = ชื่อหมวด ('' = ทุกหมวด)
  List<ProductModel> productsMatching(String query, {String category = ''}) {
    return products
        .where((product) => product.matches(query) && (category.isEmpty || product.category == category))
        .toList();
  }

  // หมวดของสินค้าที่มี (ไม่ซ้ำ เรียงตามชื่อ) ไว้ทำปุ่มกรองในหน้าขาย
  List<String> get productCategories {
    final names =
        {
          for (final product in products)
            if (product.category.isNotEmpty) product.category,
        }.toList();
    names.sort();
    return names;
  }

  // สินค้านี้อยู่ในบิลกี่ชิ้น (ไม่อยู่ = 0)
  int quantityOf(String productId) {
    for (final item in items) {
      if (item.productId == productId) return item.quantity;
    }
    return 0;
  }

  InvoiceFormState copyWith({
    AppStatus? status,
    List<ProductModel>? products,
    CompanyModel? company,
    List<InvoiceDraftItemModel>? items,
    double? discount,
    int? scanMissCount,
    int? outOfStockCount,
    String? errorCode,
    AppStatus? submitStatus,
    String? submitErrorCode,
    Map<String, String>? submitErrorParams,
    InvoiceModel? createdInvoice,
  }) {
    return InvoiceFormState(
      status: status ?? this.status,
      products: products ?? this.products,
      company: company ?? this.company,
      items: items ?? this.items,
      discount: discount ?? this.discount,
      scanMissCount: scanMissCount ?? this.scanMissCount,
      outOfStockCount: outOfStockCount ?? this.outOfStockCount,
      errorCode: errorCode ?? this.errorCode,
      submitStatus: submitStatus ?? this.submitStatus,
      submitErrorCode: submitErrorCode ?? this.submitErrorCode,
      submitErrorParams: submitErrorParams ?? this.submitErrorParams,
      createdInvoice: createdInvoice ?? this.createdInvoice,
    );
  }

  @override
  List<Object?> get props => [
    status,
    products,
    company,
    items,
    discount,
    scanMissCount,
    outOfStockCount,
    errorCode,
    submitStatus,
    submitErrorCode,
    submitErrorParams,
    createdInvoice,
  ];
}
