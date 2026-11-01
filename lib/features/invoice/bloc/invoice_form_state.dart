part of 'invoice_form_bloc.dart';

class InvoiceFormState extends Equatable {
  const InvoiceFormState({
    this.status = AppStatus.initial,
    this.products = const [],
    this.company = const CompanyModel(),
    this.items = const [],
    this.discount = 0,
    this.scanMissCount = 0,
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

  List<ProductModel> productsMatching(String query) {
    return products.where((product) => product.matches(query)).toList();
  }

  InvoiceFormState copyWith({
    AppStatus? status,
    List<ProductModel>? products,
    CompanyModel? company,
    List<InvoiceDraftItemModel>? items,
    double? discount,
    int? scanMissCount,
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
    errorCode,
    submitStatus,
    submitErrorCode,
    submitErrorParams,
    createdInvoice,
  ];
}
