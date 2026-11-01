import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:costbook/core/constants/app_status.dart';
import 'package:costbook/core/network/api_exception.dart';
import 'package:costbook/features/invoice/bloc/invoice_list_bloc.dart';
import 'package:costbook/features/invoice/models/invoice_summary_model.dart';
import 'package:costbook/features/invoice/repository/invoice_repository.dart';

class MockInvoiceRepository extends Mock implements InvoiceRepository {}

void main() {
  late MockInvoiceRepository repository;

  final october = DateTime(2026, 10);
  const summary = InvoiceSummaryModel(
    id: 'i1',
    invoiceNo: 'INV-2026-0001',
    issueDate: '2026-10-31',
    status: 'issued',
    customerName: 'ลูกค้า',
    total: 107,
  );

  setUpAll(() {
    registerFallbackValue(DateTime(2026));
  });

  setUp(() {
    repository = MockInvoiceRepository();
  });

  blocTest<InvoiceListBloc, InvoiceListState>(
    'InvoicesRequested โหลดใบกำกับของเดือน',
    build: () {
      when(() => repository.getInvoices(any())).thenAnswer((_) async => [summary]);
      return InvoiceListBloc(repository, month: october);
    },
    act: (bloc) => bloc.add(InvoicesRequested()),
    expect:
        () => [
          InvoiceListState(month: october, status: AppStatus.loading),
          InvoiceListState(month: october, status: AppStatus.success, invoices: const [summary]),
        ],
  );

  blocTest<InvoiceListBloc, InvoiceListState>(
    'InvoiceMonthChanged -1 โหลดเดือนก่อน',
    build: () {
      when(() => repository.getInvoices(any())).thenAnswer((_) async => []);
      return InvoiceListBloc(repository, month: october);
    },
    act: (bloc) => bloc.add(InvoiceMonthChanged(-1)),
    expect:
        () => [
          InvoiceListState(month: DateTime(2026, 9), status: AppStatus.loading),
          InvoiceListState(month: DateTime(2026, 9), status: AppStatus.success),
        ],
    verify: (_) => verify(() => repository.getInvoices(DateTime(2026, 9))).called(1),
  );

  blocTest<InvoiceListBloc, InvoiceListState>(
    'InvoicesRequested ล้มเหลว ได้ failure',
    build: () {
      when(() => repository.getInvoices(any())).thenThrow(ApiException('server_error'));
      return InvoiceListBloc(repository, month: october);
    },
    act: (bloc) => bloc.add(InvoicesRequested()),
    expect:
        () => [
          InvoiceListState(month: october, status: AppStatus.loading),
          InvoiceListState(month: october, status: AppStatus.failure, errorCode: 'server_error'),
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
      return InvoiceListBloc(repository, month: october);
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
            month: october,
            status: AppStatus.success,
            invoices: firstPage,
            hasMore: true,
            moreStatus: AppStatus.loading,
          ),
          InvoiceListState(
            month: october,
            status: AppStatus.success,
            invoices: [...firstPage, ...lastPage],
            moreStatus: AppStatus.success,
          ),
        ],
  );

  blocTest<InvoiceListBloc, InvoiceListState>(
    'หมดแล้ว (hasMore = false) / กำลังโหลดอยู่ → ไม่โหลดซ้ำ',
    build: () => InvoiceListBloc(repository, month: october),
    seed: () => InvoiceListState(month: october, status: AppStatus.success, invoices: [summary]),
    act: (bloc) => bloc.add(InvoicesMoreRequested()),
    expect: () => <InvoiceListState>[],
    verify: (_) => verifyNever(() => repository.getInvoices(any(), offset: any(named: 'offset'))),
  );

  blocTest<InvoiceListBloc, InvoiceListState>(
    'โหลดหน้าต่อไปไม่สำเร็จ → moreStatus failure (รายการเดิมยังอยู่ รอกดลองใหม่) / canLoadMore = false',
    build: () {
      when(() => repository.getInvoices(any(), offset: 20)).thenThrow(ApiException('network_error'));
      return InvoiceListBloc(repository, month: october);
    },
    seed: () => InvoiceListState(month: october, status: AppStatus.success, invoices: firstPage, hasMore: true),
    act: (bloc) => bloc.add(InvoicesMoreRequested()),
    expect:
        () => [
          InvoiceListState(
            month: october,
            status: AppStatus.success,
            invoices: firstPage,
            hasMore: true,
            moreStatus: AppStatus.loading,
          ),
          InvoiceListState(
            month: october,
            status: AppStatus.success,
            invoices: firstPage,
            hasMore: true,
            moreStatus: AppStatus.failure,
          ),
        ],
    verify: (bloc) => expect(bloc.state.canLoadMore, false),
  );
}
