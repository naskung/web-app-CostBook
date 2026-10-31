import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:costbook/core/constants/app_status.dart';
import 'package:costbook/core/utils/cost_util.dart';
import 'package:costbook/core/utils/tax_util.dart';
import 'package:costbook/core/utils/error_util.dart';
import 'package:costbook/features/cost/models/cost_item_model.dart';
import 'package:costbook/features/cost/models/cost_preset_model.dart';
import 'package:costbook/features/cost/models/cost_sheet_model.dart';
import 'package:costbook/features/cost/repository/cost_repository.dart';
import 'package:costbook/features/product/models/product_model.dart';
import 'package:costbook/features/product/repository/product_repository.dart';

part 'cost_event.dart';
part 'cost_state.dart';

class CostBloc extends Bloc<CostEvent, CostState> {
  CostBloc(this.repository, this.productRepository) : super(const CostState()) {
    on<CostPageOpened>(_onPageOpened);
    on<CostProductSelected>(_onProductSelected);
    on<CostItemAdded>(_onItemAdded);
    on<CostItemChanged>(_onItemChanged);
    on<CostItemRemoved>(_onItemRemoved);
    on<CostBatchQuantityChanged>(_onBatchQuantityChanged);
    on<CostSellPriceChanged>(_onSellPriceChanged);
    on<CostMarkupApplied>(_onMarkupApplied);
    on<CostSheetSaved>(_onSheetSaved);
    on<CostPresetSaved>(_onPresetSaved);
    on<CostPresetDeleted>(_onPresetDeleted);
  }

  final CostRepository repository;
  final ProductRepository productRepository;

  Future<void> _onPageOpened(CostPageOpened event, Emitter<CostState> emit) async {
    emit(state.copyWith(status: AppStatus.loading));
    try {
      final products = await productRepository.getProducts();
      final presets = await repository.getPresets();
      emit(state.copyWith(status: AppStatus.success, products: products, presets: presets));
      if (products.isNotEmpty) await _loadSheet(products.first.id, emit);
    } catch (error) {
      emit(state.copyWith(status: AppStatus.failure, errorCode: ErrorUtil.codeOf(error)));
    }
  }

  Future<void> _onProductSelected(CostProductSelected event, Emitter<CostState> emit) async {
    await _loadSheet(event.productId, emit);
  }

  Future<void> _loadSheet(String productId, Emitter<CostState> emit) async {
    emit(state.copyWith(sheetStatus: AppStatus.loading));
    try {
      final sheet = await repository.getSheet(productId);
      emit(state.copyWith(sheetStatus: AppStatus.success, sheet: sheet, isDirty: false));
    } catch (error) {
      emit(state.copyWith(sheetStatus: AppStatus.failure, errorCode: ErrorUtil.codeOf(error)));
    }
  }

  void _onItemAdded(CostItemAdded event, Emitter<CostState> emit) {
    final sheet = state.sheet;
    if (sheet == null) return;
    _emitEdited(emit, sheet.copyWith(items: [...sheet.items, event.item]));
  }

  void _onItemChanged(CostItemChanged event, Emitter<CostState> emit) {
    final sheet = state.sheet;
    if (sheet == null) return;
    final index = sheet.items.indexOf(event.oldItem);
    if (index < 0) return;
    final items = [...sheet.items]..[index] = event.newItem;
    _emitEdited(emit, sheet.copyWith(items: items));
  }

  void _onItemRemoved(CostItemRemoved event, Emitter<CostState> emit) {
    final sheet = state.sheet;
    if (sheet == null) return;
    final items = [...sheet.items]..remove(event.item);
    _emitEdited(emit, sheet.copyWith(items: items));
  }

  void _onBatchQuantityChanged(CostBatchQuantityChanged event, Emitter<CostState> emit) {
    final sheet = state.sheet;
    if (sheet == null) return;
    _emitEdited(emit, sheet.copyWith(batchQuantity: event.batchQuantity));
  }

  void _onSellPriceChanged(CostSellPriceChanged event, Emitter<CostState> emit) {
    final sheet = state.sheet;
    if (sheet == null) return;
    _emitEdited(emit, sheet.copyWith(sellPrice: event.sellPrice));
  }

  void _onMarkupApplied(CostMarkupApplied event, Emitter<CostState> emit) {
    final sheet = state.sheet;
    if (sheet == null) return;
    final price = CostUtil.sellPrice(cost: sheet.costPerUnit, markupPercent: event.markupPercent);
    final sellPrice = event.priceHasVat ? TaxUtil.totalWithVat(price) : price;
    _emitEdited(emit, sheet.copyWith(sellPrice: sellPrice));
  }

  void _emitEdited(Emitter<CostState> emit, CostSheetModel sheet) {
    emit(state.copyWith(sheet: sheet, isDirty: true, saveStatus: AppStatus.initial));
  }

  Future<void> _onSheetSaved(CostSheetSaved event, Emitter<CostState> emit) async {
    final sheet = state.sheet;
    if (sheet == null) return;
    emit(state.copyWith(saveStatus: AppStatus.loading));
    try {
      final saved = await repository.saveSheet(sheet);
      emit(state.copyWith(saveStatus: AppStatus.success, sheet: saved, isDirty: false));
    } catch (error) {
      emit(state.copyWith(saveStatus: AppStatus.failure, saveErrorCode: ErrorUtil.codeOf(error)));
    }
  }

  Future<void> _onPresetSaved(CostPresetSaved event, Emitter<CostState> emit) async {
    try {
      await repository.savePreset(event.preset);
      final presets = await repository.getPresets();
      emit(state.copyWith(presets: presets));
    } catch (error) {
      emit(state.copyWith(saveStatus: AppStatus.failure, saveErrorCode: ErrorUtil.codeOf(error)));
    }
  }

  Future<void> _onPresetDeleted(CostPresetDeleted event, Emitter<CostState> emit) async {
    try {
      await repository.deletePreset(event.id);
      emit(state.copyWith(presets: state.presets.where((preset) => preset.id != event.id).toList()));
    } catch (error) {
      emit(state.copyWith(saveStatus: AppStatus.failure, saveErrorCode: ErrorUtil.codeOf(error)));
    }
  }
}
