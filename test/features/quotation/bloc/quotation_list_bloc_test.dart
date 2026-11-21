import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart' show DateTimeRange;
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:costbook/core/constants/app_status.dart';
import 'package:costbook/core/network/api_exception.dart';
import 'package:costbook/features/quotation/bloc/quotation_list_bloc.dart';
import 'package:costbook/features/quotation/models/quotation_summary_model.dart';
import 'package:costbook/features/quotation/repository/quotation_repository.dart';

class MockQuotationRepository extends Mock implements QuotationRepository {}

void main() {
  late MockQuotationRepository repository;

  final november = DateTimeRange(start: DateTime(2026, 11), end: DateTime(2026, 11, 30));
  final october = DateTimeRange(start: DateTime(2026, 10), end: DateTime(2026, 10, 31));
  const summary = QuotationSummaryModel(
    id: 'q1',
    quotationNo: 'QT-2026-0001',
    issueDate: '2026-11-21',
    validUntil: '2026-12-21',
    status: 'issued',
    customerName: 'ลูกค้า',
    total: 107,
  );
  const nextPageItem = QuotationSummaryModel(
    id: 'q20',
    quotationNo: 'QT-2026-0021',
    issueDate: '2026-11-21',
    validUntil: '2026-12-21',
    status: 'issued',
    customerName: 'ลูกค้า',
    total: 107,
  );
  final fullPage = List.generate(
    20,
    (index) => QuotationSummaryModel(
      id: 'q$index',
      quotationNo: 'QT-2026-$index',
      issueDate: '2026-11-21',
      validUntil: '2026-12-21',
      status: 'issued',
      customerName: 'ลูกค้า',
      total: 100,
    ),
  );

  setUpAll(() {
    registerFallbackValue(DateTimeRange(start: DateTime(2026), end: DateTime(2026)));
  });

  setUp(() {
    repository = MockQuotationRepository();
  });

  blocTest<QuotationListBloc, QuotationListState>(
    'QuotationsRequested โหลดใบเสนอราคาของเดือน',
    build: () {
      when(() => repository.getQuotations(any())).thenAnswer((_) async => [summary]);
      return QuotationListBloc(repository, range: november);
    },
    act: (bloc) => bloc.add(QuotationsRequested()),
    expect:
        () => [
          QuotationListState(range: november, status: AppStatus.loading),
          QuotationListState(range: november, status: AppStatus.success, quotations: const [summary]),
        ],
  );

  blocTest<QuotationListBloc, QuotationListState>(
    'QuotationsRequested เคยโหลดแล้ว โชว์ของเดิมทันทีไม่ขึ้นหน้าโหลด',
    build: () {
      when(() => repository.cachedQuotations(any())).thenReturn(const [summary]);
      when(() => repository.getQuotations(any())).thenAnswer((_) async => [summary]);
      return QuotationListBloc(repository, range: november);
    },
    act: (bloc) => bloc.add(QuotationsRequested()),
    expect:
        () => [
          QuotationListState(range: november, status: AppStatus.success, quotations: const [summary]),
        ],
  );

  blocTest<QuotationListBloc, QuotationListState>(
    'QuotationRangeChanged โหลดช่วงวันที่ใหม่',
    build: () {
      when(() => repository.getQuotations(any())).thenAnswer((_) async => []);
      return QuotationListBloc(repository, range: november);
    },
    act: (bloc) => bloc.add(QuotationRangeChanged(october)),
    expect:
        () => [
          QuotationListState(range: october, status: AppStatus.loading),
          QuotationListState(range: october, status: AppStatus.success),
        ],
    verify: (_) => verify(() => repository.getQuotations(october)).called(1),
  );

  blocTest<QuotationListBloc, QuotationListState>(
    'QuotationsRequested ล้มเหลว ได้ failure + error code',
    build: () {
      when(() => repository.getQuotations(any())).thenThrow(ApiException('server_error'));
      return QuotationListBloc(repository, range: november);
    },
    act: (bloc) => bloc.add(QuotationsRequested()),
    expect:
        () => [
          QuotationListState(range: november, status: AppStatus.loading),
          QuotationListState(range: november, status: AppStatus.failure, errorCode: 'server_error'),
        ],
  );

  blocTest<QuotationListBloc, QuotationListState>(
    'QuotationsMoreRequested โหลดหน้าต่อไปต่อท้าย หน้าสุดท้ายไม่เต็ม = หมดแล้ว',
    build: () {
      when(() => repository.getQuotations(any(), offset: 20)).thenAnswer((_) async => [nextPageItem]);
      return QuotationListBloc(repository, range: november);
    },
    seed: () => QuotationListState(range: november, status: AppStatus.success, quotations: fullPage, hasMore: true),
    act: (bloc) => bloc.add(QuotationsMoreRequested()),
    expect:
        () => [
          QuotationListState(
            range: november,
            status: AppStatus.success,
            quotations: fullPage,
            hasMore: true,
            moreStatus: AppStatus.loading,
          ),
          QuotationListState(
            range: november,
            status: AppStatus.success,
            quotations: [...fullPage, nextPageItem],
            moreStatus: AppStatus.success,
          ),
        ],
  );

  blocTest<QuotationListBloc, QuotationListState>(
    'QuotationsMoreRequested ไม่มีหน้าต่อไปแล้ว ไม่โหลด',
    build: () => QuotationListBloc(repository, range: november),
    seed: () => QuotationListState(range: november, status: AppStatus.success, quotations: const [summary]),
    act: (bloc) => bloc.add(QuotationsMoreRequested()),
    expect: () => [],
    verify: (_) => verifyNever(() => repository.getQuotations(any(), offset: any(named: 'offset'))),
  );

  blocTest<QuotationListBloc, QuotationListState>(
    'QuotationsMoreRequested ล้มเหลว ได้ moreStatus failure รายการเดิมยังอยู่',
    build: () {
      when(() => repository.getQuotations(any(), offset: 20)).thenThrow(ApiException('network_error'));
      return QuotationListBloc(repository, range: november);
    },
    seed: () => QuotationListState(range: november, status: AppStatus.success, quotations: fullPage, hasMore: true),
    act: (bloc) => bloc.add(QuotationsMoreRequested()),
    skip: 1,
    expect:
        () => [
          QuotationListState(
            range: november,
            status: AppStatus.success,
            quotations: fullPage,
            hasMore: true,
            moreStatus: AppStatus.failure,
          ),
        ],
  );
}
