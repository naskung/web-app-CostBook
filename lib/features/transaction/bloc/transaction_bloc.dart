import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart' show DateTimeRange;
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:costbook/core/constants/api_constants.dart';
import 'package:costbook/core/constants/app_status.dart';
import 'package:costbook/core/utils/error_util.dart';
import 'package:costbook/core/utils/page_util.dart';
import 'package:costbook/features/transaction/models/transaction_model.dart';
import 'package:costbook/features/transaction/models/transaction_summary_model.dart';
import 'package:costbook/features/transaction/repository/transaction_repository.dart';

part 'transaction_event.dart';
part 'transaction_state.dart';

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  TransactionBloc(this.repository, {required DateTimeRange range}) : super(TransactionState(range: range)) {
    on<TransactionsRequested>(_onRequested);
    on<TransactionRangeChanged>(_onRangeChanged);
    on<TransactionSaved>(_onSaved);
    on<TransactionDeleted>(_onDeleted);
    on<TransactionsMoreRequested>(_onMoreRequested);
  }

  final TransactionRepository repository;

  Future<void> _onRequested(TransactionsRequested event, Emitter<TransactionState> emit) async {
    _showCachedFirst(emit, state.range);
    await _load(emit);
  }

  Future<void> _onRangeChanged(TransactionRangeChanged event, Emitter<TransactionState> emit) async {
    _showCachedFirst(emit, event.range);
    await _load(emit);
  }

  // เคยโหลดช่วงนี้แล้ว → โชว์ของเดิมทันที (ไม่ขึ้นหน้าโหลด) แล้วค่อยโหลดใหม่เงียบ ๆ / ยังไม่เคย → หน้าโหลด
  void _showCachedFirst(Emitter<TransactionState> emit, DateTimeRange range) {
    final transactions = repository.cachedTransactions(range);
    final summary = repository.cachedSummary(range);
    if (transactions == null || summary == null) {
      emit(state.copyWith(status: AppStatus.loading, range: range, moreStatus: AppStatus.initial));
      return;
    }
    emit(
      state.copyWith(
        status: AppStatus.success,
        range: range,
        transactions: transactions,
        summary: summary,
        hasMore: PageUtil.hasMore(transactions.length, ApiConstants.pageSize),
        moreStatus: AppStatus.initial,
      ),
    );
  }

  // โหลดรายการ (limit = หน้าแรก หรือเท่าที่เลื่อนไว้แล้วตอนโหลดใหม่หลังบันทึก / ลบ) + สรุปของช่วงวันที่
  // ระหว่างรอผู้ใช้เปลี่ยนช่วงวันที่แล้ว → ทิ้งผลของช่วงเก่า
  Future<void> _load(Emitter<TransactionState> emit, {int limit = ApiConstants.pageSize}) async {
    final range = state.range;
    try {
      final transactions = await repository.getTransactions(range, limit: limit);
      final summary = await repository.getSummary(range);
      if (state.range != range) return;
      emit(
        state.copyWith(
          status: AppStatus.success,
          transactions: transactions,
          summary: summary,
          hasMore: PageUtil.hasMore(transactions.length, limit),
        ),
      );
    } catch (error) {
      // มีของเดิมโชว์อยู่ (จาก cache) แล้วโหลดใหม่ไม่ได้ → โชว์ของเดิมต่อ ไม่ขึ้นหน้า error
      if (state.status == AppStatus.success) return;
      emit(state.copyWith(status: AppStatus.failure, errorCode: ErrorUtil.codeOf(error)));
    }
  }

  Future<void> _onSaved(TransactionSaved event, Emitter<TransactionState> emit) async {
    emit(state.copyWith(saveStatus: AppStatus.loading));
    try {
      await repository.saveTransaction(event.transaction);
      emit(state.copyWith(saveStatus: AppStatus.success));
      await _load(emit, limit: PageUtil.reloadLimit(state.transactions.length));
    } catch (error) {
      emit(state.copyWith(saveStatus: AppStatus.failure, saveErrorCode: ErrorUtil.codeOf(error)));
    }
  }

  Future<void> _onDeleted(TransactionDeleted event, Emitter<TransactionState> emit) async {
    emit(state.copyWith(deleteStatus: AppStatus.loading));
    try {
      await repository.deleteTransaction(event.id);
      emit(state.copyWith(deleteStatus: AppStatus.success));
      await _load(emit, limit: PageUtil.reloadLimit(state.transactions.length));
    } catch (error) {
      emit(state.copyWith(deleteStatus: AppStatus.failure, deleteErrorCode: ErrorUtil.codeOf(error)));
    }
  }

  // หน้าต่อไป: ต่อท้ายรายการเดิม / กำลังโหลดอยู่ หรือหมดแล้ว → ไม่โหลดซ้ำ / ระหว่างรอเปลี่ยนช่วงวันที่ → ทิ้งผล
  Future<void> _onMoreRequested(TransactionsMoreRequested event, Emitter<TransactionState> emit) async {
    if (state.status != AppStatus.success || !state.hasMore || state.moreStatus == AppStatus.loading) return;
    final range = state.range;
    emit(state.copyWith(moreStatus: AppStatus.loading));
    try {
      final next = await repository.getTransactions(range, offset: state.transactions.length);
      if (state.range != range) return;
      emit(
        state.copyWith(
          moreStatus: AppStatus.success,
          transactions: PageUtil.append(state.transactions, next, (transaction) => transaction.id),
          hasMore: PageUtil.hasMore(next.length, ApiConstants.pageSize),
        ),
      );
    } catch (_) {
      if (state.range != range) return;
      emit(state.copyWith(moreStatus: AppStatus.failure));
    }
  }
}
