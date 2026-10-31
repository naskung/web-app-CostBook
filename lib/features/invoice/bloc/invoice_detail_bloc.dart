import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:costbook/core/constants/app_status.dart';
import 'package:costbook/core/utils/error_util.dart';
import 'package:costbook/features/invoice/models/invoice_model.dart';
import 'package:costbook/features/invoice/repository/invoice_repository.dart';

part 'invoice_detail_event.dart';
part 'invoice_detail_state.dart';

class InvoiceDetailBloc extends Bloc<InvoiceDetailEvent, InvoiceDetailState> {
  InvoiceDetailBloc(this.repository, {required this.invoiceId}) : super(const InvoiceDetailState()) {
    on<InvoiceDetailRequested>(_onRequested);
    on<InvoiceCancelRequested>(_onCancelRequested);
  }

  final InvoiceRepository repository;
  final String invoiceId;

  Future<void> _onRequested(InvoiceDetailRequested event, Emitter<InvoiceDetailState> emit) async {
    emit(state.copyWith(status: AppStatus.loading));
    try {
      final invoice = await repository.getInvoice(invoiceId);
      emit(state.copyWith(status: AppStatus.success, invoice: invoice));
    } catch (error) {
      emit(state.copyWith(status: AppStatus.failure, errorCode: ErrorUtil.codeOf(error)));
    }
  }

  Future<void> _onCancelRequested(InvoiceCancelRequested event, Emitter<InvoiceDetailState> emit) async {
    emit(state.copyWith(cancelStatus: AppStatus.loading));
    try {
      final invoice = await repository.cancelInvoice(invoiceId);
      emit(state.copyWith(cancelStatus: AppStatus.success, invoice: invoice));
    } catch (error) {
      emit(state.copyWith(cancelStatus: AppStatus.failure, cancelErrorCode: ErrorUtil.codeOf(error)));
    }
  }
}
