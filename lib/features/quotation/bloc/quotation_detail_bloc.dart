import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:costbook/core/constants/app_status.dart';
import 'package:costbook/core/utils/error_util.dart';
import 'package:costbook/features/quotation/models/quotation_model.dart';
import 'package:costbook/features/quotation/repository/quotation_repository.dart';

part 'quotation_detail_event.dart';
part 'quotation_detail_state.dart';

class QuotationDetailBloc extends Bloc<QuotationDetailEvent, QuotationDetailState> {
  QuotationDetailBloc(this.repository, {required this.quotationId}) : super(const QuotationDetailState()) {
    on<QuotationDetailRequested>(_onRequested);
    on<QuotationCancelRequested>(_onCancelRequested);
  }

  final QuotationRepository repository;
  final String quotationId;

  Future<void> _onRequested(QuotationDetailRequested event, Emitter<QuotationDetailState> emit) async {
    emit(state.copyWith(status: AppStatus.loading));
    try {
      final quotation = await repository.getQuotation(quotationId);
      emit(state.copyWith(status: AppStatus.success, quotation: quotation));
    } catch (error) {
      emit(state.copyWith(status: AppStatus.failure, errorCode: ErrorUtil.codeOf(error)));
    }
  }

  Future<void> _onCancelRequested(QuotationCancelRequested event, Emitter<QuotationDetailState> emit) async {
    emit(state.copyWith(cancelStatus: AppStatus.loading));
    try {
      final quotation = await repository.cancelQuotation(quotationId);
      emit(state.copyWith(cancelStatus: AppStatus.success, quotation: quotation));
    } catch (error) {
      emit(state.copyWith(cancelStatus: AppStatus.failure, cancelErrorCode: ErrorUtil.codeOf(error)));
    }
  }
}
