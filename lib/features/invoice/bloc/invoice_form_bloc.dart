import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:costbook/core/constants/app_status.dart';
import 'package:costbook/core/utils/error_util.dart';
import 'package:costbook/core/utils/tax_util.dart';
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
    on<InvoiceCodeScanned>(_onCodeScanned);
    on<InvoiceItemChanged>(_onItemChanged);
    on<InvoiceItemRemoved>(_onItemRemoved);
    on<InvoiceDiscountChanged>(_onDiscountChanged);
    on<InvoiceFormSubmitted>(_onSubmitted);
    on<InvoiceFormReset>(_onReset);
  }

  final InvoiceRepository repository;
  final ProductRepository productRepository;
  final SettingsRepository settingsRepository;

  // เคยโหลดแล้ว → โชว์สินค้าเดิมทันที (เริ่มขายได้เลย) แล้วค่อยโหลดใหม่เงียบ ๆ / ยังไม่เคย → หน้าโหลด
  Future<void> _onOpened(InvoiceFormOpened event, Emitter<InvoiceFormState> emit) async {
    final products = productRepository.cachedProducts();
    final company = settingsRepository.cachedCompany();
    if (products == null || company == null) {
      emit(state.copyWith(status: AppStatus.loading));
    } else {
      emit(state.copyWith(status: AppStatus.success, products: _forSale(products), company: company));
    }
    await _loadProducts(emit);
  }

  Future<void> _loadProducts(Emitter<InvoiceFormState> emit) async {
    try {
      final products = _forSale(await productRepository.getProducts());
      final company = await settingsRepository.getCompany();
      emit(state.copyWith(status: AppStatus.success, products: products, company: company));
    } catch (error) {
      // มีของเดิมโชว์อยู่ (จาก cache) แล้วโหลดใหม่ไม่ได้ → โชว์ของเดิมต่อ ไม่ขึ้นหน้า error
      if (state.status == AppStatus.success) return;
      emit(state.copyWith(status: AppStatus.failure, errorCode: ErrorUtil.codeOf(error)));
    }
  }

  // วัสดุ (ไม่ขาย) ไม่ขึ้นให้เลือกขาย
  List<ProductModel> _forSale(List<ProductModel> products) {
    return products.where((product) => product.forSale).toList();
  }

  void _onItemAdded(InvoiceItemAdded event, Emitter<InvoiceFormState> emit) {
    final products = state.products.where((product) => product.id == event.productId).toList();
    if (products.isEmpty) return;
    _addProduct(emit, products.first);
  }

  void _onCodeScanned(InvoiceCodeScanned event, Emitter<InvoiceFormState> emit) {
    final code = event.code.trim().toLowerCase();
    final products = state.products.where((product) => product.code.toLowerCase() == code && code.isNotEmpty).toList();
    if (products.isEmpty) {
      emit(state.copyWith(scanMissCount: state.scanMissCount + 1));
      return;
    }
    _addProduct(emit, products.first);
  }

  // นับสต็อกแล้วเหลือ 0 → ไม่ลงบิล นับ outOfStockCount เพิ่ม (หน้าจอขึ้นแจ้งเตือน)
  void _addProduct(Emitter<InvoiceFormState> emit, ProductModel product) {
    if (product.isOutOfStock) {
      emit(state.copyWith(outOfStockCount: state.outOfStockCount + 1));
      return;
    }
    final existing = state.items.where((item) => item.productId == product.id).toList();
    if (existing.isNotEmpty) {
      final item = existing.first;
      _replaceItem(emit, item.copyWith(quantity: item.quantity + 1));
      return;
    }
    final items = [...state.items, InvoiceDraftItemModel.fromProduct(product)];
    emit(state.copyWith(items: items, submitStatus: AppStatus.initial));
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

  void _onDiscountChanged(InvoiceDiscountChanged event, Emitter<InvoiceFormState> emit) {
    emit(state.copyWith(discount: event.discount, submitStatus: AppStatus.initial));
  }

  Future<void> _onSubmitted(InvoiceFormSubmitted event, Emitter<InvoiceFormState> emit) async {
    emit(state.copyWith(submitStatus: AppStatus.loading));
    try {
      final draft = event.draft.copyWith(items: state.items, discount: state.discount);
      final invoice = await repository.createInvoice(draft);
      emit(state.copyWith(submitStatus: AppStatus.success, createdInvoice: invoice));
    } catch (error) {
      emit(
        state.copyWith(
          submitStatus: AppStatus.failure,
          submitErrorCode: ErrorUtil.codeOf(error),
          submitErrorParams: ErrorUtil.paramsOf(error),
        ),
      );
    }
  }

  Future<void> _onReset(InvoiceFormReset event, Emitter<InvoiceFormState> emit) async {
    emit(InvoiceFormState(status: AppStatus.loading, products: state.products, company: state.company));
    await _loadProducts(emit);
  }
}
