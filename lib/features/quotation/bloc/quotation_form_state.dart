part of 'quotation_form_bloc.dart';

class QuotationFormState extends Equatable {
  const QuotationFormState({
    this.status = AppStatus.initial,
    this.products = const [],
    this.company = const CompanyModel(),
    this.items = const [],
    this.discount = 0,
    this.errorCode = '',
    this.submitStatus = AppStatus.initial,
    this.submitErrorCode = '',
    this.createdQuotation,
  });

  final AppStatus status;
  final List<ProductModel> products;
  final CompanyModel company;
  final List<InvoiceDraftItemModel> items;
  final double discount;
  final String errorCode;
  final AppStatus submitStatus;
  final String submitErrorCode;
  final QuotationModel? createdQuotation;

  DocumentAmounts get amounts {
    final draft = QuotationDraftModel(issueDate: '', validUntil: '', items: items, discount: discount);
    return draft.amounts(vatRegistered: company.vatRegistered, pricesIncludeVat: company.pricesIncludeVat);
  }

  QuotationFormState copyWith({
    AppStatus? status,
    List<ProductModel>? products,
    CompanyModel? company,
    List<InvoiceDraftItemModel>? items,
    double? discount,
    String? errorCode,
    AppStatus? submitStatus,
    String? submitErrorCode,
    QuotationModel? createdQuotation,
  }) {
    return QuotationFormState(
      status: status ?? this.status,
      products: products ?? this.products,
      company: company ?? this.company,
      items: items ?? this.items,
      discount: discount ?? this.discount,
      errorCode: errorCode ?? this.errorCode,
      submitStatus: submitStatus ?? this.submitStatus,
      submitErrorCode: submitErrorCode ?? this.submitErrorCode,
      createdQuotation: createdQuotation ?? this.createdQuotation,
    );
  }

  @override
  List<Object?> get props => [
    status,
    products,
    company,
    items,
    discount,
    errorCode,
    submitStatus,
    submitErrorCode,
    createdQuotation,
  ];
}
