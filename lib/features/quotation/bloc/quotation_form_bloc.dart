import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:costbook/core/constants/app_status.dart';
import 'package:costbook/core/utils/error_util.dart';
import 'package:costbook/core/utils/tax_util.dart';
import 'package:costbook/features/invoice/models/invoice_draft_model.dart';
import 'package:costbook/features/product/models/product_model.dart';
import 'package:costbook/features/product/repository/product_repository.dart';
import 'package:costbook/features/quotation/models/quotation_draft_model.dart';
import 'package:costbook/features/quotation/models/quotation_model.dart';
import 'package:costbook/features/quotation/repository/quotation_repository.dart';
import 'package:costbook/features/settings/models/company_model.dart';
import 'package:costbook/features/settings/repository/settings_repository.dart';

part 'quotation_form_event.dart';
part 'quotation_form_state.dart';

class QuotationFormBloc extends Bloc<QuotationFormEvent, QuotationFormState> {
  QuotationFormBloc(this.repository, this.productRepository, this.settingsRepository)
    : super(const QuotationFormState()) {
    on<QuotationFormOpened>(_onOpened);
    on<QuotationItemAdded>(_onItemAdded);
    on<QuotationItemChanged>(_onItemChanged);
    on<QuotationItemRemoved>(_onItemRemoved);
    on<QuotationDiscountChanged>(_onDiscountChanged);
    on<QuotationFormSubmitted>(_onSubmitted);
  }

  final QuotationRepository repository;
  final ProductRepository productRepository;
  final SettingsRepository settingsRepository;

  // เคยโหลดแล้ว → โชว์สินค้าเดิมทันที แล้วค่อยโหลดใหม่เงียบ ๆ / ยังไม่เคย → หน้าโหลด
  Future<void> _onOpened(QuotationFormOpened event, Emitter<QuotationFormState> emit) async {
    final products = productRepository.cachedProducts();
    final company = settingsRepository.cachedCompany();
    if (products == null || company == null) {
      emit(state.copyWith(status: AppStatus.loading));
    } else {
      emit(state.copyWith(status: AppStatus.success, products: _forSale(products), company: company));
    }
    try {
      final freshProducts = _forSale(await productRepository.getProducts());
      final freshCompany = await settingsRepository.getCompany();
      emit(state.copyWith(status: AppStatus.success, products: freshProducts, company: freshCompany));
    } catch (error) {
      if (state.status == AppStatus.success) return;
      emit(state.copyWith(status: AppStatus.failure, errorCode: ErrorUtil.codeOf(error)));
    }
  }

  List<ProductModel> _forSale(List<ProductModel> products) {
    return products.where((product) => product.forSale).toList();
  }

  // ใบเสนอราคาไม่ตัดสต็อก → สินค้าหมดก็ใส่ได้
  void _onItemAdded(QuotationItemAdded event, Emitter<QuotationFormState> emit) {
    final products = state.products.where((product) => product.id == event.productId).toList();
    if (products.isEmpty) return;
    final items = InvoiceDraftItemModel.addTo(state.items, products.first);
    emit(state.copyWith(items: items, submitStatus: AppStatus.initial));
  }

  void _onItemChanged(QuotationItemChanged event, Emitter<QuotationFormState> emit) {
    final items = InvoiceDraftItemModel.updateIn(
      state.items,
      event.productId,
      quantity: event.quantity,
      unitPrice: event.unitPrice,
    );
    emit(state.copyWith(items: items, submitStatus: AppStatus.initial));
  }

  void _onItemRemoved(QuotationItemRemoved event, Emitter<QuotationFormState> emit) {
    final items = InvoiceDraftItemModel.removeFrom(state.items, event.productId);
    emit(state.copyWith(items: items, submitStatus: AppStatus.initial));
  }

  void _onDiscountChanged(QuotationDiscountChanged event, Emitter<QuotationFormState> emit) {
    emit(state.copyWith(discount: event.discount, submitStatus: AppStatus.initial));
  }

  Future<void> _onSubmitted(QuotationFormSubmitted event, Emitter<QuotationFormState> emit) async {
    emit(state.copyWith(submitStatus: AppStatus.loading));
    try {
      final draft = event.draft.copyWith(items: state.items, discount: state.discount);
      final quotation = await repository.createQuotation(draft);
      emit(state.copyWith(submitStatus: AppStatus.success, createdQuotation: quotation));
    } catch (error) {
      emit(state.copyWith(submitStatus: AppStatus.failure, submitErrorCode: ErrorUtil.codeOf(error)));
    }
  }
}
