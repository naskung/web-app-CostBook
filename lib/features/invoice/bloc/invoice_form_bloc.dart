import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:costbook/core/constants/app_status.dart';
import 'package:costbook/core/utils/error_util.dart';
import 'package:costbook/features/invoice/models/invoice_draft_model.dart';
import 'package:costbook/features/invoice/models/invoice_model.dart';
import 'package:costbook/features/invoice/repository/invoice_repository.dart';
import 'package:costbook/features/product/models/product_model.dart';
import 'package:costbook/features/product/repository/product_repository.dart';
import 'package:costbook/features/settings/models/company_model.dart';
import 'package:costbook/features/settings/repository/settings_repository.dart';

part 'invoice_form_event.dart';
part 'invoice_form_state.dart';

class InvoiceFormBloc extends Bloc<InvoiceFormEvent, InvoiceFormState> {
  InvoiceFormBloc(this.repository, this.productRepository, this.settingsRepository) : super(const InvoiceFormState()) {
    on<InvoiceFormOpened>(_onOpened);
    on<InvoiceItemAdded>(_onItemAdded);
    on<InvoiceItemChanged>(_onItemChanged);
    on<InvoiceItemRemoved>(_onItemRemoved);
    on<InvoiceFormSubmitted>(_onSubmitted);
  }

  final InvoiceRepository repository;
  final ProductRepository productRepository;
  final SettingsRepository settingsRepository;

  Future<void> _onOpened(InvoiceFormOpened event, Emitter<InvoiceFormState> emit) async {
    emit(state.copyWith(status: AppStatus.loading));
    try {
      final products = await productRepository.getProducts();
      final company = await settingsRepository.getCompany();
      emit(state.copyWith(status: AppStatus.success, products: products, company: company));
    } catch (error) {
      emit(state.copyWith(status: AppStatus.failure, errorCode: ErrorUtil.codeOf(error)));
    }
  }

  void _onItemAdded(InvoiceItemAdded event, Emitter<InvoiceFormState> emit) {
    final existing = state.items.where((item) => item.productId == event.productId).toList();
    if (existing.isNotEmpty) {
      final item = existing.first;
      _replaceItem(emit, item.copyWith(quantity: item.quantity + 1));
      return;
    }
    final products = state.products.where((product) => product.id == event.productId).toList();
    if (products.isEmpty) return;
    final product = products.first;
    final item = InvoiceDraftItemModel(
      productId: product.id,
      name: product.name,
      unit: product.unit,
      stock: product.stock,
      quantity: 1,
      unitPrice: product.sellPrice,
    );
    emit(state.copyWith(items: [...state.items, item], submitStatus: AppStatus.initial));
  }

  void _onItemChanged(InvoiceItemChanged event, Emitter<InvoiceFormState> emit) {
    final existing = state.items.where((item) => item.productId == event.productId).toList();
    if (existing.isEmpty) return;
    _replaceItem(emit, existing.first.copyWith(quantity: event.quantity, unitPrice: event.unitPrice));
  }

  void _replaceItem(Emitter<InvoiceFormState> emit, InvoiceDraftItemModel changed) {
    final items = [
      for (final item in state.items)
        if (item.productId == changed.productId) changed else item,
    ];
    emit(state.copyWith(items: items, submitStatus: AppStatus.initial));
  }

  void _onItemRemoved(InvoiceItemRemoved event, Emitter<InvoiceFormState> emit) {
    final items = state.items.where((item) => item.productId != event.productId).toList();
    emit(state.copyWith(items: items, submitStatus: AppStatus.initial));
  }

  Future<void> _onSubmitted(InvoiceFormSubmitted event, Emitter<InvoiceFormState> emit) async {
    emit(state.copyWith(submitStatus: AppStatus.loading));
    try {
      final invoice = await repository.createInvoice(event.draft.copyWith(items: state.items));
      emit(state.copyWith(submitStatus: AppStatus.success, createdInvoice: invoice));
    } catch (error) {
      emit(state.copyWith(submitStatus: AppStatus.failure, submitErrorCode: ErrorUtil.codeOf(error)));
    }
  }
}
