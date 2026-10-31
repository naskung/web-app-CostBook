import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:costbook/core/constants/app_status.dart';
import 'package:costbook/core/network/api_exception.dart';
import 'package:costbook/features/invoice/bloc/invoice_detail_bloc.dart';
import 'package:costbook/features/invoice/models/invoice_model.dart';
import 'package:costbook/features/invoice/repository/invoice_repository.dart';

class MockInvoiceRepository extends Mock implements InvoiceRepository {}

void main() {
  late MockInvoiceRepository repository;

  const invoice = InvoiceModel(
    id: 'i1',
    invoiceNo: 'INV-2026-0001',
    issueDate: '2026-10-31',
    status: 'issued',
    customerName: 'ลูกค้า',
    subtotal: 100,
    vat: 7,
    total: 107,
  );
  const cancelled = InvoiceModel(
    id: 'i1',
    invoiceNo: 'INV-2026-0001',
    issueDate: '2026-10-31',
    status: 'cancelled',
    customerName: 'ลูกค้า',
    subtotal: 100,
    vat: 7,
    total: 107,
  );

  setUp(() {
    repository = MockInvoiceRepository();
  });

  blocTest<InvoiceDetailBloc, InvoiceDetailState>(
    'InvoiceDetailRequested โหลดใบกำกับ',
    build: () {
      when(() => repository.getInvoice('i1')).thenAnswer((_) async => invoice);
      return InvoiceDetailBloc(repository, invoiceId: 'i1');
    },
    act: (bloc) => bloc.add(InvoiceDetailRequested()),
    expect:
        () => [
          const InvoiceDetailState(status: AppStatus.loading),
          const InvoiceDetailState(status: AppStatus.success, invoice: invoice),
        ],
  );

  blocTest<InvoiceDetailBloc, InvoiceDetailState>(
    'InvoiceDetailRequested ไม่มีใบนี้ ได้ failure invoice_not_found',
    build: () {
      when(() => repository.getInvoice('i1')).thenThrow(ApiException('invoice_not_found'));
      return InvoiceDetailBloc(repository, invoiceId: 'i1');
    },
    act: (bloc) => bloc.add(InvoiceDetailRequested()),
    expect:
        () => [
          const InvoiceDetailState(status: AppStatus.loading),
          const InvoiceDetailState(status: AppStatus.failure, errorCode: 'invoice_not_found'),
        ],
  );

  blocTest<InvoiceDetailBloc, InvoiceDetailState>(
    'InvoiceCancelRequested สำเร็จ ได้ใบที่ยกเลิกแล้ว',
    build: () {
      when(() => repository.cancelInvoice('i1')).thenAnswer((_) async => cancelled);
      return InvoiceDetailBloc(repository, invoiceId: 'i1');
    },
    seed: () => const InvoiceDetailState(status: AppStatus.success, invoice: invoice),
    act: (bloc) => bloc.add(InvoiceCancelRequested()),
    expect:
        () => [
          const InvoiceDetailState(status: AppStatus.success, invoice: invoice, cancelStatus: AppStatus.loading),
          const InvoiceDetailState(status: AppStatus.success, invoice: cancelled, cancelStatus: AppStatus.success),
        ],
  );

  blocTest<InvoiceDetailBloc, InvoiceDetailState>(
    'InvoiceCancelRequested ยกเลิกซ้ำ ได้ cancelStatus failure',
    build: () {
      when(() => repository.cancelInvoice('i1')).thenThrow(ApiException('invoice_already_cancelled'));
      return InvoiceDetailBloc(repository, invoiceId: 'i1');
    },
    seed: () => const InvoiceDetailState(status: AppStatus.success, invoice: cancelled),
    act: (bloc) => bloc.add(InvoiceCancelRequested()),
    expect:
        () => [
          const InvoiceDetailState(status: AppStatus.success, invoice: cancelled, cancelStatus: AppStatus.loading),
          const InvoiceDetailState(
            status: AppStatus.success,
            invoice: cancelled,
            cancelStatus: AppStatus.failure,
            cancelErrorCode: 'invoice_already_cancelled',
          ),
        ],
  );
}
