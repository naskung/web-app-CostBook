import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:costbook/core/constants/app_status.dart';
import 'package:costbook/core/utils/date_util.dart';
import 'package:costbook/core/utils/error_util.dart';
import 'package:costbook/features/invoice/models/invoice_summary_model.dart';
import 'package:costbook/features/invoice/repository/invoice_repository.dart';

part 'invoice_list_event.dart';
part 'invoice_list_state.dart';

class InvoiceListBloc extends Bloc<InvoiceListEvent, InvoiceListState> {
  InvoiceListBloc(this.repository, {required DateTime month}) : super(InvoiceListState(month: month)) {
    on<InvoicesRequested>(_onRequested);
    on<InvoiceMonthChanged>(_onMonthChanged);
  }

  final InvoiceRepository repository;

  Future<void> _onRequested(InvoicesRequested event, Emitter<InvoiceListState> emit) async {
    emit(state.copyWith(status: AppStatus.loading));
    await _load(emit);
  }

  Future<void> _onMonthChanged(InvoiceMonthChanged event, Emitter<InvoiceListState> emit) async {
    emit(state.copyWith(status: AppStatus.loading, month: DateUtil.addMonths(state.month, event.monthCount)));
    await _load(emit);
  }

  Future<void> _load(Emitter<InvoiceListState> emit) async {
    try {
      final invoices = await repository.getInvoices(state.month);
      emit(state.copyWith(status: AppStatus.success, invoices: invoices));
    } catch (error) {
      emit(state.copyWith(status: AppStatus.failure, errorCode: ErrorUtil.codeOf(error)));
    }
  }
}
