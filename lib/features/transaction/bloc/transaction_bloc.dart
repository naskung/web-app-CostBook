import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:costbook/core/constants/api_constants.dart';
import 'package:costbook/core/constants/app_status.dart';
import 'package:costbook/core/utils/date_util.dart';
import 'package:costbook/core/utils/error_util.dart';
import 'package:costbook/core/utils/page_util.dart';
import 'package:costbook/features/transaction/models/transaction_model.dart';
import 'package:costbook/features/transaction/models/transaction_summary_model.dart';
import 'package:costbook/features/transaction/repository/transaction_repository.dart';

part 'transaction_event.dart';
part 'transaction_state.dart';

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  TransactionBloc(this.repository, {required DateTime month}) : super(TransactionState(month: month)) {
    on<TransactionsRequested>(_onRequested);
    on<TransactionMonthChanged>(_onMonthChanged);
    on<TransactionSaved>(_onSaved);
    on<TransactionDeleted>(_onDeleted);
    on<TransactionsMoreRequested>(_onMoreRequested);
  }

  final TransactionRepository repository;

  Future<void> _onRequested(TransactionsRequested event, Emitter<TransactionState> emit) async {
    _showCachedFirst(emit, state.month);
    await _load(emit);
  }

  Future<void> _onMonthChanged(TransactionMonthChanged event, Emitter<TransactionState> emit) async {
    _showCachedFirst(emit, DateUtil.addMonths(state.month, event.monthCount));
    await _load(emit);
  }

  // เคยโหลดเดือนนี้แล้ว → โชว์ของเดิมทันที (ไม่ขึ้นหน้าโหลด) แล้วค่อยโหลดใหม่เงียบ ๆ / ยังไม่เคย → หน้าโหลด
  void _showCachedFirst(Emitter<TransactionState> emit, DateTime month) {
    final transactions = repository.cachedTransactions(month);
    final summary = repository.cachedSummary(month);
    if (transactions == null || summary == null) {
      emit(state.copyWith(status: AppStatus.loading, month: month, moreStatus: AppStatus.initial));
      return;
    }
    emit(
      state.copyWith(
        status: AppStatus.success,
        month: month,
        transactions: transactions,
        summary: summary,
        hasMore: PageUtil.hasMore(transactions.length, ApiConstants.pageSize),
        moreStatus: AppStatus.initial,
      ),
    );
  }

  // โหลดรายการ (limit = หน้าแรก หรือเท่าที่เลื่อนไว้แล้วตอนโหลดใหม่หลังบันทึก / ลบ) + สรุปของเดือน
  // ระหว่างรอผู้ใช้เปลี่ยนเดือนแล้ว → ทิ้งผลของเดือนเก่า
  Future<void> _load(Emitter<TransactionState> emit, {int limit = ApiConstants.pageSize}) async {
    final month = state.month;
    try {
      final transactions = await repository.getTransactions(month, limit: limit);
      final summary = await repository.getSummary(month);
      if (state.month != month) return;
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

  // หน้าต่อไป: ต่อท้ายรายการเดิม / กำลังโหลดอยู่ หรือหมดแล้ว → ไม่โหลดซ้ำ / ระหว่างรอเปลี่ยนเดือน → ทิ้งผล
  Future<void> _onMoreRequested(TransactionsMoreRequested event, Emitter<TransactionState> emit) async {
    if (state.status != AppStatus.success || !state.hasMore || state.moreStatus == AppStatus.loading) return;
    final month = state.month;
    emit(state.copyWith(moreStatus: AppStatus.loading));
    try {
      final next = await repository.getTransactions(month, offset: state.transactions.length);
      if (state.month != month) return;
      emit(
        state.copyWith(
          moreStatus: AppStatus.success,
          transactions: PageUtil.append(state.transactions, next, (transaction) => transaction.id),
          hasMore: PageUtil.hasMore(next.length, ApiConstants.pageSize),
        ),
      );
    } catch (_) {
      if (state.month != month) return;
      emit(state.copyWith(moreStatus: AppStatus.failure));
    }
  }
}
