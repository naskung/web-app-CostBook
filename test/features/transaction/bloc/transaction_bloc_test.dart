import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:costbook/core/constants/app_status.dart';
import 'package:costbook/core/network/api_exception.dart';
import 'package:costbook/features/transaction/bloc/transaction_bloc.dart';
import 'package:costbook/features/transaction/models/transaction_model.dart';
import 'package:costbook/features/transaction/models/transaction_summary_model.dart';
import 'package:costbook/features/transaction/repository/transaction_repository.dart';

class MockTransactionRepository extends Mock implements TransactionRepository {}

void main() {
  late MockTransactionRepository repository;

  final october = DateTime(2026, 10);
  final november = DateTime(2026, 11);
  const rent = TransactionModel(id: 't1', type: 'expense', category: 'rent', amount: 5000, date: '2026-10-01');
  const summary = TransactionSummaryModel(income: 8000, expense: 5000, profit: 3000);

  setUpAll(() {
    registerFallbackValue(rent);
    registerFallbackValue(DateTime(2026));
  });

  setUp(() {
    repository = MockTransactionRepository();
    when(() => repository.getTransactions(any())).thenAnswer((_) async => [rent]);
    when(() => repository.getSummary(any())).thenAnswer((_) async => summary);
  });

  TransactionBloc buildBloc() => TransactionBloc(repository, month: october);

  blocTest<TransactionBloc, TransactionState>(
    'TransactionsRequested โหลดรายการและยอดสรุปของเดือน',
    build: buildBloc,
    act: (bloc) => bloc.add(TransactionsRequested()),
    expect: () => [
      TransactionState(month: october, status: AppStatus.loading),
      TransactionState(month: october, status: AppStatus.success, transactions: const [rent], summary: summary),
    ],
  );

  blocTest<TransactionBloc, TransactionState>(
    'TransactionsRequested ล้มเหลว ได้ failure พร้อม code',
    build: () {
      when(() => repository.getTransactions(any())).thenThrow(ApiException('network_error'));
      return buildBloc();
    },
    act: (bloc) => bloc.add(TransactionsRequested()),
    expect: () => [
      TransactionState(month: october, status: AppStatus.loading),
      TransactionState(month: october, status: AppStatus.failure, errorCode: 'network_error'),
    ],
  );

  blocTest<TransactionBloc, TransactionState>(
    'TransactionMonthChanged +1 เปลี่ยนเป็นเดือนถัดไป แล้วโหลดของเดือนนั้น',
    build: buildBloc,
    act: (bloc) => bloc.add(TransactionMonthChanged(1)),
    expect: () => [
      TransactionState(month: november, status: AppStatus.loading),
      TransactionState(month: november, status: AppStatus.success, transactions: const [rent], summary: summary),
    ],
    verify: (_) => verify(() => repository.getTransactions(november)).called(1),
  );

  blocTest<TransactionBloc, TransactionState>(
    'TransactionSaved สำเร็จ บันทึกแล้วโหลดเดือนนั้นใหม่',
    build: () {
      when(() => repository.saveTransaction(any())).thenAnswer((_) async {});
      return buildBloc();
    },
    act: (bloc) => bloc.add(TransactionSaved(rent)),
    expect: () => [
      TransactionState(month: october, saveStatus: AppStatus.loading),
      TransactionState(month: october, saveStatus: AppStatus.success),
      TransactionState(
        month: october,
        status: AppStatus.success,
        transactions: const [rent],
        summary: summary,
        saveStatus: AppStatus.success,
      ),
    ],
  );

  blocTest<TransactionBloc, TransactionState>(
    'TransactionSaved จำนวนเงินผิด ได้ saveStatus failure',
    build: () {
      when(() => repository.saveTransaction(any())).thenThrow(ApiException('transaction_amount_invalid'));
      return buildBloc();
    },
    act: (bloc) => bloc.add(TransactionSaved(rent)),
    expect: () => [
      TransactionState(month: october, saveStatus: AppStatus.loading),
      TransactionState(month: october, saveStatus: AppStatus.failure, saveErrorCode: 'transaction_amount_invalid'),
    ],
  );

  blocTest<TransactionBloc, TransactionState>(
    'TransactionDeleted รายการจากใบกำกับ ได้ deleteStatus failure',
    build: () {
      when(() => repository.deleteTransaction('t1')).thenThrow(ApiException('transaction_from_invoice'));
      return buildBloc();
    },
    act: (bloc) => bloc.add(TransactionDeleted('t1')),
    expect: () => [
      TransactionState(month: october, deleteStatus: AppStatus.loading),
      TransactionState(month: october, deleteStatus: AppStatus.failure, deleteErrorCode: 'transaction_from_invoice'),
    ],
  );

  blocTest<TransactionBloc, TransactionState>(
    'TransactionDeleted สำเร็จ ลบแล้วโหลดใหม่',
    build: () {
      when(() => repository.deleteTransaction('t1')).thenAnswer((_) async {});
      when(() => repository.getTransactions(any())).thenAnswer((_) async => []);
      return buildBloc();
    },
    act: (bloc) => bloc.add(TransactionDeleted('t1')),
    expect: () => [
      TransactionState(month: october, deleteStatus: AppStatus.loading),
      TransactionState(month: october, deleteStatus: AppStatus.success),
      TransactionState(month: october, status: AppStatus.success, summary: summary, deleteStatus: AppStatus.success),
    ],
  );
}
