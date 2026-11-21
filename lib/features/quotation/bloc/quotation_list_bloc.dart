import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart' show DateTimeRange;
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:costbook/core/constants/api_constants.dart';
import 'package:costbook/core/constants/app_status.dart';
import 'package:costbook/core/utils/error_util.dart';
import 'package:costbook/core/utils/page_util.dart';
import 'package:costbook/features/quotation/models/quotation_summary_model.dart';
import 'package:costbook/features/quotation/repository/quotation_repository.dart';

part 'quotation_list_event.dart';
part 'quotation_list_state.dart';

class QuotationListBloc extends Bloc<QuotationListEvent, QuotationListState> {
  QuotationListBloc(this.repository, {required DateTimeRange range}) : super(QuotationListState(range: range)) {
    on<QuotationsRequested>(_onRequested);
    on<QuotationRangeChanged>(_onRangeChanged);
    on<QuotationsMoreRequested>(_onMoreRequested);
  }

  final QuotationRepository repository;

  Future<void> _onRequested(QuotationsRequested event, Emitter<QuotationListState> emit) async {
    _showCachedFirst(emit, state.range);
    await _load(emit);
  }

  Future<void> _onRangeChanged(QuotationRangeChanged event, Emitter<QuotationListState> emit) async {
    _showCachedFirst(emit, event.range);
    await _load(emit);
  }

  // เคยโหลดช่วงนี้แล้ว → โชว์ของเดิมทันที แล้วค่อยโหลดใหม่เงียบ ๆ / ยังไม่เคย → หน้าโหลด
  void _showCachedFirst(Emitter<QuotationListState> emit, DateTimeRange range) {
    final quotations = repository.cachedQuotations(range);
    if (quotations == null) {
      emit(state.copyWith(status: AppStatus.loading, range: range, moreStatus: AppStatus.initial));
      return;
    }
    emit(
      state.copyWith(
        status: AppStatus.success,
        range: range,
        quotations: quotations,
        hasMore: PageUtil.hasMore(quotations.length, ApiConstants.pageSize),
        moreStatus: AppStatus.initial,
      ),
    );
  }

  // ระหว่างรอผู้ใช้เปลี่ยนช่วงวันที่แล้ว → ทิ้งผลของช่วงเก่า
  Future<void> _load(Emitter<QuotationListState> emit) async {
    final range = state.range;
    try {
      final quotations = await repository.getQuotations(range);
      if (state.range != range) return;
      emit(
        state.copyWith(
          status: AppStatus.success,
          quotations: quotations,
          hasMore: PageUtil.hasMore(quotations.length, ApiConstants.pageSize),
        ),
      );
    } catch (error) {
      if (state.status == AppStatus.success) return;
      emit(state.copyWith(status: AppStatus.failure, errorCode: ErrorUtil.codeOf(error)));
    }
  }

  Future<void> _onMoreRequested(QuotationsMoreRequested event, Emitter<QuotationListState> emit) async {
    if (state.status != AppStatus.success || !state.hasMore || state.moreStatus == AppStatus.loading) return;
    final range = state.range;
    emit(state.copyWith(moreStatus: AppStatus.loading));
    try {
      final next = await repository.getQuotations(range, offset: state.quotations.length);
      if (state.range != range) return;
      emit(
        state.copyWith(
          moreStatus: AppStatus.success,
          quotations: PageUtil.append(state.quotations, next, (quotation) => quotation.id),
          hasMore: PageUtil.hasMore(next.length, ApiConstants.pageSize),
        ),
      );
    } catch (_) {
      if (state.range != range) return;
      emit(state.copyWith(moreStatus: AppStatus.failure));
    }
  }
}
