import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:costbook/core/constants/app_status.dart';
import 'package:costbook/core/utils/error_util.dart';
import 'package:costbook/features/stock/models/movement_model.dart';
import 'package:costbook/features/stock/models/stock_item_model.dart';
import 'package:costbook/features/stock/repository/stock_repository.dart';

part 'stock_event.dart';
part 'stock_state.dart';

class StockBloc extends Bloc<StockEvent, StockState> {
  StockBloc(this.repository) : super(const StockState()) {
    on<StockRequested>(_onStockRequested);
    on<StockFilterChanged>(_onFilterChanged);
    on<StockViewChanged>(_onViewChanged);
    on<StockMovementSaved>(_onMovementSaved);
  }

  final StockRepository repository;

  Future<void> _onStockRequested(StockRequested event, Emitter<StockState> emit) async {
    emit(state.copyWith(status: AppStatus.loading));
    await _load(emit);
  }

  void _onFilterChanged(StockFilterChanged event, Emitter<StockState> emit) {
    emit(state.copyWith(onlyLow: event.onlyLow));
  }

  Future<void> _onViewChanged(StockViewChanged event, Emitter<StockState> emit) async {
    emit(state.copyWith(status: AppStatus.loading, showHistory: event.showHistory));
    await _load(emit);
  }

  Future<void> _load(Emitter<StockState> emit) async {
    try {
      final items = await repository.getStock();
      var movements = state.movements;
      if (state.showHistory) movements = await repository.getMovements();
      emit(state.copyWith(status: AppStatus.success, items: items, movements: movements));
    } catch (error) {
      emit(state.copyWith(status: AppStatus.failure, errorCode: ErrorUtil.codeOf(error)));
    }
  }

  Future<void> _onMovementSaved(StockMovementSaved event, Emitter<StockState> emit) async {
    emit(state.copyWith(saveStatus: AppStatus.loading, savedType: event.type));
    try {
      await repository.addMovement(
        type: event.type,
        productId: event.productId,
        quantity: event.quantity,
        note: event.note,
        unitCost: event.unitCost,
        supplier: event.supplier,
      );
      emit(state.copyWith(saveStatus: AppStatus.success));
      await _load(emit);
    } catch (error) {
      emit(state.copyWith(saveStatus: AppStatus.failure, saveErrorCode: ErrorUtil.codeOf(error)));
    }
  }
}
