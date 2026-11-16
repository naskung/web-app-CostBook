import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart' show DateTimeRange;
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:costbook/core/constants/api_constants.dart';
import 'package:costbook/core/constants/app_status.dart';
import 'package:costbook/core/constants/delivery_status.dart';
import 'package:costbook/core/utils/error_util.dart';
import 'package:costbook/core/utils/page_util.dart';
import 'package:costbook/features/invoice/models/invoice_summary_model.dart';
import 'package:costbook/features/invoice/repository/invoice_repository.dart';

part 'invoice_list_event.dart';
part 'invoice_list_state.dart';

class InvoiceListBloc extends Bloc<InvoiceListEvent, InvoiceListState> {
  InvoiceListBloc(this.repository, {required DateTimeRange range}) : super(InvoiceListState(range: range)) {
    on<InvoicesRequested>(_onRequested);
    on<InvoiceRangeChanged>(_onRangeChanged);
    on<InvoicesMoreRequested>(_onMoreRequested);
    on<InvoiceDeliveryChanged>(_onDeliveryChanged);
  }

  final InvoiceRepository repository;

  Future<void> _onRequested(InvoicesRequested event, Emitter<InvoiceListState> emit) async {
    _showCachedFirst(emit, state.range);
    await _load(emit);
  }

  Future<void> _onRangeChanged(InvoiceRangeChanged event, Emitter<InvoiceListState> emit) async {
    _showCachedFirst(emit, event.range);
    await _load(emit);
  }

  // เคยโหลดช่วงนี้แล้ว → โชว์ของเดิมทันที (ไม่ขึ้นหน้าโหลด) แล้วค่อยโหลดใหม่เงียบ ๆ / ยังไม่เคย → หน้าโหลด
  void _showCachedFirst(Emitter<InvoiceListState> emit, DateTimeRange range) {
    final invoices = repository.cachedInvoices(range);
    if (invoices == null) {
      emit(state.copyWith(status: AppStatus.loading, range: range, moreStatus: AppStatus.initial));
      return;
    }
    emit(
      state.copyWith(
        status: AppStatus.success,
        range: range,
        invoices: invoices,
        hasMore: PageUtil.hasMore(invoices.length, ApiConstants.pageSize),
        moreStatus: AppStatus.initial,
      ),
    );
  }

  // โหลดหน้าแรกของเดือน / ระหว่างรอผู้ใช้เปลี่ยนช่วงวันที่แล้ว → ทิ้งผลของช่วงเก่า
  Future<void> _load(Emitter<InvoiceListState> emit) async {
    final range = state.range;
    try {
      final invoices = await repository.getInvoices(range);
      if (state.range != range) return;
      emit(
        state.copyWith(
          status: AppStatus.success,
          invoices: invoices,
          hasMore: PageUtil.hasMore(invoices.length, ApiConstants.pageSize),
        ),
      );
    } catch (error) {
      // มีของเดิมโชว์อยู่ (จาก cache) แล้วโหลดใหม่ไม่ได้ → โชว์ของเดิมต่อ ไม่ขึ้นหน้า error
      if (state.status == AppStatus.success) return;
      emit(state.copyWith(status: AppStatus.failure, errorCode: ErrorUtil.codeOf(error)));
    }
  }

  // หน้าต่อไป: ต่อท้ายรายการเดิม / กำลังโหลดอยู่ หรือหมดแล้ว → ไม่โหลดซ้ำ / ระหว่างรอเปลี่ยนช่วงวันที่ → ทิ้งผล
  Future<void> _onMoreRequested(InvoicesMoreRequested event, Emitter<InvoiceListState> emit) async {
    if (state.status != AppStatus.success || !state.hasMore || state.moreStatus == AppStatus.loading) return;
    final range = state.range;
    emit(state.copyWith(moreStatus: AppStatus.loading));
    try {
      final next = await repository.getInvoices(range, offset: state.invoices.length);
      if (state.range != range) return;
      emit(
        state.copyWith(
          moreStatus: AppStatus.success,
          invoices: PageUtil.append(state.invoices, next, (invoice) => invoice.id),
          hasMore: PageUtil.hasMore(next.length, ApiConstants.pageSize),
        ),
      );
    } catch (_) {
      if (state.range != range) return;
      emit(state.copyWith(moreStatus: AppStatus.failure));
    }
  }

  // เปลี่ยนสถานะการส่งของใบเดียว: บันทึกแล้วแก้แค่แถวนั้นในรายการ (ไม่โหลดทั้งเดือนใหม่)
  Future<void> _onDeliveryChanged(InvoiceDeliveryChanged event, Emitter<InvoiceListState> emit) async {
    emit(state.copyWith(deliveryUpdateStatus: AppStatus.loading));
    try {
      final invoice = await repository.updateDelivery(event.invoiceId, event.deliveryStatus);
      final invoices = [
        for (final summary in state.invoices)
          if (summary.id == invoice.id) summary.copyWith(deliveryStatus: invoice.deliveryStatus) else summary,
      ];
      emit(state.copyWith(deliveryUpdateStatus: AppStatus.success, invoices: invoices));
    } catch (error) {
      emit(state.copyWith(deliveryUpdateStatus: AppStatus.failure, deliveryErrorCode: ErrorUtil.codeOf(error)));
    }
  }
}
