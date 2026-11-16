import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart' show DateTimeRange;
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:costbook/core/constants/app_status.dart';
import 'package:costbook/core/constants/delivery_status.dart';
import 'package:costbook/core/network/api_exception.dart';
import 'package:costbook/features/invoice/bloc/invoice_list_bloc.dart';
import 'package:costbook/features/invoice/models/invoice_model.dart';
import 'package:costbook/features/invoice/models/invoice_summary_model.dart';
import 'package:costbook/features/invoice/repository/invoice_repository.dart';

class MockInvoiceRepository extends Mock implements InvoiceRepository {}

void main() {
  late MockInvoiceRepository repository;

  final october = DateTimeRange(start: DateTime(2026, 10), end: DateTime(2026, 10, 31));
  final september = DateTimeRange(start: DateTime(2026, 9, 1), end: DateTime(2026, 9, 30));
  const summary = InvoiceSummaryModel(
    id: 'i1',
    invoiceNo: 'INV-2026-0001',
    issueDate: '2026-10-31',
    status: 'issued',
    customerName: 'ลูกค้า',
    total: 107,
  );

  setUpAll(() {
    registerFallbackValue(DateTimeRange(start: DateTime(2026), end: DateTime(2026)));
  });

  setUp(() {
    repository = MockInvoiceRepository();
  });

  blocTest<InvoiceListBloc, InvoiceListState>(
    'InvoicesRequested โหลดใบกำกับของเดือน',
    build: () {
      when(() => repository.getInvoices(any())).thenAnswer((_) async => [summary]);
      return InvoiceListBloc(repository, range: october);
    },
    act: (bloc) => bloc.add(InvoicesRequested()),
    expect:
        () => [
          InvoiceListState(range: october, status: AppStatus.loading),
          InvoiceListState(range: october, status: AppStatus.success, invoices: const [summary]),
        ],
  );

  blocTest<InvoiceListBloc, InvoiceListState>(
    'InvoiceRangeChanged โหลดช่วงวันที่ใหม่',
    build: () {
      when(() => repository.getInvoices(any())).thenAnswer((_) async => []);
      return InvoiceListBloc(repository, range: october);
    },
    act: (bloc) => bloc.add(InvoiceRangeChanged(september)),
    expect:
        () => [
          InvoiceListState(range: september, status: AppStatus.loading),
          InvoiceListState(range: september, status: AppStatus.success),
        ],
    verify: (_) => verify(() => repository.getInvoices(september)).called(1),
  );

  blocTest<InvoiceListBloc, InvoiceListState>(
    'InvoicesRequested ล้มเหลว ได้ failure',
    build: () {
      when(() => repository.getInvoices(any())).thenThrow(ApiException('server_error'));
      return InvoiceListBloc(repository, range: october);
    },
    act: (bloc) => bloc.add(InvoicesRequested()),
    expect:
        () => [
          InvoiceListState(range: october, status: AppStatus.loading),
          InvoiceListState(range: october, status: AppStatus.failure, errorCode: 'server_error'),
        ],
  );

  // ใบที่ n ของเดือน (id ไม่ซ้ำ)
  InvoiceSummaryModel invoiceAt(int n) {
    return InvoiceSummaryModel(
      id: 'i$n',
      invoiceNo: 'RC-2026-$n',
      issueDate: '2026-10-31',
      status: 'issued',
      customerName: '',
      total: 100,
    );
  }

  final firstPage = [for (var n = 1; n <= 20; n++) invoiceAt(n)];
  final lastPage = [invoiceAt(21), invoiceAt(22)];

  blocTest<InvoiceListBloc, InvoiceListState>(
    'ได้ครบ 20 ใบ = ยังมีอีก (hasMore) / เลื่อนลงโหลดหน้าต่อไป ต่อท้าย ได้น้อยกว่า 20 = หมดแล้ว',
    build: () {
      when(() => repository.getInvoices(any())).thenAnswer((_) async => firstPage);
      when(() => repository.getInvoices(any(), offset: 20)).thenAnswer((_) async => lastPage);
      return InvoiceListBloc(repository, range: october);
    },
    act: (bloc) async {
      bloc.add(InvoicesRequested());
      await Future<void>.delayed(Duration.zero);
      bloc.add(InvoicesMoreRequested());
    },
    skip: 2,
    expect:
        () => [
          InvoiceListState(
            range: october,
            status: AppStatus.success,
            invoices: firstPage,
            hasMore: true,
            moreStatus: AppStatus.loading,
          ),
          InvoiceListState(
            range: october,
            status: AppStatus.success,
            invoices: [...firstPage, ...lastPage],
            moreStatus: AppStatus.success,
          ),
        ],
  );

  blocTest<InvoiceListBloc, InvoiceListState>(
    'หมดแล้ว (hasMore = false) / กำลังโหลดอยู่ → ไม่โหลดซ้ำ',
    build: () => InvoiceListBloc(repository, range: october),
    seed: () => InvoiceListState(range: october, status: AppStatus.success, invoices: [summary]),
    act: (bloc) => bloc.add(InvoicesMoreRequested()),
    expect: () => <InvoiceListState>[],
    verify: (_) => verifyNever(() => repository.getInvoices(any(), offset: any(named: 'offset'))),
  );

  blocTest<InvoiceListBloc, InvoiceListState>(
    'โหลดหน้าต่อไปไม่สำเร็จ → moreStatus failure (รายการเดิมยังอยู่ รอกดลองใหม่) / canLoadMore = false',
    build: () {
      when(() => repository.getInvoices(any(), offset: 20)).thenThrow(ApiException('network_error'));
      return InvoiceListBloc(repository, range: october);
    },
    seed: () => InvoiceListState(range: october, status: AppStatus.success, invoices: firstPage, hasMore: true),
    act: (bloc) => bloc.add(InvoicesMoreRequested()),
    expect:
        () => [
          InvoiceListState(
            range: october,
            status: AppStatus.success,
            invoices: firstPage,
            hasMore: true,
            moreStatus: AppStatus.loading,
          ),
          InvoiceListState(
            range: october,
            status: AppStatus.success,
            invoices: firstPage,
            hasMore: true,
            moreStatus: AppStatus.failure,
          ),
        ],
    verify: (bloc) => expect(bloc.state.canLoadMore, false),
  );

  group('InvoiceDeliveryChanged', () {
    const other = InvoiceSummaryModel(
      id: 'i2',
      invoiceNo: 'INV-2026-0002',
      issueDate: '2026-10-31',
      status: 'issued',
      customerName: 'ลูกค้า 2',
      total: 50,
    );
    const shippedInvoice = InvoiceModel(
      id: 'i1',
      invoiceNo: 'INV-2026-0001',
      issueDate: '2026-10-31',
      status: 'issued',
      deliveryStatus: DeliveryStatus.shipped,
      customerName: 'ลูกค้า',
      subtotal: 100,
      vat: 7,
      total: 107,
    );
    final loaded = InvoiceListState(range: october, status: AppStatus.success, invoices: const [summary, other]);

    blocTest<InvoiceListBloc, InvoiceListState>(
      'เปลี่ยนเป็นส่งแล้ว บันทึกแล้วแก้แค่แถวนั้น แถวอื่นเหมือนเดิม',
      build: () {
        when(() => repository.updateDelivery('i1', DeliveryStatus.shipped)).thenAnswer((_) async => shippedInvoice);
        return InvoiceListBloc(repository, range: october);
      },
      seed: () => loaded,
      act: (bloc) => bloc.add(InvoiceDeliveryChanged(invoiceId: 'i1', deliveryStatus: DeliveryStatus.shipped)),
      expect:
          () => [
            loaded.copyWith(deliveryUpdateStatus: AppStatus.loading),
            loaded.copyWith(
              deliveryUpdateStatus: AppStatus.success,
              invoices: [summary.copyWith(deliveryStatus: DeliveryStatus.shipped), other],
            ),
          ],
    );

    blocTest<InvoiceListBloc, InvoiceListState>(
      'บันทึกไม่ได้ (ใบถูกยกเลิกไปแล้ว) ได้ failure + error code รายการไม่เปลี่ยน',
      build: () {
        when(
          () => repository.updateDelivery('i1', DeliveryStatus.received),
        ).thenThrow(ApiException('invoice_already_cancelled'));
        return InvoiceListBloc(repository, range: october);
      },
      seed: () => loaded,
      act: (bloc) => bloc.add(InvoiceDeliveryChanged(invoiceId: 'i1', deliveryStatus: DeliveryStatus.received)),
      expect:
          () => [
            loaded.copyWith(deliveryUpdateStatus: AppStatus.loading),
            loaded.copyWith(deliveryUpdateStatus: AppStatus.failure, deliveryErrorCode: 'invoice_already_cancelled'),
          ],
    );
  });
}
