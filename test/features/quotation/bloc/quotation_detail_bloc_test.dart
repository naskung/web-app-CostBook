import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:costbook/core/constants/app_status.dart';
import 'package:costbook/core/network/api_exception.dart';
import 'package:costbook/features/quotation/bloc/quotation_detail_bloc.dart';
import 'package:costbook/features/quotation/models/quotation_model.dart';
import 'package:costbook/features/quotation/repository/quotation_repository.dart';

class MockQuotationRepository extends Mock implements QuotationRepository {}

void main() {
  late MockQuotationRepository repository;

  const quotation = QuotationModel(
    id: 'q1',
    quotationNo: 'QT-2026-0001',
    issueDate: '2026-11-21',
    validUntil: '2026-12-21',
    status: 'issued',
    customerName: 'ลูกค้า',
    total: 107,
  );
  const cancelled = QuotationModel(
    id: 'q1',
    quotationNo: 'QT-2026-0001',
    issueDate: '2026-11-21',
    validUntil: '2026-12-21',
    status: 'cancelled',
    customerName: 'ลูกค้า',
    total: 107,
  );
  const loaded = QuotationDetailState(status: AppStatus.success, quotation: quotation);

  setUp(() {
    repository = MockQuotationRepository();
  });

  blocTest<QuotationDetailBloc, QuotationDetailState>(
    'QuotationDetailRequested โหลดใบเสนอราคา',
    build: () {
      when(() => repository.getQuotation('q1')).thenAnswer((_) async => quotation);
      return QuotationDetailBloc(repository, quotationId: 'q1');
    },
    act: (bloc) => bloc.add(QuotationDetailRequested()),
    expect: () => [const QuotationDetailState(status: AppStatus.loading), loaded],
  );

  blocTest<QuotationDetailBloc, QuotationDetailState>(
    'QuotationDetailRequested ไม่มีใบนี้ ได้ failure quotation_not_found',
    build: () {
      when(() => repository.getQuotation('q1')).thenThrow(ApiException('quotation_not_found'));
      return QuotationDetailBloc(repository, quotationId: 'q1');
    },
    act: (bloc) => bloc.add(QuotationDetailRequested()),
    expect:
        () => [
          const QuotationDetailState(status: AppStatus.loading),
          const QuotationDetailState(status: AppStatus.failure, errorCode: 'quotation_not_found'),
        ],
  );

  blocTest<QuotationDetailBloc, QuotationDetailState>(
    'QuotationCancelRequested สำเร็จ ได้ใบที่ยกเลิกแล้ว',
    build: () {
      when(() => repository.cancelQuotation('q1')).thenAnswer((_) async => cancelled);
      return QuotationDetailBloc(repository, quotationId: 'q1');
    },
    seed: () => loaded,
    act: (bloc) => bloc.add(QuotationCancelRequested()),
    expect:
        () => [
          loaded.copyWith(cancelStatus: AppStatus.loading),
          loaded.copyWith(cancelStatus: AppStatus.success, quotation: cancelled),
        ],
  );

  blocTest<QuotationDetailBloc, QuotationDetailState>(
    'QuotationCancelRequested ยกเลิกซ้ำ ได้ cancelStatus failure ใบเดิมยังอยู่',
    build: () {
      when(() => repository.cancelQuotation('q1')).thenThrow(ApiException('quotation_already_cancelled'));
      return QuotationDetailBloc(repository, quotationId: 'q1');
    },
    seed: () => loaded,
    act: (bloc) => bloc.add(QuotationCancelRequested()),
    expect:
        () => [
          loaded.copyWith(cancelStatus: AppStatus.loading),
          loaded.copyWith(cancelStatus: AppStatus.failure, cancelErrorCode: 'quotation_already_cancelled'),
        ],
  );
}
