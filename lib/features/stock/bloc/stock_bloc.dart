import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:costbook/core/constants/api_constants.dart';
import 'package:costbook/core/constants/app_status.dart';
import 'package:costbook/core/utils/error_util.dart';
import 'package:costbook/core/utils/page_util.dart';
import 'package:costbook/features/stock/models/movement_model.dart';
import 'package:costbook/features/stock/models/stock_item_model.dart';
import 'package:costbook/features/stock/repository/stock_repository.dart';

part 'stock_event.dart';
part 'stock_state.dart';

class StockBloc extends Bloc<StockEvent, StockState> {
  // withHistory = false → โหลดแค่สินค้า (หน้ารายการสินค้าใช้กล่องรับเข้า / เบิกออก ไม่ต้องโหลดประวัติ)
  StockBloc(this.repository, {this.withHistory = true}) : super(const StockState()) {
    on<StockRequested>(_onStockRequested);
    on<StockMovementSaved>(_onMovementSaved);
    on<StockMovementsMoreRequested>(_onMoreRequested);
  }

  final StockRepository repository;
  final bool withHistory;

  Future<void> _onStockRequested(StockRequested event, Emitter<StockState> emit) async {
    _showCachedFirst(emit);
    await _load(emit);
  }

  // เคยโหลดแล้ว → โชว์ของเดิมทันที (ไม่ขึ้นหน้าโหลด) แล้วค่อยโหลดใหม่เงียบ ๆ / ยังไม่เคย → หน้าโหลด
  void _showCachedFirst(Emitter<StockState> emit) {
    final items = repository.cachedStock();
    final movements = withHistory ? repository.cachedMovements() : state.movements;
    if (items == null || movements == null) {
      emit(state.copyWith(status: AppStatus.loading));
      return;
    }
    emit(
      state.copyWith(
        status: AppStatus.success,
        items: items,
        movements: movements,
        hasMore: PageUtil.hasMore(movements.length, ApiConstants.pageSize),
      ),
    );
  }

  // คงเหลือ (ทุกสินค้า ไว้ให้กล่องรับเข้า / เบิกออกเลือก) + ประวัติ (limit = หน้าแรก หรือเท่าที่เลื่อนไว้แล้ว ตอนโหลดใหม่หลังบันทึก)
  Future<void> _load(Emitter<StockState> emit, {int limit = ApiConstants.pageSize}) async {
    try {
      final items = await repository.getStock();
      final movements = withHistory ? await repository.getMovements(limit: limit) : state.movements;
      emit(
        state.copyWith(
          status: AppStatus.success,
          items: items,
          movements: movements,
          hasMore: withHistory && PageUtil.hasMore(movements.length, limit),
        ),
      );
    } catch (error) {
      // มีของเดิมโชว์อยู่ (จาก cache) แล้วโหลดใหม่ไม่ได้ → โชว์ของเดิมต่อ ไม่ขึ้นหน้า error
      if (state.status == AppStatus.success) return;
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
        skipMaterials: event.skipMaterials,
      );
      emit(state.copyWith(saveStatus: AppStatus.success));
      await _load(emit, limit: PageUtil.reloadLimit(state.movements.length));
    } catch (error) {
      emit(
        state.copyWith(
          saveStatus: AppStatus.failure,
          saveErrorCode: ErrorUtil.codeOf(error),
          saveErrorParams: ErrorUtil.paramsOf(error),
        ),
      );
    }
  }

  // ประวัติหน้าต่อไป: ต่อท้ายรายการเดิม / กำลังโหลดอยู่ หรือหมดแล้ว → ไม่โหลดซ้ำ
  Future<void> _onMoreRequested(StockMovementsMoreRequested event, Emitter<StockState> emit) async {
    if (state.status != AppStatus.success || !state.hasMore || state.moreStatus == AppStatus.loading) return;
    emit(state.copyWith(moreStatus: AppStatus.loading));
    try {
      final next = await repository.getMovements(offset: state.movements.length);
      emit(
        state.copyWith(
          moreStatus: AppStatus.success,
          movements: PageUtil.append(state.movements, next, (movement) => movement.id),
          hasMore: PageUtil.hasMore(next.length, ApiConstants.pageSize),
        ),
      );
    } catch (_) {
      emit(state.copyWith(moreStatus: AppStatus.failure));
    }
  }
}
