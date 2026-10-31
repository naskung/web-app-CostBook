import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:costbook/core/constants/app_status.dart';
import 'package:costbook/core/utils/date_util.dart';
import 'package:costbook/core/utils/error_util.dart';
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
  }

  final TransactionRepository repository;

  Future<void> _onRequested(TransactionsRequested event, Emitter<TransactionState> emit) async {
    emit(state.copyWith(status: AppStatus.loading));
    await _load(emit);
  }

  Future<void> _onMonthChanged(TransactionMonthChanged event, Emitter<TransactionState> emit) async {
    emit(state.copyWith(status: AppStatus.loading, month: DateUtil.addMonths(state.month, event.monthCount)));
    await _load(emit);
  }

  Future<void> _load(Emitter<TransactionState> emit) async {
    try {
      final transactions = await repository.getTransactions(state.month);
      final summary = await repository.getSummary(state.month);
      emit(state.copyWith(status: AppStatus.success, transactions: transactions, summary: summary));
    } catch (error) {
      emit(state.copyWith(status: AppStatus.failure, errorCode: ErrorUtil.codeOf(error)));
    }
  }

  Future<void> _onSaved(TransactionSaved event, Emitter<TransactionState> emit) async {
    emit(state.copyWith(saveStatus: AppStatus.loading));
    try {
      await repository.saveTransaction(event.transaction);
      emit(state.copyWith(saveStatus: AppStatus.success));
      await _load(emit);
    } catch (error) {
      emit(state.copyWith(saveStatus: AppStatus.failure, saveErrorCode: ErrorUtil.codeOf(error)));
    }
  }

  Future<void> _onDeleted(TransactionDeleted event, Emitter<TransactionState> emit) async {
    emit(state.copyWith(deleteStatus: AppStatus.loading));
    try {
      await repository.deleteTransaction(event.id);
      emit(state.copyWith(deleteStatus: AppStatus.success));
      await _load(emit);
    } catch (error) {
      emit(state.copyWith(deleteStatus: AppStatus.failure, deleteErrorCode: ErrorUtil.codeOf(error)));
    }
  }
}
