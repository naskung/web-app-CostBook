part of 'invoice_form_bloc.dart';

class InvoiceFormState extends Equatable {
  const InvoiceFormState({
    this.status = AppStatus.initial,
    this.products = const [],
    this.company = const CompanyModel(),
    this.items = const [],
    this.errorCode = '',
    this.submitStatus = AppStatus.initial,
    this.submitErrorCode = '',
    this.createdInvoice,
  });

  final AppStatus status;
  final List<ProductModel> products;
  final CompanyModel company;
  final List<InvoiceDraftItemModel> items;
  final String errorCode;
  final AppStatus submitStatus;
  final String submitErrorCode;
  final InvoiceModel? createdInvoice;

  InvoiceDraftModel get totals => InvoiceDraftModel(issueDate: '', customerName: '', items: items);

  InvoiceFormState copyWith({
    AppStatus? status,
    List<ProductModel>? products,
    CompanyModel? company,
    List<InvoiceDraftItemModel>? items,
    String? errorCode,
    AppStatus? submitStatus,
    String? submitErrorCode,
    InvoiceModel? createdInvoice,
  }) {
    return InvoiceFormState(
      status: status ?? this.status,
      products: products ?? this.products,
      company: company ?? this.company,
      items: items ?? this.items,
      errorCode: errorCode ?? this.errorCode,
      submitStatus: submitStatus ?? this.submitStatus,
      submitErrorCode: submitErrorCode ?? this.submitErrorCode,
      createdInvoice: createdInvoice ?? this.createdInvoice,
    );
  }

  @override
  List<Object?> get props =>
      [status, products, company, items, errorCode, submitStatus, submitErrorCode, createdInvoice];
}
